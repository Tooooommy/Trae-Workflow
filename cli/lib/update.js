const axios = require('axios');
const chalk = require('chalk');
const ora = require('ora');

const GITHUB_API_BASE = 'https://api.github.com';
const DEFAULT_REPO = 'trae-cn/Trae-Workflow';

function log(message, level = 'info') {
  const colors = {
    info: chalk.cyan,
    success: chalk.green,
    warning: chalk.yellow,
    error: chalk.red
  };
  console.log(colors[level](message));
}

function getSpinner(text) {
  return ora({ text, color: 'cyan' });
}

async function getLatestRelease(repo) {
  const spinner = getSpinner('Checking for updates...');
  spinner.start();
  
  try {
    const response = await axios.get(`${GITHUB_API_BASE}/repos/${repo}/releases/latest`);
    spinner.stop();
    return response.data;
  } catch (error) {
    spinner.stop();
    throw new Error(`Failed to check for updates: ${error.message}`);
  }
}

async function update() {
  try {
    const release = await getLatestRelease(DEFAULT_REPO);
    const latestVersion = release.tag_name;
    const currentVersion = require('../package.json').version;
    
    log(`Current version: ${currentVersion}`, 'info');
    log(`Latest version: ${latestVersion}`, 'info');
    
    if (latestVersion === currentVersion) {
      log('You are already using the latest version', 'success');
      return;
    }
    
    log('New version available!', 'warning');
    log(`Run: trae install ${DEFAULT_REPO}`, 'info');
  } catch (error) {
    log(`Update check failed: ${error.message}`, 'error');
    process.exit(1);
  }
}

module.exports = { update };
