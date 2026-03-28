#!/usr/bin/env node

const path = require('path');
const { program } = require('commander');
const { install } = require('../lib/install');
const { update } = require('../lib/update');
const { version } = require('../lib/version');
const { status } = require('../lib/status');
const { config } = require('../lib/config');
const { uninstall } = require('../lib/uninstall');
const pkg = require('../package.json');

program
  .name('traew')
  .description('Trae Workflow CLI - Install and manage Trae Workflow')
  .version(pkg.version);

program
  .command('install [repo]')
  .description('Install Trae Workflow from GitHub repository')
  .option('-b, --backup', 'Backup existing config')
  .option('--skip-skills', 'Skip Skills config')
  .option('--skip-rules', 'Skip Rules config')
  .option('-q, --quiet', 'Quiet mode')
  .option('-f, --force', 'Force execution')
  .option('-l, --local <dir>', 'Install from local directory')
  .action((repo, options) => {
    install(repo, options);
  });

program
  .command('update')
  .description('Update Trae Workflow to latest version')
  .option('-f, --force', 'Force update without confirmation')
  .option('-b, --backup', 'Backup existing config before update')
  .action((options) => {
    update(options);
  });

program
  .command('version')
  .description('Show current version')
  .action(() => {
    version();
  });

program
  .command('status')
  .description('Show installation status and config info')
  .action(() => {
    status();
  });

program
  .command('config')
  .description('Manage configuration')
  .option('-l, --list', 'List all config files')
  .option('-e, --edit', 'Open config directory in file manager')
  .option('--path', 'Show config directory path')
  .action((options) => {
    config(options);
  });

program
  .command('uninstall')
  .description('Uninstall Trae Workflow')
  .option('-b, --backup', 'Create backup before uninstall')
  .option('-f, --force', 'Force uninstall without confirmation')
  .action((options) => {
    uninstall(options);
  });

program.parse(process.argv);
