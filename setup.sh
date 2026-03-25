#!/bin/bash

# Trae Workflow Setup Script (Linux/macOS)
# Version: 2.1.0

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
WHITE='\033[1;37m'
NC='\033[0m'

# Config
TRAECONFIG_DIR="$HOME/.trae-cn"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/setup-$(date +%Y%m%d_%H%M%S).log"
VERSION="2.1.0"
BACKUP=false
SKIP_MCP=false
SKIP_SKILLS=false
SKIP_AGENTS=false
SKIP_RULES=false
SKIP_TRACKING=false
SKIP_PROJECT_RULES=false
QUIET=false
FORCE=false
PROJECT_PATH=""
PROJECT_TYPE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backup)
            BACKUP=true
            shift
            ;;
        --skip-mcp)
            SKIP_MCP=true
            shift
            ;;
        --skip-skills)
            SKIP_SKILLS=true
            shift
            ;;
        --skip-agents)
            SKIP_AGENTS=true
            shift
            ;;
        --skip-rules)
            SKIP_RULES=true
            shift
            ;;
        --skip-tracking)
            SKIP_TRACKING=true
            shift
            ;;
        --skip-project-rules)
            SKIP_PROJECT_RULES=true
            shift
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --project-path)
            PROJECT_PATH="$2"
            shift 2
            ;;
        --project-type)
            PROJECT_TYPE="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for help"
            exit 1
            ;;
    esac
done

# Logging functions
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

print_info() {
    echo -e "${CYAN}$1${NC}"
    log "INFO" "$1"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
    log "INFO" "$1"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
    log "WARN" "$1"
}

print_error() {
    echo -e "${RED}$1${NC}"
    log "ERROR" "$1"
}

print_gray() {
    echo -e "${GRAY}$1${NC}"
    log "INFO" "$1"
}

print_white() {
    echo -e "${WHITE}$1${NC}"
    log "INFO" "$1"
}

# Show help
show_help() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Trae Workflow Setup Script v${VERSION}${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "${WHITE}Usage: ./setup.sh [options]${NC}"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo -e "${WHITE}  --backup                Backup existing config${NC}"
    echo -e "${WHITE}  --skip-mcp              Skip MCP config${NC}"
    echo -e "${WHITE}  --skip-skills           Skip Skills config${NC}"
    echo -e "${WHITE}  --skip-agents           Skip Agents config${NC}"
    echo -e "${WHITE}  --skip-rules            Skip Rules config${NC}"
    echo -e "${WHITE}  --skip-tracking         Skip Tracking config${NC}"
    echo -e "${WHITE}  --skip-project-rules    Skip Project Rules config${NC}"
    echo -e "${WHITE}  --quiet                 Quiet mode${NC}"
    echo -e "${WHITE}  --force                 Force execution${NC}"
    echo -e "${WHITE}  --project-path <path>   Project path for Project Rules${NC}"
    echo -e "${WHITE}  --project-type <type>   Project type${NC}"
    echo -e "${WHITE}  --help                  Show this help${NC}"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "${GRAY}  ./setup.sh${NC}"
    echo -e "${GRAY}  ./setup.sh --backup${NC}"
    echo -e "${GRAY}  ./setup.sh --project-path ~/myproject --project-type typescript${NC}"
    echo ""
    echo -e "${YELLOW}Supported project types:${NC}"
    echo -e "${GRAY}  typescript, python, java, golang, rust, kotlin, swift${NC}"
    echo ""
}

# Check if Trae IDE is running
check_trae_running() {
    if pgrep -f "trae" > /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Validate config file
test_config_file() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        return 1
    fi
    
    if [[ ! -s "$file_path" ]]; then
        return 1
    fi
    
    return 0
}

# Get available project types
get_available_project_types() {
    local project_rules_dir="$SCRIPT_DIR/project_rules"
    
    if [[ ! -d "$project_rules_dir" ]]; then
        echo ""
        return
    fi
    
    find "$project_rules_dir" -maxdepth 1 -type d -not -path "$project_rules_dir" -exec basename {} \; | sort | tr '\n' ' ' | sed 's/ $//'
}

