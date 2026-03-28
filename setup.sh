#!/bin/bash

# Trae Workflow Setup Script (Linux/macOS)
# Version: 3.1.0

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
VERSION="3.1.0"
BACKUP=false
SKIP_SKILLS=false
SKIP_RULES=false
QUIET=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --backup)
            BACKUP=true
            shift
            ;;
        --skip-skills)
            SKIP_SKILLS=true
            shift
            ;;
        --skip-rules)
            SKIP_RULES=true
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
    echo -e "${WHITE}  --backup         Backup existing config${NC}"
    echo -e "${WHITE}  --skip-skills    Skip Skills config${NC}"
    echo -e "${WHITE}  --skip-rules     Skip Rules config${NC}"
    echo -e "${WHITE}  --quiet          Quiet mode${NC}"
    echo -e "${WHITE}  --force          Force execution${NC}"
    echo -e "${WHITE}  --help           Show this help${NC}"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo -e "${GRAY}  ./setup.sh${NC}"
    echo -e "${GRAY}  ./setup.sh --backup${NC}"
    echo ""
}

# Check if Trae IDE is running
check_trae_running() {
    if pgrep -f "trae" > /dev/null 2>&1; then
        return 0
    fi
    return 1
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
    total_steps=2
    [[ "$SKIP_SKILLS" == false ]] && ((total_steps++))
    [[ "$SKIP_RULES" == false ]] && ((total_steps++))

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
    if [[ "$BACKUP" == true ]] || [[ -d "$TRAECONFIG_DIR/skills" ]]; then
        show_progress "Backing up existing config..."
        backup_dir="$TRAECONFIG_DIR/backup_$(date +%Y%m%d_%H%M%S)"
        
        if mkdir -p "$backup_dir"; then
            [[ -d "$TRAECONFIG_DIR/skills" ]] && cp -r "$TRAECONFIG_DIR/skills" "$backup_dir/"
            [[ -d "$TRAECONFIG_DIR/user_rules" ]] && cp -r "$TRAECONFIG_DIR/user_rules" "$backup_dir/"
            
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
        print_gray "  ├── skills/           (Skills directory)"
        print_gray "  └── user_rules/       (User rules directory)"
        echo ""
    fi

    # Show summary
    if [[ "$QUIET" == false ]]; then
        print_info "Summary:"
        [[ "$SKIP_SKILLS" == false ]] && echo -e "${WHITE}  - Skills: Configured${NC}" || echo -e "${WHITE}  - Skills: Skipped${NC}"
        [[ "$SKIP_RULES" == false ]] && echo -e "${WHITE}  - User Rules: Configured${NC}" || echo -e "${WHITE}  - User Rules: Skipped${NC}"
        echo ""
    fi

    # Validate config
    if [[ "$QUIET" == false ]]; then
        print_info "Validating config..."
        issues=()
        
        [[ "$SKIP_SKILLS" == false ]] && [[ ! -d "$TRAECONFIG_DIR/skills" ]] && issues+=("Skills directory not found")
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
