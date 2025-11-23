# Opinionated Windows 11 Setup

Automated Windows 11 setup script for a fresh installation. One command to install all your essential software, configure system settings, and get your development environment ready.

## 🚀 Quick Start

### Interactive Menu (Recommended)

Simply run the script and choose from the interactive menu:

```powershell
.\setup.ps1
```

The menu offers:
- **Full Installation** - Install everything
- **Dry-Run Mode** - Preview changes without applying them
- **Custom Installation** - Pick and choose components
- **Quick Install** - Skip drivers and WSL for faster setup

### One-Line Remote Installation

Open PowerShell as Administrator and run:

```powershell
irm https://raw.githubusercontent.com/YOUR-USERNAME/opinionated_windows11/main/setup.ps1 | iex
```

> **Note:** Replace `YOUR-USERNAME` with your GitHub username after uploading this repo.

## ✨ What This Does

This automated setup script configures a fresh Windows 11 installation with:

### 📦 Software Installation (via winget)

**Development Tools:**
- Git
- Node.js
- Visual Studio Code
- Docker Desktop
- Python 3.13
- FFmpeg
- cURL

**Terminal & Shell:**
- Windows Terminal
- Starship (beautiful shell prompt)

**Productivity:**
- Claude (AI assistant)
- Obsidian (note-taking)
- 1Password (password manager)
- Google Chrome

**Communication:**
- Discord
- Slack
- Zoom
- Lark

**Creative Tools:**
- Affinity (design suite)
- Bambu Studio (3D printing)

**Utilities:**
- LocalSend (file sharing)
- Spotify
- NordVPN
- Focusrite Control 2

**Gaming:**
- Steam

### ⚙️ System Configuration

**Windows Explorer:**
- Show hidden files and folders
- Show file extensions
- Open to "This PC" instead of Quick Access

**Theme:**
- Dark mode for apps
- Dark mode for system

**Taskbar:**
- Hide search box
- Hide Task View button
- Disable animations
- Disable desktop preview on hover

**Privacy & Performance:**
- Disable recent documents tracking
- Disable Start Menu recommendations
- Disable window animations
- Optimize visual effects for performance

### 🔧 Environment Variables

**Custom Variables:**
- `Claude_Code` → `%USERPROFILE%\.local\bin`
- `NODE_HOME` → `C:\Program Files\nodejs`

**PATH Additions:**
- Claude Code CLI
- npm global packages
- VS Code CLI
- Python & Scripts
- Git
- Starship
- Node.js
- Docker

### 🖥️ Hardware Detection & Driver Installation

**Automatic Hardware Detection:**
- Graphics cards (NVIDIA, AMD, Intel)
- Processors (Intel, AMD)
- Audio devices (Realtek, Focusrite, etc.)
- Network adapters (WiFi, Ethernet, Bluetooth)
- Storage devices
- System manufacturer information

**Smart Driver Installation:**
- NVIDIA GeForce Experience (for NVIDIA GPUs)
- AMD Adrenalin Edition (for AMD GPUs)
- Intel Driver & Support Assistant (for Intel systems)
- Manufacturer-specific tools:
  - Lenovo System Update
  - Dell Command Update
  - HP Support Assistant
- Windows Update integration for remaining drivers

### 🐧 WSL (Windows Subsystem for Linux)

- Enables WSL 2
- Enables Virtual Machine Platform
- Installs Ubuntu as default distribution

## 📋 Requirements

- Windows 11 (fresh installation recommended)
- PowerShell 5.1 or higher
- Administrator privileges
- Internet connection

## 🛠️ Manual Installation

If you prefer to clone the repository first:

1. Clone this repository:
   ```powershell
   git clone https://github.com/YOUR-USERNAME/opinionated_windows11.git
   cd opinionated_windows11
   ```

2. Run the setup script as Administrator:
   ```powershell
   .\setup.ps1
   ```
   This will show the interactive menu where you can choose your installation mode.

## 📋 Interactive Menu

When you run `.\setup.ps1` without parameters, you'll see an interactive menu:

```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          Windows 11 Automated Setup Script               ║
║          Opinionated & Optimized                         ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

Select Installation Mode:

  1. Full Installation (Recommended)
     Install everything: software, drivers, WSL, and configure system

  2. Dry-Run Mode (Preview Only)
     See what would be installed without making changes

  3. Custom Installation
     Choose which components to install

  4. Quick Install (Skip Drivers & WSL)
     Install software and configure system only

  Q. Quit
```

### Custom Installation Menu

Option 3 opens an interactive component selector:

