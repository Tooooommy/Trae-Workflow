const fs = require('fs-extra');
const path = require('path');
const os = require('os');
const chalk = require('chalk');
const readline = require('readline');

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

async function prompt(question) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer);
    });
  });
}

async function uninstall(options = {}) {
  console.log('');
  log('========================================', 'info');
  log('  Trae Workflow Uninstall', 'info');
  log('========================================', 'info');
  console.log('');

  if (!fs.existsSync(TRAECONFIG_DIR)) {
    log('Trae Workflow is not installed', 'warning');
    return;
  }

  if (!options.force) {
    log('This will remove all Trae Workflow configuration files:', 'warning');
    log(`  ${TRAECONFIG_DIR}`, 'gray');
    console.log('');

    const answer = await prompt('Are you sure you want to uninstall? (y/N) ');
    if (answer.toLowerCase() !== 'y') {
      log('Uninstall cancelled', 'warning');
      return;
    }
  }

  try {
    if (options.backup) {
      const backupDir = `${TRAECONFIG_DIR}_backup_${Date.now()}`;
      log(`Creating backup: ${backupDir}`, 'info');
      await fs.copy(TRAECONFIG_DIR, backupDir);
      log('Backup created', 'success');
    }

    log('Removing configuration files...', 'info');
    await fs.remove(TRAECONFIG_DIR);

    log('Uninstall completed!', 'success');
    log('Please restart Trae IDE to apply changes', 'gray');
  } catch (error) {
    log(`Uninstall failed: ${error.message}`, 'error');
    process.exit(1);
  }
}

module.exports = { uninstall };
