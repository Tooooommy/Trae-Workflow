const fs = require('fs-extra');
const path = require('path');
const { execSync } = require('child_process');
const chalk = require('chalk');
const os = require('os');

const DEFAULT_REPO = 'Tooooommy/Trae-Workflow';
const TRAECONFIG_DIR = path.join(os.homedir(), '.trae-cn');

function log(message, level = 'info') {
  const colors = {
    info: chalk.cyan,
    success: chalk.green,
    warning: chalk.yellow,
    error: chalk.red,
    gray: chalk.gray,
  };
  console.log(colors[level](message));
}

function getPlatform() {
  const platform = os.platform();
  if (platform === 'win32') return 'windows';
  if (platform === 'darwin') return 'macos';
  if (platform === 'linux') return 'linux';
  return platform;
}

function buildSetupArgs(options) {
  const args = [];

  if (options.backup) args.push('--backup');
  if (options.skipMcp) args.push('--skip-mcp');
  if (options.skipSkills) args.push('--skip-skills');
  if (options.skipAgents) args.push('--skip-agents');
  if (options.skipRules) args.push('--skip-rules');
  if (options.skipTracking) args.push('--skip-tracking');
  if (options.skipProjectRules) args.push('--skip-project-rules');
  if (options.quiet) args.push('--quiet');
  if (options.force) args.push('--force');
  if (options.path) args.push('--project-path', options.path);
  if (options.type) args.push('--project-type', options.type);

  return args;
}

async function runBashSetupScript(setupPath, options) {
  const args = buildSetupArgs(options);

  log('Running setup script (bash)...', 'info');

  try {
    const { spawnSync } = require('child_process');
    const result = spawnSync('bash', [setupPath, ...args], {
      stdio: 'inherit',
      cwd: path.dirname(setupPath),
    });

    if (result.status !== 0) {
      throw new Error(`Setup script exited with code ${result.status}`);
    }

    log('Setup completed successfully!', 'success');
  } catch (error) {
    throw new Error(`Setup script failed: ${error.message}`);
  }
}

async function runPowerShellSetupScript(setupPath, options) {
  const args = [];

  if (options.backup) args.push('-Backup');
  if (options.skipMcp) args.push('-SkipMCP');
  if (options.skipSkills) args.push('-SkipSkills');
  if (options.skipAgents) args.push('-SkipAgents');
  if (options.skipRules) args.push('-SkipRules');
  if (options.skipTracking) args.push('-SkipTracking');
  if (options.skipProjectRules) args.push('-SkipProjectRules');
  if (options.quiet) args.push('-Quiet');
  if (options.force) args.push('-Force');
  if (options.path) args.push(`-ProjectPath "${options.path}"`);
  if (options.type) args.push(`-ProjectType "${options.type}"`);

  const command = `powershell -ExecutionPolicy Bypass -File "${setupPath}" ${args.join(' ')}`;

  log('Running setup script (PowerShell)...', 'info');

  try {
    execSync(command, { stdio: 'inherit' });
    log('Setup completed successfully!', 'success');
  } catch (error) {
    throw new Error(`Setup script failed: ${error.message}`);
  }
}

async function runSetupScript(tempDir, options) {
  const platform = getPlatform();

  if (platform === 'windows') {
    const setupPs1 = path.join(tempDir, 'setup.ps1');
    if (fs.existsSync(setupPs1)) {
      return runPowerShellSetupScript(setupPs1, options);
    }
  }

  const setupSh = path.join(tempDir, 'setup.sh');
  if (fs.existsSync(setupSh)) {
    return runBashSetupScript(setupSh, options);
  }

  throw new Error('No setup script found (setup.sh or setup.ps1)');
}

async function update(options = {}) {
  const configDir = TRAECONFIG_DIR;
  const repoSourceDir = path.join(configDir, '.repo');

  if (!fs.existsSync(repoSourceDir)) {
    log('No existing installation found. Running fresh install...', 'info');
    const { install } = require('./install');
    await install(DEFAULT_REPO, { ...options, force: true });
    return;
  }

  const gitDir = path.join(repoSourceDir, '.git');
  if (!fs.existsSync(gitDir)) {
    log('Existing installation is not a git repository. Running fresh install...', 'warning');
    const { install } = require('./install');
    await install(DEFAULT_REPO, { ...options, force: true });
    return;
  }

  try {
    log('Pulling latest changes...', 'info');

    execSync('git fetch origin', {
      cwd: repoSourceDir,
      stdio: 'inherit',
    });

    execSync('git reset --hard origin/main', {
      cwd: repoSourceDir,
      stdio: 'inherit',
    });

    log('Running setup with latest changes...', 'info');

    await runSetupScript(repoSourceDir, { ...options, force: true });

    log('Update completed!', 'success');
  } catch (error) {
    log(`Update failed: ${error.message}`, 'error');
    log('Running fresh install instead...', 'info');
    
    const { install } = require('./install');
    await install(DEFAULT_REPO, { ...options, force: true });
  }
}

module.exports = { update };
