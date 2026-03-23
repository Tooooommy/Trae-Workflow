# Trae Workflow Setup Script
# Version: 2.1.0

param(
    [switch]$Backup,
    [switch]$SkipMCP,
    [switch]$SkipSkills,
    [switch]$SkipAgents,
    [switch]$SkipRules,
    [switch]$SkipTracking,
    [switch]$SkipProjectRules,
    [switch]$Quiet,
    [switch]$Force,
    [string]$ProjectPath,
    [string]$ProjectType,
    [switch]$Help
)

$ErrorActionPreference = "Continue"
$TraeConfigDir = "$env:USERPROFILE\.trae-cn"
$ScriptDir = $PSScriptRoot
$LogFile = "$ScriptDir\setup-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Version = "2.1.0"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage -Encoding UTF8
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
    Write-Log -Message $Message -Level "INFO"
}

function Write-Warning {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
    Write-Log -Message $Message -Level "WARN"
}

function Write-Error {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
    Write-Log -Message $Message -Level "ERROR"
}

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
    Write-Log -Message $Message -Level "INFO"
}

function Write-Gray {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Gray
    Write-Log -Message $Message -Level "INFO"
}

function Write-White {
    param([string]$Message)
    Write-Host $Message -ForegroundColor White
    Write-Log -Message $Message -Level "INFO"
}

function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Trae Workflow Setup Script v$Version" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\setup.ps1 [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Backup              Backup existing config" -ForegroundColor White
    Write-Host "  -SkipMCP             Skip MCP config" -ForegroundColor White
    Write-Host "  -SkipSkills          Skip Skills config" -ForegroundColor White
    Write-Host "  -SkipAgents          Skip Agents config" -ForegroundColor White
    Write-Host "  -SkipRules           Skip Rules config" -ForegroundColor White
    Write-Host "  -SkipTracking        Skip Tracking config" -ForegroundColor White
    Write-Host "  -SkipProjectRules    Skip Project Rules config" -ForegroundColor White
    Write-Host "  -Quiet               Quiet mode" -ForegroundColor White
    Write-Host "  -Force               Force execution" -ForegroundColor White
    Write-Host "  -ProjectPath path    Project path for Project Rules" -ForegroundColor White
    Write-Host "  -ProjectType type    Project type" -ForegroundColor White
    Write-Host "  -Help                Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\setup.ps1" -ForegroundColor Gray
    Write-Host "  .\setup.ps1 -Backup" -ForegroundColor Gray
    Write-Host "  .\setup.ps1 -ProjectPath 'C:\myproject' -ProjectType typescript" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Supported project types:" -ForegroundColor Yellow
    Write-Host "  typescript, python, java, golang, rust, kotlin, swift" -ForegroundColor Gray
    Write-Host ""
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-TraeRunning {
    $processes = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*trae*" }
    return $processes.Count -gt 0
}

function Test-ConfigFile {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return $false
    }
    
    try {
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        return $null -ne $content -and $content.Trim().Length -gt 0
    } catch {
        return $false
    }
}

function Get-AvailableProjectTypes {
    $projectRulesDir = "$ScriptDir\project_rules"
    if (-not (Test-Path $projectRulesDir)) {
        return @()
    }
    
    return Get-ChildItem $projectRulesDir -Directory | Select-Object -ExpandProperty Name
}

