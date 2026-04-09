# Cross-Platform Build Automation Guide

## Quick Start

### Windows (Native Build - Primary)
```powershell
# Build and publish Windows app
dotnet publish -c Release -f net8.0-windows -o ./bin/releases/windows

# Or use the automated script
.\scripts\build-all.ps1
```

### Android (Docker Build - Fully Automated)
```powershell
# Prerequisites: Docker Desktop installed
# https://www.docker.com/products/docker-desktop

# Option 1: Individual Android build
.\scripts\build-android-docker.ps1 -Version 1.1.0

# Option 2: Build all platforms
.\scripts\build-all.ps1
```

### macOS (GitHub Actions - Cloud Build)
- Automatically builds when you push to GitHub
- See `.github/workflows/cross-platform-build.yml`
- Creates DMG installer for macOS

---

## Architecture

### **Windows** ✅ (Primary - Native)
- Builds directly on Windows machine
- Uses WPF for UI
- Location: `/bin/releases/windows/AkkDictionary.exe`

### **Android** 📱 (Docker)
- Runs in isolated Linux Docker container
- Includes Android SDK, NDK, and Java JDK
- No local installation needed on Windows
- Location: `/bin/releases/*.apk`

### **macOS** 🍎 (GitHub Actions Cloud)
- Builds on GitHub's macOS runner
- No local macOS machine needed
- Automatically creates DMG installer
- Triggered on push/tag to master

---

## Setup Instructions

### 1. Install Docker (for Android builds)

**Windows:**
```powershell
# Using Chocolatey (if installed)
choco install docker-desktop

# Or: Download from https://www.docker.com/products/docker-desktop
# After installation, restart computer
```

Verify:
```powershell
docker --version
```

### 2. Enable GitHub Actions (for macOS builds)

1. Go to your GitHub repo: https://github.com/aungkokomm/AkkDictionaryApp
2. Click **Settings** → **Actions** → **General**
3. Enable "Allow all actions and reusable workflows"
4. Save

### 3. Test Builds Locally

```powershell
# Windows only
dotnet publish -c Release -f net8.0-windows -o ./bin/releases/windows

# Windows + Android (via Docker)
.\scripts\build-all.ps1

# Android only (via Docker)
.\scripts\build-android-docker.ps1
```

---

## Build Pipeline

### Local Workflow (Windows + Docker)
```
1. User runs: .\scripts\build-all.ps1
   ↓
2. Windows build:
   - Clean solution
   - Build native WPF app
   - Publish to bin/releases/windows/
   ↓
3. Android build (Docker):
   - Start Docker container
   - Install Android SDK + NDK
   - Build APK
   - Output to bin/releases/*.apk
   ↓
4. Both artifacts ready in ./bin/releases/
```

### Cloud Workflow (GitHub Actions)
```
1. Push to master or create tag
   ↓
2. GitHub Actions triggers:
   - Windows job (win-latest)
   - Android job (ubuntu-latest)
   - macOS job (macos-latest)
   ↓
3. All build in parallel
   ↓
4. Create GitHub Release (if tagged)
   - Attach Windows EXE
   - Attach Android APK
   - Attach macOS DMG
```

---

## File Outputs

After building, artifacts are located at:

```
bin/
  releases/
    windows/
      AkkDictionary.exe           ← Windows main executable
      *.dll                        ← Windows dependencies
      dictionary.db               ← Database
    AKK-Dictionary-Android-v1.1.0.apk    ← Android app
```

---

## Troubleshooting

### Docker not found
```powershell
# Solution: Install Docker Desktop
# https://www.docker.com/products/docker-desktop
# After installation, restart your machine
```

### Android build fails in Docker
```powershell
# Clear Docker cache and rebuild
docker system prune -a
.\scripts\build-android-docker.ps1
```

### macOS build not showing in Actions
```
1. Go to GitHub repo → Actions tab
2. Check if workflows are enabled (see Setup #2)
3. Push a new commit to trigger workflow
```

### Database not copied to Windows build
```
# Ensure dictionary.db exists in project root
# Update path in AkkDictionaryApp.iss if needed
```

---

## Version Management

All builds include version numbering:

```powershell
# Build specific version
.\scripts\build-all.ps1 -Version 1.2.0

# Creates:
# - AkkDictionary.exe (Windows)
# - AKK-Dictionary-Android-v1.2.0.apk (Android)
# - AKK-Dictionary-macOS-v1.2.0.dmg (macOS, GitHub Actions)
```

---

## GitHub Release Integration

### Manual Upload
```powershell
# After building locally:
# 1. Create GitHub Release manually
# 2. Upload artifacts to release

# Or use PowerShell script:
.\scripts\upload-release.ps1 -Version 1.1.0 -ReleaseNotes "Your notes here"
```

### Automatic (on Tag)
```powershell
# Push tag to GitHub
git tag v1.1.0
git push origin v1.1.0

# GitHub Actions automatically:
# - Builds all platforms
# - Creates Release
# - Attaches all artifacts
```

---

## Platform-Specific Notes

### Windows
- Uses WPF framework
- Desktop shortcut support via Inno Setup
- Program Files installation
- ~100+ MB total size

### Android
- .apk format for Play Store distribution
- Minimum SDK: Android 21 (5.0)
- Target SDK: Android 34 (14.0)
- ~80 MB typical size

### macOS
- .dmg installer format
- Minimum: macOS 14.0
- Codesigning required for App Store (optional)
- ~150 MB typical size

---

## Next Steps

1. **Test local builds:**
   ```powershell
   .\scripts\build-all.ps1
   ```

2. **Push to GitHub:**
   ```powershell
   git add .github/ Dockerfile.Android docker-compose.yml scripts/
   git commit -m "Add cross-platform Docker build automation"
   git push
   ```

3. **Tag for release:**
   ```powershell
   git tag v1.1.0
   git push origin v1.1.0
   ```

4. **Monitor actions:** https://github.com/aungkokomm/AkkDictionaryApp/actions

5. **Download releases:** https://github.com/aungkokomm/AkkDictionaryApp/releases

---

## Support Matrix

| Platform | Build Location | Requires | Status |
|----------|---|---|---|
| Windows | Local | .NET 8 SDK | ✅ Ready |
| Android | Docker | Docker Desktop | ✅ Ready |
| macOS | GitHub Actions | (Cloud) | ✅ Ready |

---

**Questions?** Check the detailed guides in root directory or GitHub Issues.
