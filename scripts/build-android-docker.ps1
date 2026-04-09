#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build Android APK using Docker (fully automated, no local SDK needed)
.DESCRIPTION
    Builds AKK Dictionary for Android using a Docker container with all dependencies
.EXAMPLE
    .\scripts\build-android-docker.ps1
#>

param(
    [string]$Version = "1.1.0",
    [string]$Configuration = "Release"
)

Write-Host "=== AKK Dictionary Android Docker Build ===" -ForegroundColor Cyan
Write-Host "Version: $Version" -ForegroundColor Green
Write-Host "Configuration: $Configuration" -ForegroundColor Green

# Check Docker installation
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

# Get workspace root
$WorkspaceRoot = Split-Path -Parent $PSScriptRoot

Write-Host "`nStep 1: Building Docker image..." -ForegroundColor Cyan
docker build -f "$WorkspaceRoot\Dockerfile.Android" `
    -t akk-dictionary-android-builder:latest `
    "$WorkspaceRoot"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`nStep 2: Running Android build in container..." -ForegroundColor Cyan
docker run --rm `
    -v "$WorkspaceRoot`:/app" `
    akk-dictionary-android-builder:latest `
    bash -c "cd /app && dotnet publish -f net8.0-android -c $Configuration -o ./bin/releases"

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Android build failed in Docker" -ForegroundColor Red
    exit 1
}

# Extract APK
Write-Host "`nStep 3: Locating APK..." -ForegroundColor Cyan
$ApkPath = Get-ChildItem -Path "$WorkspaceRoot\bin\releases" -Filter "*.apk" -Recurse | Select-Object -First 1

if ($ApkPath) {
    Write-Host "`n✅ Android build completed successfully!" -ForegroundColor Green
    Write-Host "APK location: $($ApkPath.FullName)" -ForegroundColor Green
    Write-Host "Size: $([math]::Round($ApkPath.Length / 1MB, 2)) MB" -ForegroundColor Green
    
    # Rename to versioned filename
    $NewName = "AKK-Dictionary-Android-v$Version.apk"
    $NewPath = Join-Path $ApkPath.Directory.FullName $NewName
    Rename-Item -Path $ApkPath.FullName -NewName $NewName
    
    Write-Host "`nRenamed to: $NewName" -ForegroundColor Cyan
    Write-Host "`n📦 Ready for distribution!" -ForegroundColor Green
} else {
    Write-Host "ERROR: APK not found after build" -ForegroundColor Red
    exit 1
}
