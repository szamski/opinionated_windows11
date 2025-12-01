<#
.SYNOPSIS
    Installs essential prerequisites: Git and PowerShell 7.

.DESCRIPTION
    This script runs first to ensure Git and PowerShell 7 are available.
    These are required for subsequent installation steps (Scoop, etc.).
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\install-prerequisites.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-GitInstalled {
    try {
        $null = git --version 2>&1
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Test-PowerShell7Installed {
    try {
        $pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue
        return ($null -ne $pwshPath)
    }
    catch {
        return $false
    }
}

function Install-GitPackage {
    Write-ColorOutput "`nInstalling Git..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install Git via winget"
        return $true
    }

    try {
        # Check if already installed
        if (Test-GitInstalled) {
            Write-ColorOutput "  ○ Git is already installed" "Gray"
            $version = git --version 2>&1
            Write-ColorOutput "  Version: $version" "Gray"
            return $true
        }

        # Install Git via winget
        Write-ColorOutput "  Installing Git.Git via winget..." "Gray"
        winget install --id Git.Git --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Git installed successfully" "Green"

            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            Write-ColorOutput "  ! You may need to restart PowerShell for git to be fully available" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  ✗ Failed to install Git (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  ✗ Error installing Git: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Install-PowerShell7Package {
    Write-ColorOutput "`nInstalling PowerShell 7..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Install PowerShell 7 via winget"
        return $true
    }

    try {
        # Check if already installed
        if (Test-PowerShell7Installed) {
            Write-ColorOutput "  ○ PowerShell 7 is already installed" "Gray"
            $version = pwsh --version 2>&1
            Write-ColorOutput "  Version: $version" "Gray"
            return $true
        }

        # Install PowerShell 7 via winget
        Write-ColorOutput "  Installing Microsoft.PowerShell via winget..." "Gray"
        winget install --id Microsoft.PowerShell --exact --silent --accept-source-agreements --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ PowerShell 7 installed successfully" "Green"

            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

            Write-ColorOutput "  ! You may need to restart your session to use pwsh" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  ✗ Failed to install PowerShell 7 (exit code: $LASTEXITCODE)" "Red"
            return $false
        }
    }
    catch {
        Write-ColorOutput "  ✗ Error installing PowerShell 7: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Prerequisites Installation" "Magenta"
Write-ColorOutput "========================================" "Magenta"

Write-ColorOutput "`nInstalling essential prerequisites required for setup..." "White"

$successCount = 0
$totalSteps = 2

# ========================================
# Step 1: Install Git
# ========================================
Write-ColorOutput "`n[Step 1: Git Installation]" "Cyan"
if (Install-GitPackage) {
    $successCount++
}

# ========================================
# Step 2: Install PowerShell 7
# ========================================
Write-ColorOutput "`n[Step 2: PowerShell 7 Installation]" "Cyan"
if (Install-PowerShell7Package) {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Prerequisites Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nPrerequisites installation completed successfully!" "Green"
}
else {
    Write-ColorOutput "`nPrerequisites installation completed with some errors." "Yellow"
    Write-ColorOutput "Some features may not work correctly." "Yellow"
}

Write-ColorOutput "`n[Important Notes]" "Cyan"
Write-ColorOutput "  • Git is required for cloning repositories" "Gray"
Write-ColorOutput "  • PowerShell 7 provides modern features and better performance" "Gray"
Write-ColorOutput "  • Scoop installation (next step) requires both of these" "Gray"