function Initialize-ProjectRules {
    param([string]$ProjectPath, [string]$ProjectType)
    
    if ([string]::IsNullOrEmpty($ProjectPath)) {
        Write-Warning "Project path not specified, skipping Project Rules"
        return $false
    }
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Error "Project path does not exist: $ProjectPath"
        return $false
    }
    
    if ([string]::IsNullOrEmpty($ProjectType)) {
        $availableTypes = Get-AvailableProjectTypes
        if ($availableTypes.Count -eq 0) {
            Write-Warning "No available Project Rules found"
            return $false
        }
        
        Write-Info "Available project types:"
        for ($i = 0; $i -lt $availableTypes.Count; $i++) {
            Write-Host "  $($i + 1). $($availableTypes[$i])" -ForegroundColor White
        }
        
        $selection = Read-Host "Select project type (1-$($availableTypes.Count))"
        if ($selection -match '^\d+$' -and $selection -gt 0 -and $selection -le $availableTypes.Count) {
            $ProjectType = $availableTypes[$selection - 1]
        } else {
            Write-Error "Invalid selection"
            return $false
        }
    }
    
    $sourceDir = "$ScriptDir\project_rules\$ProjectType"
    if (-not (Test-Path $sourceDir)) {
        Write-Error "Project type '$ProjectType' rules not found"
        Write-Gray "Available types: $($availableTypes -join ', ')"
        return $false
    }
    
    $targetDir = "$ProjectPath\.trae\rules"
    
    try {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        Copy-Item "$sourceDir\*" $targetDir -Recurse -Force
        
        $ruleCount = (Get-ChildItem $targetDir -File).Count
        Write-Success "      OK Copied $ruleCount rules to $targetDir"
        Write-Log -Message "Project Rules initialized: $ProjectType -> $targetDir" -Level "INFO"
        return $true
    } catch {
        Write-Error "      ERROR Project Rules initialization failed: $_"
        Write-Log -Message "Project Rules initialization failed: $_" -Level "ERROR"
        return $false
    }
}

if ($Help) {
    Show-Help
    exit 0
}

if (-not $Quiet) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Trae Workflow Setup Script" -ForegroundColor Cyan
    Write-Host "  Version: $Version" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

Write-Log -Message "Setup script started (Version: $Version)" -Level "INFO"

if (-not (Test-Path "$ScriptDir\mcp.json")) {
    Write-Error "Please run this script in the Trae Workflow directory"
    exit 1
}

if (-not (Test-Administrator)) {
    Write-Warning "Note: Running as administrator is recommended"
    if (-not $Force) {
        $response = Read-Host "Continue? (Y/N)"
        if ($response -ne "Y" -and $response -ne "y") {
            Write-Log -Message "User cancelled" -Level "WARN"
            exit 0
        }
    }
}

if (Test-TraeRunning) {
    Write-Warning "Trae IDE is running"
    Write-Warning "Please close Trae IDE before running this script"
    if (-not $Force) {
        $response = Read-Host "Continue? (Y/N)"
        if ($response -ne "Y" -and $response -ne "y") {
            Write-Log -Message "User cancelled" -Level "WARN"
            exit 0
        }
    }
}

$totalSteps = 5
if (-not $SkipMCP) { $totalSteps++ }
if (-not $SkipSkills) { $totalSteps++ }
if (-not $SkipAgents) { $totalSteps++ }
if (-not $SkipRules) { $totalSteps++ }
if (-not $SkipTracking) { $totalSteps++ }
if (-not $SkipProjectRules -and -not [string]::IsNullOrEmpty($ProjectPath)) { $totalSteps++ }

$currentStep = 0

function Write-Progress {
    param([string]$Message)
    $script:currentStep++
    Write-Info "[$currentStep/$totalSteps] $Message"
}

Write-Progress -Message "Creating config directory..."
try {
    New-Item -ItemType Directory -Force -Path $TraeConfigDir | Out-Null
    Write-Success "      OK Config directory: $TraeConfigDir"
    Write-Log -Message "Config directory created: $TraeConfigDir" -Level "INFO"
} catch {
    Write-Error "      ERROR Failed to create config directory: $_"
    Write-Log -Message "Failed to create config directory: $_" -Level "ERROR"
    exit 1
}

if ($Backup -or (Test-Path "$TraeConfigDir\mcp.json")) {
    Write-Progress -Message "Backing up existing config..."
    try {
        $BackupDir = "$TraeConfigDir\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
        
        if (Test-Path "$TraeConfigDir\mcp.json") {
            Copy-Item "$TraeConfigDir\mcp.json" $BackupDir -Force
        }
        if (Test-Path "$TraeConfigDir\skills") {
            Copy-Item "$TraeConfigDir\skills" $BackupDir -Recurse -Force
        }
        if (Test-Path "$TraeConfigDir\agents") {
            Copy-Item "$TraeConfigDir\agents" $BackupDir -Recurse -Force
        }
        if (Test-Path "$TraeConfigDir\user_rules") {
            Copy-Item "$TraeConfigDir\user_rules" $BackupDir -Recurse -Force
        }
        if (Test-Path "$TraeConfigDir\tracking.json") {
            Copy-Item "$TraeConfigDir\tracking.json" $BackupDir -Force
        }
        
        Write-Success "      OK Backup completed: $BackupDir"
        Write-Log -Message "Backup completed: $BackupDir" -Level "INFO"
    } catch {
        Write-Error "      ERROR Backup failed: $_"
        Write-Log -Message "Backup failed: $_" -Level "ERROR"
        exit 1
    }
} else {
    Write-Progress -Message "Skipping backup..."
    Write-Gray "      Skipped backup"
}

