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

function getInstalledVersion() {
  const repoSourceDir = path.join(TRAECONFIG_DIR, '.repo');
  const packagePath = path.join(repoSourceDir, 'package.json');

  if (fs.existsSync(packagePath)) {
    try {
      const pkg = fs.readJsonSync(packagePath);
      return pkg.version || 'unknown';
    } catch {
      return 'unknown';
    }
  }

  return 'not installed';
}

function version() {
  const cliVersion = require('../package.json').version;
  const installedVersion = getInstalledVersion();
  const platform = os.platform();
  const arch = os.arch();

  console.log('');
  log('========================================', 'info');
  log('  Trae Workflow CLI', 'info');
  log('========================================', 'info');
  console.log('');
  log(`CLI Version:     v${cliVersion}`, 'white');
  log(`Installed:       ${installedVersion}`, 'white');
  log(`Platform:        ${platform} (${arch})`, 'white');
  log(`Config Dir:      ${TRAECONFIG_DIR}`, 'white');
  console.log('');
  log('Commands:', 'warning');
  log('  traew install [repo]   Install Trae Workflow', 'gray');
  log('  traew update           Update to latest version', 'gray');
  log('  traew status           Show installation status', 'gray');
  log('  traew config           Manage configuration', 'gray');
  log('  traew uninstall        Uninstall Trae Workflow', 'gray');
  log('  traew version          Show version info', 'gray');
  console.log('');
  log('Options:', 'warning');
  log('  -h, --help             Show help for command', 'gray');
  log('  -V, --version          Show CLI version', 'gray');
  console.log('');
}

module.exports = { version };