```
═══════════════════════════════════════
  Custom Installation Options
═══════════════════════════════════════

Select components to install:

  1. [X] Software Installation
  2. [X] System Configuration
  3. [X] Environment Variables
  4. [X] Hardware Drivers
  5. [X] Windows Subsystem for Linux (WSL)

  D. [ ] Dry-Run Mode (Preview Only)

  S. Start Installation
  B. Back to Main Menu
```

Toggle options by entering their number, then press **S** to start!

## 🔍 Dry-Run Mode (Preview Changes)

**Test before you commit!** Use dry-run mode to see what the script would do without making any actual changes:

```powershell
# Preview everything that would be installed/configured
.\setup.ps1 -DryRun

# Preview with selective installation
.\setup.ps1 -DryRun -SkipWSL

# Perfect for testing on VMs or before running on your main system
```

**Dry-run mode:**
- Shows all packages that would be installed
- Lists all registry changes that would be made
- Displays environment variables that would be set
- Shows drivers that would be installed
- **Makes NO actual changes to your system**
- **Does NOT require Administrator privileges**

## 🎯 Command-Line Parameters (Advanced)

You can bypass the menu and use command-line parameters directly:

```powershell
# Full installation without menu
.\setup.ps1 -NoMenu

# Dry-run without menu
.\setup.ps1 -DryRun -NoMenu

# Skip specific components
.\setup.ps1 -SkipSoftware -NoMenu
.\setup.ps1 -SkipSystemConfig -NoMenu
.\setup.ps1 -SkipEnvironment -NoMenu
.\setup.ps1 -SkipDrivers -NoMenu
.\setup.ps1 -SkipWSL -NoMenu

# Combine multiple parameters
.\setup.ps1 -SkipWSL -SkipDrivers -DryRun -NoMenu
```

**Parameters:**
- `-NoMenu` - Skip interactive menu and run directly
- `-DryRun` - Preview mode (no changes)
- `-SkipSoftware` - Skip software installation
- `-SkipSystemConfig` - Skip system configuration
- `-SkipEnvironment` - Skip environment variables
- `-SkipDrivers` - Skip hardware drivers
- `-SkipWSL` - Skip WSL installation

## 📁 Project Structure

```
opinionated_windows11/
├── setup.ps1                    # Main orchestration script
├── config/
│   └── software.json           # Software packages configuration
├── scripts/
│   ├── common-helpers.ps1      # Shared helper functions
│   ├── install-software.ps1    # Winget software installer
│   ├── configure-system.ps1    # Windows settings configurator
│   ├── setup-env.ps1           # Environment variables setup
│   ├── detect-hardware.ps1     # Hardware detection module
│   ├── install-drivers.ps1     # Driver installation module
│   └── enable-wsl.ps1          # WSL installer
└── README.md                    # This file
```

## 🔄 Post-Installation Steps

After running the setup script:

1. **Restart your computer** to apply all changes

2. **Launch Ubuntu** from Start Menu to complete WSL setup
   - Create your Linux username and password

3. **Configure Starship prompt** (optional):
   Add to your PowerShell profile:
   ```powershell
   notepad $PROFILE
   # Add this line:
   Invoke-Expression (&starship init powershell)
   ```

4. **Sign into your applications:**
   - 1Password
   - Google Chrome (sync your settings)
   - Discord, Slack, Zoom

5. **Configure Git:**
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your.email@example.com"
   ```

## 🎨 Customization

### Adding More Software

Edit `config/software.json` to add or remove software packages. Find package IDs using:

```powershell
winget search "package name"
```

### Modifying System Settings

Edit `scripts/configure-system.ps1` to customize Windows registry settings.

### Changing Environment Variables

Edit `scripts/setup-env.ps1` to add or modify environment variables.

## 📝 Logs

The setup script creates a log file with timestamp in the root directory:
```
setup-log-2024-01-15-143022.txt
```

Review this file if you encounter any issues.

## ⚠️ Troubleshooting

### Winget Not Found
If winget is not installed, the script will attempt to install it automatically. If this fails:
1. Install "App Installer" from Microsoft Store
2. Restart PowerShell and try again

### Permission Errors
Make sure you're running PowerShell as Administrator:
1. Right-click PowerShell
2. Select "Run as Administrator"

### WSL Installation Requires Restart
Some Windows features require a restart. The script will notify you if this is needed.

### Script Execution Policy
If you get an execution policy error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🤝 Contributing

This is a personal setup script, but feel free to fork it and customize it for your own needs!

## 📄 License

This project is provided as-is for personal use. Feel free to modify and share.

## 🙏 Credits

Generated with [Claude Code](https://claude.com/claude-code) - AI-powered coding assistant.

---

**Happy Windows 11 Setup!** 🎉