if (-not $SkipMCP) {
    Write-Progress -Message "Configuring MCP servers..."
    try {
        if (Test-ConfigFile "$ScriptDir\mcp.json") {
            Copy-Item "$ScriptDir\mcp.json" "$TraeConfigDir\mcp.json" -Force
            Write-Success "      OK MCP config copied"
            Write-Log -Message "MCP config copied" -Level "INFO"
        } else {
            Write-Error "      ERROR MCP config file is invalid or empty"
            Write-Log -Message "MCP config file validation failed" -Level "ERROR"
            exit 1
        }
    } catch {
        Write-Error "      ERROR MCP config copy failed: $_"
        Write-Log -Message "MCP config copy failed: $_" -Level "ERROR"
        exit 1
    }
} else {
    Write-Progress -Message "Skipping MCP config..."
    Write-Gray "      Skipped MCP config"
}

if (-not $SkipSkills) {
    Write-Progress -Message "Configuring Skills..."
    try {
        $SkillsDir = "$TraeConfigDir\skills"
        New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null
        Copy-Item "$ScriptDir\skills\*" $SkillsDir -Recurse -Force
        
        $SkillCount = (Get-ChildItem $SkillsDir -Directory).Count
        Write-Success "      OK Copied $SkillCount skills"
        Write-Log -Message "Skills copied: $SkillCount" -Level "INFO"
    } catch {
        Write-Error "      ERROR Skills config failed: $_"
        Write-Log -Message "Skills config failed: $_" -Level "ERROR"
        exit 1
    }
} else {
    Write-Progress -Message "Skipping Skills config..."
    Write-Gray "      Skipped Skills config"
}

if (-not $SkipAgents) {
    Write-Progress -Message "Configuring Agents..."
    try {
        $AgentsDir = "$TraeConfigDir\agents"
        New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
        Copy-Item "$ScriptDir\agents\*" $AgentsDir -Recurse -Force
        
        $AgentCount = (Get-ChildItem $AgentsDir -File -Filter "*.md").Count
        Write-Success "      OK Copied $AgentCount agents"
        Write-Log -Message "Agents copied: $AgentCount" -Level "INFO"
    } catch {
        Write-Error "      ERROR Agents config failed: $_"
        Write-Log -Message "Agents config failed: $_" -Level "ERROR"
        exit 1
    }
} else {
    Write-Progress -Message "Skipping Agents config..."
    Write-Gray "      Skipped Agents config"
}

if (-not $SkipRules) {
    Write-Progress -Message "Configuring User Rules..."
    try {
        $RulesDir = "$TraeConfigDir\user_rules"
        New-Item -ItemType Directory -Force -Path $RulesDir | Out-Null
        Copy-Item "$ScriptDir\user_rules\*" $RulesDir -Recurse -Force
        
        Write-Success "      OK User Rules copied"
        Write-Log -Message "User Rules copied" -Level "INFO"
    } catch {
        Write-Error "      ERROR User Rules config failed: $_"
        Write-Log -Message "User Rules config failed: $_" -Level "ERROR"
        exit 1
    }
} else {
    Write-Progress -Message "Skipping Rules config..."
    Write-Gray "      Skipped Rules config"
}

if (-not $SkipTracking) {
    Write-Progress -Message "Configuring Tracking..."
    try {
        if (Test-ConfigFile "$ScriptDir\tracking.json") {
            Copy-Item "$ScriptDir\tracking.json" "$TraeConfigDir\tracking.json" -Force
            Write-Success "      OK Tracking config copied"
            Write-Log -Message "Tracking config copied" -Level "INFO"
        } else {
            Write-Warning "      WARN Tracking config file is invalid, skipping"
            Write-Log -Message "Tracking config file validation failed, skipped" -Level "WARN"
        }
    } catch {
        Write-Error "      ERROR Tracking config failed: $_"
        Write-Log -Message "Tracking config failed: $_" -Level "ERROR"
        exit 1
    }
} else {
    Write-Progress -Message "Skipping Tracking config..."
    Write-Gray "      Skipped Tracking config"
}