# Initialize project rules
initialize_project_rules() {
    local project_path="$1"
    local project_type="$2"
    
    if [[ -z "$project_path" ]]; then
        print_warning "Project path not specified, skipping Project Rules"
        return 1
    fi
    
    if [[ ! -d "$project_path" ]]; then
        print_error "Project path does not exist: $project_path"
        return 1
    fi
    
    local available_types
    available_types=$(get_available_project_types)
    
    if [[ -z "$project_type" ]]; then
        if [[ -z "$available_types" ]]; then
            print_warning "No available Project Rules found"
            return 1
        fi
        
        print_info "Available project types:"
        local i=1
        for type in $available_types; do
            echo -e "${WHITE}  $i. $type${NC}"
            ((i++))
        done
        
        read -p "Select project type (1-$((i-1))): " selection
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -lt "$i" ]]; then
            project_type=$(echo "$available_types" | awk -v sel="$selection" '{print $sel}')
        else
            print_error "Invalid selection"
            return 1
        fi
    fi
    
    local source_dir="$SCRIPT_DIR/project_rules/$project_type"
    if [[ ! -d "$source_dir" ]]; then
        print_error "Project type '$project_type' rules not found"
        print_gray "Available types: $available_types"
        return 1
    fi
    
    local target_dir="$project_path/.trae/rules"
    
    if mkdir -p "$target_dir" && cp -r "$source_dir/"* "$target_dir/"; then
        local rule_count
        rule_count=$(find "$target_dir" -maxdepth 1 -type f | wc -l)
        print_success "      OK Copied $rule_count rules to $target_dir"
        log "INFO" "Project Rules initialized: $project_type -> $target_dir"
        return 0
    else
        print_error "      ERROR Project Rules initialization failed"
        log "ERROR" "Project Rules initialization failed"
        return 1
    fi
}

