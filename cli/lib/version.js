const chalk = require('chalk');

function version() {
  const version = require('../package.json').version;
  console.log(chalk.cyan(`Trae Workflow CLI v${version}`));
  console.log(chalk.gray(`Command: traew`));
}

module.exports = { version };
