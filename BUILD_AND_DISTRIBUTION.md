# AKK En-to-MM Dictionary - Build & Distribution Guide

## Overview
This guide explains how to build the executable and create an installer for the AKK En-to-MM Dictionary application.

## Prerequisites
- .NET 8 SDK or higher
- (Optional) Inno Setup 6 for creating the installer

## Build Options

### Option 1: Quick Build (Recommended)
Run the PowerShell build script:

```powershell
.\Build-Package.ps1
```

This script will:
1. Build a self-contained executable for Windows x64
2. Copy the executable to `bin\Installers`
3. Create an installer (if Inno Setup is installed)

### Option 2: Manual Build

#### Build Release Executable
```bash
dotnet publish -c Release -r win-x64 --self-contained
```

Output: `bin\Release\net8.0-windows\win-x64\publish\AKK En-to-MM Dictionary.exe`

#### Create Installer (requires Inno Setup 6)
1. Install Inno Setup from: https://jrsoftware.org/isinfo.php
2. Right-click `AkkDictionaryApp.iss` and select "Compile with Inno Setup"
   - Or use command line: `"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" AkkDictionaryApp.iss`

Output: `bin\Installers\AKK_En-to-MM_Dictionary_Setup_v1.0.0.exe`

## Distribution

### Option A: Standalone Executable (No Installation)
Users can download and run the `.exe` directly:
- **File**: `bin\Installers\AKK En-to-MM Dictionary.exe`
- **Size**: ~181 MB (includes .NET 8 runtime)
- **No dependencies** - works on any Windows 10/11 system
- **Portable** - can be run from USB drive or network share

### Option B: Installer
Users can run the installer for a more traditional installation experience:
- **File**: `bin\Installers\AKK_En-to-MM_Dictionary_Setup_v1.0.0.exe`
- **Includes**: Application + dictionary.db file
- **Installs**: Desktop shortcut and Start Menu entry
- **Uninstall**: Via Windows Control Panel

## Building Different Configurations

### Build for other Windows versions (x86):
```bash
dotnet publish -c Release -r win-x86 --self-contained
```

### Build with trimming (smaller size, but slower to build):
```bash
dotnet publish -c Release -r win-x64 --self-contained -p:TrimMode=partial
```

## Troubleshooting

### Installer fails to build
- Ensure Inno Setup 6 is installed
- Check that `AkkDictionaryApp.iss` exists in the project root
- Run PowerShell as Administrator

### Application doesn't start
- Ensure `dictionary.db` is in the same folder as the executable
- Check Windows Event Viewer for error details
- Try running the application from command line to see errors

### .NET 8 not found
- The standalone executable includes the .NET 8 runtime
- No additional .NET installation is required

## File Locations After Build

```
bin/
├── Release/
│   └── net8.0-windows/
│       ├── AkkDictionaryApp.dll (framework-dependent)
│       └── win-x64/
│           └── publish/
│               ├── AKK En-to-MM Dictionary.exe (standalone)
│               ├── dictionary.db
│               └── [runtime files]
└── Installers/
    ├── AKK En-to-MM Dictionary.exe (copy of standalone)
    └── AKK_En-to-MM_Dictionary_Setup_v1.0.0.exe (installer)
```

## Release Checklist

Before releasing, ensure:
- [ ] All features are tested
- [ ] No compilation errors or warnings
- [ ] Settings are saved/loaded correctly
- [ ] Database operations work correctly
- [ ] Excel import works
- [ ] SQLite import works
- [ ] Reverse search works
- [ ] Application runs on clean Windows system

## Version Updates

To update the version:
1. Edit `AkkDictionaryApp.csproj` - change `<Version>` tag
2. Edit `AkkDictionaryApp.iss` - change `#define MyAppVersion`
3. Rebuild using the build script

## Support

For issues or questions, visit the project repository or contact the development team.
