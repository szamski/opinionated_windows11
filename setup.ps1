#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Automated Windows 11 setup script - One script to rule them all!

.DESCRIPTION
    This is the main orchestration script that sets up a fresh Windows 11 installation with:
    - Essential software installation via winget
    - Custom system settings and preferences
    - Environment variables and PATH configuration
    - Hardware detection and driver installation
    - Windows Subsystem for Linux (WSL)

    This script is designed to be run immediately after a fresh Windows 11 installation.

.PARAMETER SkipSoftware
    Skip software installation

.PARAMETER SkipSystemConfig
    Skip system configuration

.PARAMETER SkipEnvironment
    Skip environment variables setup

.PARAMETER SkipDrivers
    Skip hardware detection and driver installation

.PARAMETER SkipWSL
    Skip WSL installation

.EXAMPLE
    .\setup.ps1
    Run full setup (recommended)

.EXAMPLE
    .\setup.ps1 -SkipWSL
    Run setup but skip WSL installation

.NOTES
    Author: Generated with Claude Code
    Requires: Windows 11, PowerShell 5.1+, Administrator privileges
#>

param(
    [switch]$SkipSoftware,
    [switch]$SkipSystemConfig,
    [switch]$SkipEnvironment,
    [switch]$SkipDrivers,
    [switch]$SkipWSL
)

# ========================================
# Configuration
# ========================================
$ErrorActionPreference = "Continue"
$ScriptRoot = $PSScriptRoot
$LogFile = Join-Path $ScriptRoot "setup-log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"

# ========================================
# Helper Functions
# ========================================
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message"

    Write-Host $logMessage -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $logMessage
}

function Write-Header {
    param([string]$Title)

    $line = "=" * 60
    Write-ColorOutput "`n$line" "Magenta"
    Write-ColorOutput "  $Title" "Magenta"
    Write-ColorOutput "$line" "Magenta"
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-ScriptModule {
    param(
        [string]$ModulePath,
        [string]$ModuleName,
        [string]$Description
    )

    Write-Header $Description

    if (-not (Test-Path $ModulePath)) {
        Write-ColorOutput "Error: Module not found at $ModulePath" "Red"
        return $false
    }

    try {
        Write-ColorOutput "Executing $ModuleName..." "Cyan"
        $startTime = Get-Date

        & $ModulePath

        $duration = (Get-Date) - $startTime
        Write-ColorOutput "`n✓ $ModuleName completed in $($duration.TotalSeconds) seconds" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "`n✗ Error executing $ModuleName : $_" "Red"
        Write-ColorOutput $_.ScriptStackTrace "Red"
        return $false
    }
}

# ========================================
# Pre-flight Checks
# ========================================
Clear-Host

Write-ColorOutput @"

    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║          Windows 11 Automated Setup Script               ║
    ║          Opinionated & Optimized                         ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝

"@ "Cyan"

Write-ColorOutput "Starting setup at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" "White"
Write-ColorOutput "Log file: $LogFile" "Gray"

# Check administrator privileges
if (-not (Test-Administrator)) {
    Write-ColorOutput "`nError: This script requires Administrator privileges!" "Red"
    Write-ColorOutput "Please right-click and select 'Run as Administrator'" "Yellow"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-ColorOutput "✓ Running with Administrator privileges" "Green"

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-ColorOutput "PowerShell Version: $($psVersion.Major).$($psVersion.Minor).$($psVersion.Build)" "Gray"

if ($psVersion.Major -lt 5) {
    Write-ColorOutput "`nWarning: PowerShell 5.0 or higher is recommended" "Yellow"
}

# Display what will be executed
Write-ColorOutput "`nSetup Configuration:" "White"
Write-ColorOutput "  Software Installation: $(if ($SkipSoftware) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipSoftware) { "Yellow" } else { "Green" })
Write-ColorOutput "  System Configuration: $(if ($SkipSystemConfig) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipSystemConfig) { "Yellow" } else { "Green" })
Write-ColorOutput "  Environment Variables: $(if ($SkipEnvironment) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipEnvironment) { "Yellow" } else { "Green" })
Write-ColorOutput "  Driver Installation: $(if ($SkipDrivers) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipDrivers) { "Yellow" } else { "Green" })
Write-ColorOutput "  WSL Installation: $(if ($SkipWSL) { 'SKIPPED' } else { 'ENABLED' })" $(if ($SkipWSL) { "Yellow" } else { "Green" })

Write-ColorOutput "`nPress Ctrl+C to cancel, or" "Yellow"
Read-Host "Press Enter to continue"

# ========================================
# Main Execution
# ========================================
$overallStartTime = Get-Date
$executedModules = 0
$successfulModules = 0
$failedModules = @()

# Module 1: Software Installation
if (-not $SkipSoftware) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\install-software.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Software Installation" -Description "STEP 1: Installing Software Packages") {
        $successfulModules++
    }
    else {
        $failedModules += "Software Installation"
    }
}

