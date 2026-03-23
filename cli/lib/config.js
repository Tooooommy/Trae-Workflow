const fs = require('fs-extra');
const path = require('path');
const os = require('os');
const chalk = require('chalk');
const { execSync } = require('child_process');

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
      execSync(`explorer "${TRAECONFIG_DIR}"`);
    } else if (platform === 'darwin') {
      execSync(`open "${TRAECONFIG_DIR}"`);
    } else {
      execSync(`xdg-open "${TRAECONFIG_DIR}"`);
    }
    log('Opened config directory', 'success');
  } catch (error) {
    log(`Failed to open directory: ${error.message}`, 'error');
  }
}

function showConfigValue(key) {
  const configFiles = {
    mcp: 'mcp.json',
    tracking: 'tracking.json',
  };

  const fileName = configFiles[key];
  if (!fileName) {
    log(`Unknown config key: ${key}`, 'error');
    log('Available keys: mcp, tracking', 'gray');
    return;
  }

  const filePath = path.join(TRAECONFIG_DIR, fileName);

  if (!fs.existsSync(filePath)) {
    log(`Config file not found: ${fileName}`, 'error');
    return;
  }

  try {
    const content = fs.readJsonSync(filePath);
    console.log(JSON.stringify(content, null, 2));
  } catch (error) {
    log(`Failed to read config: ${error.message}`, 'error');
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

  if (options.show) {
    showConfigValue(options.show);
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
  log('  traew config --show <key>   Show specific config value', 'white');
  console.log('');
  log('Available config keys:', 'warning');
  log('  mcp       MCP servers configuration', 'gray');
  log('  tracking  Tracking configuration', 'gray');
  console.log('');
}

module.exports = { config, TRAECONFIG_DIR };
