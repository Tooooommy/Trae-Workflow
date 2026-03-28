# Trae Workflow Setup Script
# Version: 3.1.0

param(
    [switch]$Backup,
    [switch]$SkipSkills,
    [switch]$SkipRules,
    [switch]$Quiet,
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = "Continue"
$TraeConfigDir = "$env:USERPROFILE\.trae-cn"
$ScriptDir = $PSScriptRoot
$LogFile = "$ScriptDir\setup-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Version = "3.1.0"

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
    Write-Host "  -Backup         Backup existing config" -ForegroundColor White
    Write-Host "  -SkipSkills     Skip Skills config" -ForegroundColor White
    Write-Host "  -SkipRules      Skip Rules config" -ForegroundColor White
    Write-Host "  -Quiet          Quiet mode" -ForegroundColor White
    Write-Host "  -Force          Force execution" -ForegroundColor White
    Write-Host "  -Help           Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\setup.ps1" -ForegroundColor Gray
    Write-Host "  .\setup.ps1 -Backup" -ForegroundColor Gray
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

$totalSteps = 2
if (-not $SkipSkills) { $totalSteps++ }
if (-not $SkipRules) { $totalSteps++ }

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

if ($Backup -or (Test-Path "$TraeConfigDir\skills")) {
    Write-Progress -Message "Backing up existing config..."
    try {
        $BackupDir = "$TraeConfigDir\backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

        if (Test-Path "$TraeConfigDir\skills") {
            Copy-Item "$TraeConfigDir\skills" $BackupDir -Recurse -Force
        }
        if (Test-Path "$TraeConfigDir\user_rules") {
            Copy-Item "$TraeConfigDir\user_rules" $BackupDir -Recurse -Force
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
    Write-Gray "  ├── skills\           (Skills directory)"
    Write-Gray "  └── user_rules\       (User rules directory)"
    Write-Host ""
}

if (-not $Quiet) {
    Write-Info "Summary:"
    Write-Host "  - Skills: $(if (-not $SkipSkills) { 'Configured' } else { 'Skipped' })"
    Write-Host "  - User Rules: $(if (-not $SkipRules) { 'Configured' } else { 'Skipped' })"
    Write-Host ""
}

if (-not $Quiet) {
    Write-Info "Validating config..."
    $Issues = @()

    if (-not $SkipSkills -and -not (Test-Path "$TraeConfigDir\skills")) {
        $Issues += "Skills directory not found"
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
