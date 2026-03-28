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

function getConfigStatus() {
  const config = {
    installed: false,
    skills: 0,
    userRules: false,
    backups: 0,
  };

  if (!fs.existsSync(TRAECONFIG_DIR)) {
    return config;
  }

  config.installed = true;

  const skillsDir = path.join(TRAECONFIG_DIR, 'skills');
  if (fs.existsSync(skillsDir)) {
    const items = fs.readdirSync(skillsDir, { withFileTypes: true });
    config.skills = items.filter((item) => item.isDirectory()).length;
  }

  const rulesDir = path.join(TRAECONFIG_DIR, 'user_rules');
  config.userRules = fs.existsSync(rulesDir) && fs.readdirSync(rulesDir).length > 0;

  const backups = fs.readdirSync(TRAECONFIG_DIR).filter((item) => item.startsWith('backup_'));
  config.backups = backups.length;

  return config;
}

function status() {
  console.log('');
  log('========================================', 'info');
  log('  Trae Workflow Status', 'info');
  log('========================================', 'info');
  console.log('');

  const config = getConfigStatus();

  if (!config.installed) {
    log('Trae Workflow is not installed', 'warning');
    log('Run "traew install" to install', 'gray');
    return;
  }

  log(`Config directory: ${TRAECONFIG_DIR}`, 'gray');
  console.log('');

  log('Components:', 'warning');

  const skillsStatus = config.skills > 0 ? `✓ ${config.skills} skills` : '✗ No skills';
  const skillsColor = config.skills > 0 ? 'success' : 'error';
  log(`  Skills: ${skillsStatus}`, skillsColor);

  const rulesStatus = config.userRules ? '✓ Configured' : '✗ Not configured';
  const rulesColor = config.userRules ? 'success' : 'error';
  log(`  User Rules: ${rulesStatus}`, rulesColor);

  console.log('');

  if (config.backups > 0) {
    log(`Backups: ${config.backups} backup(s) found`, 'gray');
  }

  console.log('');
  log('Directory structure:', 'warning');
  log('  ~/.trae-cn/', 'gray');
  log('  ├── skills/           (Skills directory)', 'gray');
  log('  └── user_rules/       (User rules directory)', 'gray');
  console.log('');
}

module.exports = { status, getConfigStatus, TRAECONFIG_DIR };
