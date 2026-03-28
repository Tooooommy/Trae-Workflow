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

function listConfigFiles() {
  console.log('');
  log('Config files:', 'warning');
  console.log('');

  if (!fs.existsSync(TRAECONFIG_DIR)) {
    log('Config directory does not exist', 'error');
    return;
  }

  const items = fs.readdirSync(TRAECONFIG_DIR, { withFileTypes: true });

  items.forEach((item) => {
    const itemPath = path.join(TRAECONFIG_DIR, item.name);
    const stats = fs.statSync(itemPath);

    if (item.isDirectory()) {
      const subItems = fs.readdirSync(itemPath);
      log(`  📁 ${item.name}/ (${subItems.length} items)`, 'white');
    } else {
      const size = (stats.size / 1024).toFixed(2);
      log(`  📄 ${item.name} (${size} KB)`, 'white');
    }
  });

  console.log('');
}

function showConfigPath() {
  log(TRAECONFIG_DIR, 'white');
}

function openConfigDirectory() {
  if (!fs.existsSync(TRAECONFIG_DIR)) {
    log('Config directory does not exist', 'error');
    return;
  }

  const platform = os.platform();

  try {
    if (platform === 'win32') {
      const { execSync } = require('child_process');
      execSync(`explorer "${TRAECONFIG_DIR}"`);
    } else if (platform === 'darwin') {
      const { execSync } = require('child_process');
      execSync(`open "${TRAECONFIG_DIR}"`);
    } else {
      const { execSync } = require('child_process');
      execSync(`xdg-open "${TRAECONFIG_DIR}"`);
    }
    log('Opened config directory', 'success');
  } catch (error) {
    log(`Failed to open directory: ${error.message}`, 'error');
  }
}

function config(options) {
  if (options.path) {
    showConfigPath();
    return;
  }

  if (options.edit) {
    openConfigDirectory();
    return;
  }

  if (options.list) {
    listConfigFiles();
    return;
  }

  console.log('');
  log('========================================', 'info');
  log('  Trae Workflow Config', 'info');
  log('========================================', 'info');
  console.log('');
  log(`Config directory: ${TRAECONFIG_DIR}`, 'gray');
  console.log('');
  log('Usage:', 'warning');
  log('  traew config --list         List all config files', 'white');
  log('  traew config --path         Show config directory path', 'white');
  log('  traew config --edit         Open config directory', 'white');
  console.log('');
}

module.exports = { config, TRAECONFIG_DIR };
