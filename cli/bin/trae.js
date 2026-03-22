#!/usr/bin/env node

const path = require('path');
const { program } = require('commander');
const { install } = require('../lib/install');
const { update } = require('../lib/update');
const { version } = require('../lib/version');

program
  .name('traew')
  .description('Trae Workflow CLI - Install and manage Trae Workflow')
  .version(require('../package.json').version);

program
  .command('install [repo]')
  .description('Install Trae Workflow from GitHub repository')
  .option('-b, --backup', 'Backup existing config')
  .option('--skip-mcp', 'Skip MCP config')
  .option('--skip-skills', 'Skip Skills config')
  .option('--skip-agents', 'Skip Agents config')
  .option('--skip-rules', 'Skip Rules config')
  .option('--skip-tracking', 'Skip Tracking config')
  .option('--skip-project-rules', 'Skip Project Rules config')
  .option('-q, --quiet', 'Quiet mode')
  .option('-f, --force', 'Force execution')
  .option('-p, --path <path>', 'Project path for Project Rules')
  .option('-t, --type <type>', 'Project type')
  .action((repo, options) => {
    install(repo, options);
  });

program
  .command('update')
  .description('Update Trae Workflow to latest version')
  .action(() => {
    update();
  });

program
  .command('version')
  .description('Show current version')
  .action(() => {
    version();
  });

program.parse(process.argv);