# Main program
main() {
    log "INFO" "Setup script started (Version: $VERSION)"
    
    if [[ "$QUIET" == false ]]; then
        print_info "========================================"
        print_info "  Trae Workflow Setup Script"
        print_info "  Version: $VERSION"
        print_info "========================================"
        echo ""
    fi

    # Check if in project directory
    if [[ ! -f "$SCRIPT_DIR/mcp.json" ]]; then
        print_error "Please run this script in the Trae Workflow directory"
        exit 1
    fi

    # Check if Trae IDE is running
    if check_trae_running; then
        print_warning "Trae IDE is running"
        print_warning "Please close Trae IDE before running this script"
        if [[ "$FORCE" == false ]]; then
            read -p "Continue? (Y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "WARN" "User cancelled"
                exit 0
            fi
        fi
    fi

    # Calculate total steps
    total_steps=6
    [[ "$SKIP_MCP" == false ]] && ((total_steps++))
    [[ "$SKIP_SKILLS" == false ]] && ((total_steps++))
    [[ "$SKIP_AGENTS" == false ]] && ((total_steps++))
    [[ "$SKIP_RULES" == false ]] && ((total_steps++))
    [[ "$SKIP_PROJECT_RULES" == false ]] && ((total_steps++))
    [[ "$SKIP_TRACKING" == false ]] && ((total_steps++))

    current_step=0

    # Progress function
    show_progress() {
        ((current_step++))
        print_info "[$current_step/$total_steps] $1"
    }

    # Create config directory
    show_progress "Creating config directory..."
    if mkdir -p "$TRAECONFIG_DIR"; then
        print_success "      OK Config directory: $TRAECONFIG_DIR"
        log "INFO" "Config directory created: $TRAECONFIG_DIR"
    else
        print_error "      ERROR Failed to create config directory"
        log "ERROR" "Failed to create config directory"
        exit 1
    fi

    # Backup existing config
    if [[ "$BACKUP" == true ]] || [[ -f "$TRAECONFIG_DIR/mcp.json" ]]; then
        show_progress "Backing up existing config..."
        backup_dir="$TRAECONFIG_DIR/backup_$(date +%Y%m%d_%H%M%S)"
        
        if mkdir -p "$backup_dir"; then
            [[ -f "$TRAECONFIG_DIR/mcp.json" ]] && cp "$TRAECONFIG_DIR/mcp.json" "$backup_dir/"
            [[ -d "$TRAECONFIG_DIR/skills" ]] && cp -r "$TRAECONFIG_DIR/skills" "$backup_dir/"
            [[ -d "$TRAECONFIG_DIR/agents" ]] && cp -r "$TRAECONFIG_DIR/agents" "$backup_dir/"
            [[ -d "$TRAECONFIG_DIR/user_rules" ]] && cp -r "$TRAECONFIG_DIR/user_rules" "$backup_dir/"
            [[ -d "$TRAECONFIG_DIR/project_rules" ]] && cp -r "$TRAECONFIG_DIR/project_rules" "$backup_dir/"
            [[ -f "$TRAECONFIG_DIR/tracking.json" ]] && cp "$TRAECONFIG_DIR/tracking.json" "$backup_dir/"
            
            print_success "      OK Backup completed: $backup_dir"
            log "INFO" "Backup completed: $backup_dir"
        else
            print_error "      ERROR Backup failed"
            log "ERROR" "Backup failed"
            exit 1
        fi
    else
        show_progress "Skipping backup..."
        print_gray "      Skipped backup"
    fi

    # Configure MCP
    if [[ "$SKIP_MCP" == false ]]; then
        show_progress "Configuring MCP servers..."
        if test_config_file "$SCRIPT_DIR/mcp.json"; then
            if cp "$SCRIPT_DIR/mcp.json" "$TRAECONFIG_DIR/mcp.json"; then
                print_success "      OK MCP config copied"
                log "INFO" "MCP config copied"
            else
                print_error "      ERROR MCP config copy failed"
                log "ERROR" "MCP config copy failed"
                exit 1
            fi
        else
            print_error "      ERROR MCP config file is invalid or empty"
            log "ERROR" "MCP config file validation failed"
            exit 1
        fi
    else
        show_progress "Skipping MCP config..."
        print_gray "      Skipped MCP config"
    fi

    # Configure Skills
    if [[ "$SKIP_SKILLS" == false ]]; then
        show_progress "Configuring Skills..."
        skills_dir="$TRAECONFIG_DIR/skills"
        
        if mkdir -p "$skills_dir" && cp -r "$SCRIPT_DIR/skills/"* "$skills_dir/"; then
            skill_count=$(find "$skills_dir" -maxdepth 1 -type d | wc -l)
            skill_count=$((skill_count - 1))
            print_success "      OK Copied $skill_count skills"
            log "INFO" "Skills copied: $skill_count"
        else
            print_error "      ERROR Skills config failed"
            log "ERROR" "Skills config failed"
            exit 1
        fi
    else
        show_progress "Skipping Skills config..."
        print_gray "      Skipped Skills config"
    fi

    # Configure Agents
    if [[ "$SKIP_AGENTS" == false ]]; then
        show_progress "Configuring Agents..."
        agents_dir="$TRAECONFIG_DIR/agents"
        
        if mkdir -p "$agents_dir" && cp -r "$SCRIPT_DIR/agents/"* "$agents_dir/"; then
            agent_count=$(find "$agents_dir" -maxdepth 1 -type f -name "*.md" | wc -l)
            print_success "      OK Copied $agent_count agents"
            log "INFO" "Agents copied: $agent_count"
        else
            print_error "      ERROR Agents config failed"
            log "ERROR" "Agents config failed"
            exit 1
        fi
    else
        show_progress "Skipping Agents config..."
        print_gray "      Skipped Agents config"
    fi

    # Configure Rules
    if [[ "$SKIP_RULES" == false ]]; then
        show_progress "Configuring User Rules..."
        rules_dir="$TRAECONFIG_DIR/user_rules"
        
        if mkdir -p "$rules_dir" && cp -r "$SCRIPT_DIR/user_rules/"* "$rules_dir/"; then
            print_success "      OK User Rules copied"
            log "INFO" "User Rules copied"
        else
            print_error "      ERROR User Rules config failed"
            log "ERROR" "User Rules config failed"
            exit 1
        fi
    else
        show_progress "Skipping Rules config..."
        print_gray "      Skipped Rules config"
    fi

    # Configure Project Rules
    if [[ "$SKIP_PROJECT_RULES" == false ]]; then
        show_progress "Configuring Project Rules..."
        project_rules_dir="$TRAECONFIG_DIR/project_rules"
        
        if mkdir -p "$project_rules_dir" && cp -r "$SCRIPT_DIR/project_rules/"* "$project_rules_dir/"; then
            local count
            count=$(find "$project_rules_dir" -maxdepth 1 -type d -not -path "$project_rules_dir" | wc -l)
            print_success "      OK Copied $count project rules"
            log "INFO" "Project Rules copied: $count"
        else
            print_error "      ERROR Project Rules config failed"
            log "ERROR" "Project Rules config failed"
            exit 1
        fi
    else
        show_progress "Skipping Project Rules config..."
        print_gray "      Skipped Project Rules config"
    fi

    # Configure Tracking
    if [[ "$SKIP_TRACKING" == false ]]; then
        show_progress "Configuring Tracking..."
        if test_config_file "$SCRIPT_DIR/tracking.json"; then
            if cp "$SCRIPT_DIR/tracking.json" "$TRAECONFIG_DIR/tracking.json"; then
                print_success "      OK Tracking config copied"
                log "INFO" "Tracking config copied"
            else
                print_error "      ERROR Tracking config failed"
                log "ERROR" "Tracking config failed"
                exit 1
            fi
        else
            print_warning "      WARN Tracking config file is invalid, skipping"
            log "WARN" "Tracking config file validation failed, skipped"
        fi
    else
        show_progress "Skipping Tracking config..."
        print_gray "      Skipped Tracking config"
    fi

    # Initialize Project Rules
    if [[ "$SKIP_PROJECT_RULES" == false ]] && [[ -n "$PROJECT_PATH" ]]; then
        show_progress "Initializing Project Rules..."
        initialize_project_rules "$PROJECT_PATH" "$PROJECT_TYPE"
    fi

    # Show completion info
    if [[ "$QUIET" == false ]]; then
        echo ""
        print_info "========================================"
        print_success "  Setup Complete!"
        print_info "========================================"
        echo ""
        print_warning "Please restart Trae IDE to apply changes"
        echo ""
        print_gray "Config location: $TRAECONFIG_DIR"
        echo ""
        print_info "Directory structure:"
        print_gray "  $TRAECONFIG_DIR/"
        print_gray "  ├── mcp.json          (MCP servers config)"
        print_gray "  ├── skills/           (Skills directory)"
        print_gray "  ├── agents/           (Agents directory)"
        print_gray "  ├── user_rules/       (User rules directory)"
        print_gray "  ├── project_rules/    (Project rules directory)"
        print_gray "  └── tracking.json     (Tracking config)"
        echo ""
        print_info "Project Rules usage:"
        print_gray "  Project Rules should be copied to project directory:"
        print_warning "  <project_root>/.trae/rules/"
        echo ""
        print_gray "  Method 1: Use script to initialize"
        print_gray "    ./setup.sh --project-path ~/myproject --project-type typescript"
        echo ""
        print_gray "  Method 2: Manual copy"
        print_gray "    cp -r '$SCRIPT_DIR/project_rules/typescript/*' './.trae/rules/'"
        echo ""
        print_gray "  Supported types: $(get_available_project_types)"
        echo ""
        print_gray "Environment variables (optional):"
        print_gray "  export GITHUB_PAT='your_token'"
        print_gray "  export EXA_API_KEY='your_key'"
        echo ""
    fi

    # Show summary
    if [[ "$QUIET" == false ]]; then
        print_info "Summary:"
        [[ "$SKIP_MCP" == false ]] && echo -e "${WHITE}  - MCP servers: Configured${NC}" || echo -e "${WHITE}  - MCP servers: Skipped${NC}"
        [[ "$SKIP_SKILLS" == false ]] && echo -e "${WHITE}  - Skills: Configured${NC}" || echo -e "${WHITE}  - Skills: Skipped${NC}"
        [[ "$SKIP_AGENTS" == false ]] && echo -e "${WHITE}  - Agents: Configured${NC}" || echo -e "${WHITE}  - Agents: Skipped${NC}"
        [[ "$SKIP_RULES" == false ]] && echo -e "${WHITE}  - User Rules: Configured${NC}" || echo -e "${WHITE}  - User Rules: Skipped${NC}"
        [[ "$SKIP_PROJECT_RULES" == false ]] && echo -e "${WHITE}  - Project Rules: Configured${NC}" || echo -e "${WHITE}  - Project Rules: Skipped${NC}"
        [[ "$SKIP_TRACKING" == false ]] && echo -e "${WHITE}  - Tracking: Configured${NC}" || echo -e "${WHITE}  - Tracking: Skipped${NC}"
        echo ""
    fi

    # Validate config
    if [[ "$QUIET" == false ]]; then
        print_info "Validating config..."
        issues=()
        
        [[ "$SKIP_MCP" == false ]] && [[ ! -f "$TRAECONFIG_DIR/mcp.json" ]] && issues+=("MCP config not found")
        [[ "$SKIP_MCP" == false ]] && [[ ! -s "$TRAECONFIG_DIR/mcp.json" ]] && issues+=("MCP config invalid or empty")
        [[ "$SKIP_SKILLS" == false ]] && [[ ! -d "$TRAECONFIG_DIR/skills" ]] && issues+=("Skills directory not found")
        [[ "$SKIP_AGENTS" == false ]] && [[ ! -d "$TRAECONFIG_DIR/agents" ]] && issues+=("Agents directory not found")
        [[ "$SKIP_RULES" == false ]] && [[ ! -d "$TRAECONFIG_DIR/user_rules" ]] && issues+=("User Rules directory not found")
        
        if [[ ${#issues[@]} -eq 0 ]]; then
            print_success "  OK All configurations validated"
            log "INFO" "Config validation passed"
        else
            print_warning "  WARN Issues found:"
            for issue in "${issues[@]}"; do
                print_error "    - $issue"
                log "WARN" "Validation issue: $issue"
            done
        fi
        
        echo ""
        print_gray "Log file: $LOG_FILE"
        echo ""
        read -p "Press Enter to exit"
    fi

    log "INFO" "Setup script completed"
}

# Run main program
main "$@"
