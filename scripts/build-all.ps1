#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build all platforms locally (Windows primary, Docker for Android)
.DESCRIPTION
    Executes builds for all supported platforms in sequence
.EXAMPLE
    .\scripts\build-all.ps1
#>

param(
    [string]$Version = "1.1.0",
    [string]$Configuration = "Release",
    [switch]$SkipAndroid,
    [switch]$SkipWindows
)

Write-Host @"
╔══════════════════════════════════════════════════════════╗
║     AKK Dictionary - Multi-Platform Build Automation     ║
╚══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

Write-Host "📋 Build Configuration:" -ForegroundColor Green
Write-Host "   Version: $Version"
Write-Host "   Configuration: $Configuration"
Write-Host "   Skip Android: $SkipAndroid"
Write-Host "   Skip Windows: $SkipWindows"
Write-Host ""

$BuildStartTime = Get-Date
$BuildResults = @()

# Build Windows
if (-not $SkipWindows) {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🪟  BUILDING WINDOWS (v$Version)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $WindowsStart = Get-Date
    
    try {
        dotnet clean -c $Configuration
        dotnet build -c $Configuration -f net8.0-windows
        dotnet publish -c $Configuration -f net8.0-windows -o ./bin/releases/windows
        
        $WindowsExe = Get-ChildItem -Path "./bin/releases/windows" -Filter "AkkDictionary.exe" -Recurse
        if ($WindowsExe) {
            Write-Host "✅ Windows build successful" -ForegroundColor Green
            $BuildResults += @{
                Platform = "Windows"
                Status = "Success"
                Artifact = $WindowsExe.FullName
                Size = "$([math]::Round($WindowsExe.Length / 1MB, 2)) MB"
            }
        } else {
            throw "EXE not found"
        }
    } catch {
        Write-Host "❌ Windows build failed: $_" -ForegroundColor Red
        $BuildResults += @{
            Platform = "Windows"
            Status = "Failed"
            Error = $_
        }
    }
    
    $WindowsDuration = (Get-Date) - $WindowsStart
    Write-Host "⏱️  Duration: $($WindowsDuration.TotalMinutes -as [int])m $($WindowsDuration.Seconds)s`n" -ForegroundColor Yellow
}

# Build Android via Docker
if (-not $SkipAndroid) {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🤖 BUILDING ANDROID VIA DOCKER (v$Version)" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    $AndroidStart = Get-Date
    
    try {
        # Check Docker
        $DockerCheck = docker --version
        if (-not $DockerCheck) {
            throw "Docker not available"
        }
        
        # Run build script
        & "$PSScriptRoot\build-android-docker.ps1" -Version $Version -Configuration $Configuration
        
        $ApkFile = Get-ChildItem -Path "./bin/releases" -Filter "*.apk" -Recurse | Select-Object -First 1
        if ($ApkFile) {
            Write-Host "✅ Android build successful" -ForegroundColor Green
            $BuildResults += @{
                Platform = "Android"
                Status = "Success"
                Artifact = $ApkFile.FullName
                Size = "$([math]::Round($ApkFile.Length / 1MB, 2)) MB"
            }
        } else {
            throw "APK not found"
        }
    } catch {
        Write-Host "⚠️  Android Docker build skipped: $_" -ForegroundColor Yellow
        Write-Host "   To enable: Install Docker Desktop" -ForegroundColor Yellow
        $BuildResults += @{
            Platform = "Android"
            Status = "Skipped"
            Reason = $_
        }
    }
    
    $AndroidDuration = (Get-Date) - $AndroidStart
    Write-Host "⏱️  Duration: $($AndroidDuration.TotalMinutes -as [int])m $($AndroidDuration.Seconds)s`n" -ForegroundColor Yellow
}

# Summary
$TotalDuration = (Get-Date) - $BuildStartTime
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    BUILD SUMMARY" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$BuildResults | ForEach-Object {
    Write-Host "`n📦 $($_.Platform)" -ForegroundColor Green
    Write-Host "   Status: $($_.Status)"
    if ($_.Status -eq "Success") {
        Write-Host "   Artifact: $($_.Artifact)"
        Write-Host "   Size: $($_.Size)"
    } else {
        Write-Host "   Reason: $($_.Reason -or $_.Error)"
    }
}

Write-Host "`n⏱️  Total Duration: $($TotalDuration.TotalMinutes -as [int])m $($TotalDuration.Seconds)s" -ForegroundColor Yellow
Write-Host "`n✨ Build pipeline completed!" -ForegroundColor Green
Write-Host "`n📂 Releases directory: $(Resolve-Path ./bin/releases)" -ForegroundColor Cyan