# Module 2: System Configuration
if (-not $SkipSystemConfig) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\configure-system.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "System Configuration" -Description "STEP 2: Configuring Windows Settings") {
        $successfulModules++
    }
    else {
        $failedModules += "System Configuration"
    }
}

# Module 3: Environment Variables
if (-not $SkipEnvironment) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\setup-env.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Environment Setup" -Description "STEP 3: Setting Up Environment Variables") {
        $successfulModules++
    }
    else {
        $failedModules += "Environment Setup"
    }
}

# Module 4: Hardware Detection & Driver Installation
if (-not $SkipDrivers) {
    # Step 4a: Detect Hardware
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\detect-hardware.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Hardware Detection" -Description "STEP 4a: Detecting System Hardware") {
        $successfulModules++
    }
    else {
        $failedModules += "Hardware Detection"
    }

    # Step 4b: Install Drivers
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\install-drivers.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "Driver Installation" -Description "STEP 4b: Installing Hardware Drivers") {
        $successfulModules++
    }
    else {
        $failedModules += "Driver Installation"
    }
}

# Module 5: WSL Installation
if (-not $SkipWSL) {
    $executedModules++
    $modulePath = Join-Path $ScriptRoot "scripts\enable-wsl.ps1"
    if (Invoke-ScriptModule -ModulePath $modulePath -ModuleName "WSL Installation" -Description "STEP 5: Installing Windows Subsystem for Linux") {
        $successfulModules++
    }
    else {
        $failedModules += "WSL Installation"
    }
}

# ========================================
# Final Summary
# ========================================
$overallDuration = (Get-Date) - $overallStartTime

Write-Header "SETUP COMPLETE"

Write-ColorOutput "`nExecution Summary:" "White"
Write-ColorOutput "  Total modules executed: $executedModules" "White"
Write-ColorOutput "  Successful: $successfulModules" "Green"
Write-ColorOutput "  Failed: $($failedModules.Count)" $(if ($failedModules.Count -gt 0) { "Red" } else { "Green" })
Write-ColorOutput "  Total duration: $([math]::Round($overallDuration.TotalMinutes, 2)) minutes" "White"

if ($failedModules.Count -gt 0) {
    Write-ColorOutput "`nFailed modules:" "Red"
    foreach ($module in $failedModules) {
        Write-ColorOutput "  - $module" "Red"
    }
}

Write-ColorOutput "`nLog file saved to: $LogFile" "Gray"

# ========================================
# Post-Setup Recommendations
# ========================================
Write-ColorOutput "`n" "White"
Write-ColorOutput "╔═══════════════════════════════════════════════════════════╗" "Cyan"
Write-ColorOutput "║              RECOMMENDED NEXT STEPS                       ║" "Cyan"
Write-ColorOutput "╚═══════════════════════════════════════════════════════════╝" "Cyan"
Write-ColorOutput ""
Write-ColorOutput "  1. Restart your computer to apply all changes" "Yellow"
Write-ColorOutput "  2. After restart, launch Ubuntu from Start Menu to complete WSL setup" "Yellow"
Write-ColorOutput "  3. Configure Starship prompt (if not done):" "Yellow"
Write-ColorOutput "     Add to PowerShell profile: Invoke-Expression (&starship init powershell)" "Gray"
Write-ColorOutput "  4. Sign into your applications:" "Yellow"
Write-ColorOutput "     - 1Password" "Gray"
Write-ColorOutput "     - Google Chrome" "Gray"
Write-ColorOutput "     - Discord, Slack, Zoom" "Gray"
Write-ColorOutput "  5. Configure Git:" "Yellow"
Write-ColorOutput "     git config --global user.name 'Your Name'" "Gray"
Write-ColorOutput "     git config --global user.email 'your.email@example.com'" "Gray"
Write-ColorOutput ""

if ($successfulModules -eq $executedModules) {
    Write-ColorOutput "All modules completed successfully! Enjoy your optimized Windows 11 setup!" "Green"
}
else {
    Write-ColorOutput "Setup completed with some errors. Please review the log file." "Yellow"
}

Write-ColorOutput "`nPress Enter to exit..." "White"
Read-Host
