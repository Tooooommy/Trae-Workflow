const axios = require('axios');
const fs = require('fs-extra');
const path = require('path');
const tar = require('tar');
const https = require('https');
const { execSync } = require('child_process');
const chalk = require('chalk');
const ora = require('ora');

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

async function downloadFile(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https
      .get(url, (response) => {
        if (response.statusCode === 302 || response.statusCode === 301) {
          https
            .get(response.headers.location, (res) => {
              res.pipe(file);
              file.on('finish', () => {
                file.close();
                resolve();
              });
            })
            .on('error', reject);
        } else {
          response.pipe(file);
          file.on('finish', () => {
            file.close();
            resolve();
          });
        }
      })
      .on('error', reject);
  });
}

async function getLatestRelease(repo) {
  const spinner = getSpinner('Fetching latest release...');
  spinner.start();

  try {
    const response = await axios.get(`${GITHUB_API_BASE}/repos/${repo}/releases/latest`);
    spinner.stop();
    return response.data;
  } catch (error) {
    spinner.stop();
    throw new Error(`Failed to fetch release: ${error.message}`);
  }
}

async function downloadRelease(repo, version, dest) {
  const spinner = getSpinner(`Downloading ${repo} ${version}...`);
  spinner.start();

  try {
    const release = await getLatestRelease(repo);
    const tarballUrl = release.tarball_url;
    const tarballPath = path.join(dest, `${repo.replace('/', '-')}-${version}.tar.gz`);

    await downloadFile(tarballUrl, tarballPath);

    spinner.stop();
    log(`Downloaded ${repo} ${version}`, 'success');

    return tarballPath;
  } catch (error) {
    spinner.stop();
    throw error;
  }
}

async function extractTarball(tarballPath, dest) {
  const spinner = getSpinner('Extracting files...');
  spinner.start();

  try {
    await fs.ensureDir(dest);
    await tar.x({
      file: tarballPath,
      cwd: dest,
      strip: 1,
    });

    await fs.remove(tarballPath);

    spinner.stop();
    log('Extracted successfully', 'success');
  } catch (error) {
    spinner.stop();
    throw new Error(`Failed to extract: ${error.message}`);
  }
}

async function runSetupScript(setupPath, options) {
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

  log('Running setup script...', 'info');

  try {
    execSync(command, { stdio: 'inherit' });
    log('Setup completed successfully!', 'success');
  } catch (error) {
    throw new Error(`Setup script failed: ${error.message}`);
  }
}

async function install(repo, options) {
  const targetRepo = repo || DEFAULT_REPO;
  const tempDir = path.join(__dirname, '..', '.temp');

  try {
    log(`Installing Trae Workflow from ${targetRepo}`, 'info');

    const release = await getLatestRelease(targetRepo);
    const version = release.tag_name;

    log(`Latest version: ${version}`, 'info');

    const tarballPath = await downloadRelease(targetRepo, version, tempDir);
    await extractTarball(tarballPath, tempDir);

    const setupPath = path.join(tempDir, 'setup.ps1');

    if (!fs.existsSync(setupPath)) {
      throw new Error('setup.ps1 not found in downloaded package');
    }

    await runSetupScript(setupPath, options);

    await fs.remove(tempDir);

    log('Installation completed!', 'success');
  } catch (error) {
    log(`Installation failed: ${error.message}`, 'error');
    process.exit(1);
  }
}

module.exports = { install };
