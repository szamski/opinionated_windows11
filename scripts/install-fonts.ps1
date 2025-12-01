<#
.SYNOPSIS
    Installs Nerd Fonts for terminal usage.

.DESCRIPTION
    Downloads and installs CaskaydiaCove Nerd Font (Cascadia Code with icons) from GitHub releases.
    This font is essential for proper Starship prompt display.
    Based on NerdFontInstaller by vatsan-madhavan.
    Supports dry-run mode via DRYRUN_MODE environment variable.

.EXAMPLE
    .\install-fonts.ps1
#>

# Import common helpers
. "$PSScriptRoot\common-helpers.ps1"

function Test-DryRun {
    return ($env:DRYRUN_MODE -eq "true")
}

function Test-FontInstalled {
    param([string]$FontName)

    try {
        $installedFonts = (New-Object -ComObject Shell.Application).Namespace(0x14).Items() | Select-Object -ExpandProperty Name
        return ($installedFonts -match $FontName)
    }
    catch {
        # Fallback to registry check
        try {
            $fonts = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue
            $fontInstalled = $fonts.PSObject.Properties | Where-Object { $_.Value -like "*$FontName*" }
            return ($null -ne $fontInstalled)
        }
        catch {
            return $false
        }
    }
}

function Install-NerdFont {
    param(
        [string]$FontName = "CascadiaCode"
    )

    Write-ColorOutput "`nInstalling $FontName Nerd Font..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Download and install $FontName Nerd Font from GitHub"
        return $true
    }

    try {
        # Check if font is already installed
        if (Test-FontInstalled -FontName $FontName) {
            Write-ColorOutput "  ○ $FontName Nerd Font appears to be already installed" "Gray"
            return $true
        }

        # Get latest release from nerd-fonts GitHub
        Write-ColorOutput "  Fetching latest Nerd Fonts release from GitHub..." "Gray"
        $repo = "ryanoasis/nerd-fonts"
        $release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest" -ErrorAction Stop

        # Find the font asset
        $fontAsset = $release.assets | Where-Object { $_.name -eq "$FontName.zip" } | Select-Object -First 1

        if (-not $fontAsset) {
            Write-ColorOutput "  ✗ Could not find $FontName in latest release" "Red"
            Write-ColorOutput "  Falling back to winget installation..." "Yellow"

            # Fallback to winget
            winget install --id "DEVCOM.CascadiaCodeNerdFont" --exact --silent --accept-source-agreements --accept-package-agreements

            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "  ✓ $FontName installed successfully via winget" "Green"
                return $true
            }
            else {
                Write-ColorOutput "  ✗ Failed to install via winget" "Red"
                return $false
            }
        }

        # Create temp directory
        $tempDir = Join-Path $env:TEMP "NerdFonts_$([guid]::NewGuid())"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        # Download the font zip
        Write-ColorOutput "  Downloading $FontName ($([math]::Round($fontAsset.size / 1MB, 2)) MB)..." "Gray"
        $zipPath = Join-Path $tempDir "$FontName.zip"
        Invoke-WebRequest -Uri $fontAsset.browser_download_url -OutFile $zipPath -ErrorAction Stop

        # Extract the zip
        Write-ColorOutput "  Extracting fonts..." "Gray"
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

        # Install fonts using Shell COM object (proper method)
        Write-ColorOutput "  Installing fonts to system..." "Gray"
        $shellApp = New-Object -ComObject Shell.Application
        $fontsFolder = $shellApp.NameSpace(0x14)  # Fonts special folder

        $fontFiles = Get-ChildItem -Path $tempDir -Include "*.ttf", "*.otf" -Recurse
        $installedCount = 0

        foreach ($fontFile in $fontFiles) {
            # Skip if filename contains "Windows Compatible" (we want the full version)
            if ($fontFile.Name -notmatch "Windows Compatible") {
                try {
                    $fontsFolder.CopyHere($fontFile.FullName, 0x10)  # 0x10 = Don't show UI
                    $installedCount++
                }
                catch {
                    # Font might already be installed, continue
                }
            }
        }

        # Cleanup
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

        if ($installedCount -gt 0) {
            Write-ColorOutput "  ✓ Successfully installed $installedCount font files" "Green"
            Write-ColorOutput "  Note: Restart applications to see the new font" "Yellow"
            return $true
        }
        else {
            Write-ColorOutput "  ✗ No fonts were installed (they may already exist)" "Yellow"
            return $true
        }
    }
    catch {
        Write-ColorOutput "  ✗ Error installing $FontName : $_" "Red"
        Write-ColorOutput "  You can manually download from: https://github.com/ryanoasis/nerd-fonts/releases" "Yellow"
        return $false
    }
}

function Set-WindowsTerminalFont {
    Write-ColorOutput "`nConfiguring Windows Terminal to use CaskaydiaCove..." "Cyan"

    if (Test-DryRun) {
        Write-DryRunAction "Update Windows Terminal settings.json to use CaskaydiaCove NF"
        return $true
    }

    try {
        $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

        if (-not (Test-Path $settingsPath)) {
            Write-ColorOutput "  ○ Windows Terminal settings not found (not installed or not run yet)" "Gray"
            return $true
        }

        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        # Update default profile font
        if (-not $settings.profiles.defaults) {
            $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue @{} -Force
        }

        if (-not $settings.profiles.defaults.font) {
            $settings.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue @{} -Force
        }

        $settings.profiles.defaults.font.face = "CaskaydiaCove Nerd Font"

        # Save settings
        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

        Write-ColorOutput "  ✓ Windows Terminal configured to use CaskaydiaCove Nerd Font" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "  ✗ Failed to configure Windows Terminal: $_" "Red"
        Write-ColorOutput "  You can manually set the font in Windows Terminal settings" "Yellow"
        return $false
    }
}

# Main execution
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "  Nerd Fonts Installation" "Magenta"
Write-ColorOutput "========================================" "Magenta"

$successCount = 0
$totalSteps = 0

# ========================================
# Step 1: Install CaskaydiaCove Nerd Font
# ========================================
Write-ColorOutput "`n[Step 1: CaskaydiaCove Nerd Font]" "Cyan"
$totalSteps++

if (Install-NerdFont -FontName "CascadiaCode") {
    $successCount++
}

# ========================================
# Step 2: Configure Windows Terminal
# ========================================
Write-ColorOutput "`n[Step 2: Windows Terminal Configuration]" "Cyan"
$totalSteps++

if (Set-WindowsTerminalFont) {
    $successCount++
}

# ========================================
# Summary
# ========================================
Write-ColorOutput "`n========================================" "Magenta"
Write-ColorOutput "  Font Installation Summary" "Magenta"
Write-ColorOutput "========================================" "Magenta"
Write-ColorOutput "Total steps: $totalSteps" "White"
Write-ColorOutput "Successfully completed: $successCount" "Green"
Write-ColorOutput "Failed: $($totalSteps - $successCount)" "Red"

if ($successCount -eq $totalSteps) {
    Write-ColorOutput "`nFont installation completed successfully!" "Green"
}
else {
    Write-ColorOutput "`nFont installation completed with some warnings." "Yellow"
}

Write-ColorOutput "`n[Important Notes]" "Cyan"
Write-ColorOutput "  • The font is now installed system-wide" "Gray"
Write-ColorOutput "  • Restart Windows Terminal if it's currently open" "Gray"
Write-ColorOutput "  • The font enables icons in Starship prompt" "Gray"
Write-ColorOutput "  • You can select it in any terminal: 'CaskaydiaCove Nerd Font'" "Gray"
