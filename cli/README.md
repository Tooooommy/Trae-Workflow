# Trae Workflow CLI

Command-line interface for installing and managing Trae Workflow.

## Installation

### Option 1: Global Install (Recommended)

```bash
npm install -g trae-workflow-cli
```

### Option 2: Local Install

For development or testing, install locally:

```bash
# 1. Navigate to CLI directory
cd cli

# 2. Install dependencies
npm install

# 3. Link globally (recommended)
npm link

# 4. Verify installation
traew version
```

For detailed local installation guide, see [LOCAL_INSTALL.md](LOCAL_INSTALL.md)

## Usage

### Install Trae Workflow

```bash
# Install from default repository
traew install

# Install from specific repository
traew install username/repo

# Install with options
traew install --backup --skip-mcp --quiet
```

### Options

| Option                 | Description                    |
| ---------------------- | ------------------------------ |
| `-b, --backup`         | Backup existing config         |
| `--skip-mcp`           | Skip MCP config                |
| `--skip-skills`        | Skip Skills config             |
| `--skip-agents`        | Skip Agents config             |
| `--skip-rules`         | Skip Rules config              |
| `--skip-tracking`      | Skip Tracking config           |
| `--skip-project-rules` | Skip Project Rules config      |
| `-q, --quiet`          | Quiet mode                     |
| `-f, --force`          | Force execution                |
| `-p, --path <path>`    | Project path for Project Rules |
| `-t, --type <type>`    | Project type                   |

### Update CLI

```bash
traew update
```

### Check Version

```bash
traew version
```

## Development

```bash
# Install dependencies
npm install

# Run in development mode
node bin/trae.js install

# Link for testing
npm link
```

## License

MIT
