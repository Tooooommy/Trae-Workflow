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

# Install from local directory
traew install --local ./Trae-Workflow

# Install with options
traew install --backup --skip-mcp --quiet

# Install with project rules
traew install --path ~/myproject --type typescript
```

### Install Options

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
| `-l, --local <dir>`    | Install from local directory   |

### Update Trae Workflow

```bash
# Check and update to latest version
traew update

# Force update without confirmation
traew update --force

# Backup before update
traew update --backup
```

### Check Status

```bash
# Show installation status and config info
traew status
```

### Manage Configuration

```bash
# List all config files
traew config --list

# Show config directory path
traew config --path

# Open config directory in file manager
traew config --edit

# Show specific config value
traew config --show mcp
traew config --show tracking
```

### Initialize Project Rules

```bash
# Initialize in current directory
traew init

# Initialize in specific project
traew init ~/myproject

# Initialize with specific type
traew init --type typescript

# Force overwrite existing rules
traew init --force
```

### Uninstall

```bash
# Uninstall with confirmation
traew uninstall

# Force uninstall without confirmation
traew uninstall --force

# Create backup before uninstall
traew uninstall --backup
```

### Check Version

```bash
traew version
```

## Supported Project Types

- typescript
- python
- java
- golang
- rust
- kotlin
- swift

## Platform Support

| Platform | Setup Script |
| -------- | ------------ |
| Windows  | setup.ps1    |
| macOS    | setup.sh     |
| Linux    | setup.sh     |

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
