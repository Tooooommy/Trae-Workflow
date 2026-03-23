const fs = require('fs-extra');
const path = require('path');
const { execSync, spawnSync } = require('child_process');
const chalk = require('chalk');
const os = require('os');

const DEFAULT_REPO = 'Tooooommy/Trae-Workflow';
const TRAECONFIG_DIR = path.join(os.homedir(), '.trae-cn');

const COLORS = {
  info: chalk.cyan,
  success: chalk.green,
  warning: chalk.yellow,
  error: chalk.red,
  gray: chalk.gray,
  white: chalk.white,
};

function log(message, level = 'info') {
  console.log(COLORS[level](message));
}

function getPlatform() {
  const platform = os.platform();
  if (platform === 'win32') return 'windows';
  if (platform === 'darwin') return 'macos';
  if (platform === 'linux') return 'linux';
  return platform;
}

function isWindows() {
  return os.platform() === 'win32';
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

async function installFromLocal(sourceDir, options) {
  log('Installing from local directory...', 'info');

  const platform = getPlatform();

  if (platform === 'windows') {
    const setupPs1 = path.join(sourceDir, 'setup.ps1');
    if (fs.existsSync(setupPs1)) {
      return runPowerShellSetupScript(setupPs1, options);
    }
  }

  const setupSh = path.join(sourceDir, 'setup.sh');
  if (fs.existsSync(setupSh)) {
    return runBashSetupScript(setupSh, options);
  }

  throw new Error('No setup script found in local directory');
}

function showHelp() {
  console.log('');
  log('========================================', 'info');
  log('  Trae Workflow CLI Install', 'info');
  log('========================================', 'info');
  console.log('');
  log('Usage: traew install [repo] [options]', 'white');
  console.log('');
  log('Options:', 'warning');
  log('  --backup                Backup existing config', 'white');
  log('  --skip-mcp              Skip MCP config', 'white');
  log('  --skip-skills           Skip Skills config', 'white');
  log('  --skip-agents           Skip Agents config', 'white');
  log('  --skip-rules            Skip Rules config', 'white');
  log('  --skip-tracking         Skip Tracking config', 'white');
  log('  --skip-project-rules    Skip Project Rules config', 'white');
  log('  --quiet                 Quiet mode', 'white');
  log('  --force                 Force execution', 'white');
  log('  --path <path>           Project path for Project Rules', 'white');
  log('  --type <type>           Project type', 'white');
  log('  --local <dir>           Install from local directory', 'white');
  console.log('');
  log('Examples:', 'warning');
  log('  traew install', 'gray');
  log('  traew install --backup', 'gray');
  log('  traew install --path ~/myproject --type typescript', 'gray');
  log('  traew install --local ./Trae-Workflow', 'gray');
  console.log('');
  log('Supported project types:', 'warning');
  log('  typescript, python, java, golang, rust, kotlin, swift', 'gray');
  console.log('');
}

async function install(repo, options) {
  if (options.help) {
    showHelp();
    return;
  }

  if (options.local) {
    try {
      await installFromLocal(options.local, options);
      log('Local installation completed!', 'success');
    } catch (error) {
      log(`Local installation failed: ${error.message}`, 'error');
      process.exit(1);
    }
    return;
  }

  const targetRepo = repo || DEFAULT_REPO;
  const tempDir = path.join(__dirname, '..', '.temp');
  const repoSourceDir = path.join(TRAECONFIG_DIR, '.repo');

  try {
    log(`Installing Trae Workflow from ${targetRepo}`, 'info');
    log(`Platform: ${getPlatform()}`, 'gray');

    await fs.ensureDir(tempDir);

    const clonePath = path.join(tempDir, 'repo');
    const repoUrl = `https://github.com/${targetRepo}.git`;

    log('Cloning repository...', 'info');

    try {
      execSync(`git clone --depth=1 "${repoUrl}" "${clonePath}"`, {
        stdio: 'inherit',
      });
    } catch (cloneError) {
      throw new Error(`Failed to clone repository: ${cloneError.message}`);
    }

    log('Repository cloned successfully', 'success');

    if (fs.existsSync(repoSourceDir)) {
      await fs.remove(repoSourceDir);
    }
    await fs.move(clonePath, repoSourceDir);

    await runSetupScript(repoSourceDir, options);

    await fs.remove(tempDir);

    log('Installation completed!', 'success');
    log(`Config location: ${TRAECONFIG_DIR}`, 'gray');
    log(`Source repository: ${repoSourceDir}`, 'gray');
  } catch (error) {
    log(`Installation failed: ${error.message}`, 'error');
    process.exit(1);
  }
}

module.exports = { install, installFromLocal };
