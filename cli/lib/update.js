const axios = require('axios');
const fs = require('fs-extra');
const path = require('path');
const chalk = require('chalk');
const ora = require('ora');
const { install } = require('./install');

const GITHUB_API_BASE = 'https://api.github.com';
const DEFAULT_REPO = 'trae-cn/Trae-Workflow';

function log(message, level = 'info') {
  const colors = {
    info: chalk.cyan,
    success: chalk.green,
    warning: chalk.yellow,
    error: chalk.red,
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

function compareVersions(v1, v2) {
  const normalize = (v) => v.replace(/^v/, '').split('.').map(Number);
  const parts1 = normalize(v1);
  const parts2 = normalize(v2);

  for (let i = 0; i < Math.max(parts1.length, parts2.length); i++) {
    const p1 = parts1[i] || 0;
    const p2 = parts2[i] || 0;
    if (p1 > p2) return 1;
    if (p1 < p2) return -1;
  }
  return 0;
}

async function update(options = {}) {
  try {
    const release = await getLatestRelease(DEFAULT_REPO);
    const latestVersion = release.tag_name;
    const currentVersion = require('../package.json').version;

    log(`Current version: ${currentVersion}`, 'info');
    log(`Latest version: ${latestVersion}`, 'info');

    if (compareVersions(latestVersion, `v${currentVersion}`) <= 0) {
      log('You are already using the latest version', 'success');
      return;
    }

    log('New version available!', 'warning');

    if (!options.force) {
      const readline = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout,
      });

      const answer = await new Promise((resolve) => {
        readline.question('Do you want to update? (y/N) ', resolve);
      });
      readline.close();

      if (answer.toLowerCase() !== 'y') {
        log('Update cancelled', 'warning');
        return;
      }
    }

    log('Starting update...', 'info');

    await install(DEFAULT_REPO, {
      backup: options.backup,
      force: true,
    });

    log('Update completed!', 'success');
  } catch (error) {
    log(`Update failed: ${error.message}`, 'error');
    process.exit(1);
  }
}

module.exports = { update, compareVersions };
