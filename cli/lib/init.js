const fs = require('fs-extra');
const path = require('path');
const os = require('os');
const chalk = require('chalk');

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

function getAvailableProjectTypes() {
  const skillsDir = path.join(TRAECONFIG_DIR, 'project_rules');

  if (!fs.existsSync(skillsDir)) {
    return [];
  }

  return fs.readdirSync(skillsDir, { withFileTypes: true })
    .filter((item) => item.isDirectory())
    .map((item) => item.name);
}

async function initProject(projectPath, options = {}) {
  console.log('');
  log('========================================', 'info');
  log('  Trae Workflow Project Init', 'info');
  log('========================================', 'info');
  console.log('');

  const targetPath = projectPath || process.cwd();

  if (!fs.existsSync(targetPath)) {
    log(`Project path does not exist: ${targetPath}`, 'error');
    process.exit(1);
  }

  const availableTypes = getAvailableProjectTypes();

  if (availableTypes.length === 0) {
    log('No project types available', 'error');
    log('Run "traew install" first to install skills', 'gray');
    process.exit(1);
  }

  let projectType = options.type;

  if (!projectType) {
    log('Available project types:', 'warning');
    availableTypes.forEach((type, index) => {
      log(`  ${index + 1}. ${type}`, 'white');
    });
    console.log('');

    const readline = require('readline').createInterface({
      input: process.stdin,
      output: process.stdout,
    });

    const answer = await new Promise((resolve) => {
      readline.question('Select project type (1-' + availableTypes.length + '): ', resolve);
    });
    readline.close();

    const selection = parseInt(answer);
    if (isNaN(selection) || selection < 1 || selection > availableTypes.length) {
      log('Invalid selection', 'error');
      process.exit(1);
    }

    projectType = availableTypes[selection - 1];
  }

  if (!availableTypes.includes(projectType)) {
    log(`Invalid project type: ${projectType}`, 'error');
    log(`Available types: ${availableTypes.join(', ')}`, 'gray');
    process.exit(1);
  }

  const targetDir = path.join(targetPath, '.trae', 'rules');

  if (fs.existsSync(targetDir) && !options.force) {
    log('Project rules already exist', 'warning');
    log('Use --force to overwrite', 'gray');
    process.exit(1);
  }

  const sourceDir = path.join(TRAECONFIG_DIR, 'project_rules', projectType);

  if (!fs.existsSync(sourceDir)) {
    log(`Source directory not found: ${sourceDir}`, 'error');
    process.exit(1);
  }

  try {
    await fs.ensureDir(targetDir);
    await fs.copy(sourceDir, targetDir, { overwrite: options.force });

    const ruleCount = fs.readdirSync(targetDir).filter((f) => f.endsWith('.md')).length;

    log(`Project rules initialized: ${projectType}`, 'success');
    log(`Target: ${targetDir}`, 'gray');
    log(`Rules: ${ruleCount} file(s)`, 'gray');
  } catch (error) {
    log(`Failed to initialize project rules: ${error.message}`, 'error');
    process.exit(1);
  }
}

module.exports = { initProject };