if (-not $SkipProjectRules -and -not [string]::IsNullOrEmpty($ProjectPath)) {
    Write-Progress -Message "Initializing Project Rules..."
    Initialize-ProjectRules -ProjectPath $ProjectPath -ProjectType $ProjectType
}

if (-not $Quiet) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Setup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Warning "Please restart Trae IDE to apply changes"
    Write-Host ""
    Write-Gray "Config location: $TraeConfigDir"
    Write-Host ""
    Write-Info "Directory structure:"
    Write-Gray "  $TraeConfigDir\"
    Write-Gray "  ├── mcp.json          (MCP servers config)"
    Write-Gray "  ├── skills\           (Skills directory)"
    Write-Gray "  ├── agents\           (Agents directory)"
    Write-Gray "  ├── user_rules\       (User rules directory)"
    Write-Gray "  └── tracking.json     (Tracking config)"
    Write-Host ""
    Write-Info "Project Rules usage:"
    Write-Gray "  Project Rules should be copied to project directory:"
    Write-Warning "  <project_root>/.trae/rules/"
    Write-Host ""
    Write-Gray "  Method 1: Use script to initialize"
    Write-Gray "    .\setup.ps1 -ProjectPath 'C:\myproject' -ProjectType typescript"
    Write-Host ""
    Write-Gray "  Method 2: Manual copy"
    Write-Gray "    Copy-Item -Path '$ScriptDir\project_rules\typescript\*' -Destination '.\.trae\rules\' -Recurse -Force"
    Write-Host ""
    Write-Gray "  Supported types: $(Get-AvailableProjectTypes -join ', ')"
    Write-Host ""
    Write-Gray "Environment variables (optional):"
    Write-Gray "  [Environment]::SetEnvironmentVariable('GITHUB_PAT', 'your_token', 'User')"
    Write-Gray "  [Environment]::SetEnvironmentVariable('EXA_API_KEY', 'your_key', 'User')"
    Write-Host ""
}

if (-not $Quiet) {
    Write-Info "Summary:"
    Write-Host "  - MCP servers: $(if (-not $SkipMCP) { 'Configured' } else { 'Skipped' })"
    Write-Host "  - Skills: $(if (-not $SkipSkills) { 'Configured' } else { 'Skipped' })"
    Write-Host "  - Agents: $(if (-not $SkipAgents) { 'Configured' } else { 'Skipped' })"
    Write-Host "  - User Rules: $(if (-not $SkipRules) { 'Configured' } else { 'Skipped' })"
    Write-Host "  - Tracking: $(if (-not $SkipTracking) { 'Configured' } else { 'Skipped' })"
    if (-not [string]::IsNullOrEmpty($ProjectPath)) {
        Write-Host "  - Project Rules: $(if (-not $SkipProjectRules) { 'Initialized' } else { 'Skipped' })"
    }
    Write-Host ""
}

if (-not $Quiet) {
    Write-Info "Validating config..."
    $Issues = @()
    
    if (-not $SkipMCP -and -not (Test-ConfigFile "$TraeConfigDir\mcp.json")) {
        $Issues += "MCP config not found or invalid"
    }
    if (-not $SkipSkills -and -not (Test-Path "$TraeConfigDir\skills")) {
        $Issues += "Skills directory not found"
    }
    if (-not $SkipAgents -and -not (Test-Path "$TraeConfigDir\agents")) {
        $Issues += "Agents directory not found"
    }
    if (-not $SkipRules -and -not (Test-Path "$TraeConfigDir\user_rules")) {
        $Issues += "User Rules directory not found"
    }
    
    if ($Issues.Count -eq 0) {
        Write-Success "  OK All configurations validated"
        Write-Log -Message "Config validation passed" -Level "INFO"
    } else {
        Write-Warning "  WARN Issues found:"
        $Issues | ForEach-Object { 
            Write-Error "    - $_"
            Write-Log -Message "Validation issue: $_" -Level "WARN"
        }
    }
    
    Write-Host ""
    Write-Gray "Log file: $LogFile"
    Write-Host ""
    Read-Host "Press Enter to exit"
}

Write-Log -Message "Setup script completed" -Level "INFO"
