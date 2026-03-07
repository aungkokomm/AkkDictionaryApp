# Build and Package Script for AKK Dictionary
# This script builds the application and creates an installer

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AKK Dictionary Build & Package Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$AppName = "AKK En-to-MM Dictionary"
$Version = "1.0.0"
$PublishPath = "bin\Release\net8.0-windows\win-x64\publish"
$OutputDir = "bin\Installers"
$ExecutableName = "AKK En-to-MM Dictionary.exe"

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Created output directory: $OutputDir" -ForegroundColor Green
}

# Check if publish folder exists
if (-not (Test-Path $PublishPath)) {
    Write-Host "ERROR: Publish folder not found at $PublishPath" -ForegroundColor Red
    Write-Host "Running: dotnet publish -c Release -r win-x64 --self-contained" -ForegroundColor Yellow
    dotnet publish -c Release -r win-x64 --self-contained
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
}

# Verify executable exists
$ExePath = Join-Path $PublishPath $ExecutableName
if (-not (Test-Path $ExePath)) {
    Write-Host "ERROR: Executable not found at $ExePath" -ForegroundColor Red
    exit 1
}

Write-Host "Executable found: $ExePath" -ForegroundColor Green
Write-Host "File size: $(([System.IO.FileInfo]$ExePath).Length / 1MB).2 MB" -ForegroundColor Green
Write-Host ""

# Copy executable to Installers directory for easy access
$ExeOutputPath = Join-Path $OutputDir $ExecutableName
Copy-Item -Path $ExePath -Destination $ExeOutputPath -Force
Write-Host "Copied executable to: $ExeOutputPath" -ForegroundColor Green
Write-Host ""

# Check for Inno Setup
$InnoSetupPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
$InnoSetupPath2 = "C:\Program Files\Inno Setup 6\ISCC.exe"

if (Test-Path $InnoSetupPath) {
    $InnoPath = $InnoSetupPath
} elseif (Test-Path $InnoSetupPath2) {
    $InnoPath = $InnoSetupPath2
} else {
    Write-Host "WARNING: Inno Setup not found. Installer will not be created." -ForegroundColor Yellow
    Write-Host "To create an installer, please install Inno Setup from:" -ForegroundColor Yellow
    Write-Host "https://jrsoftware.org/isinfo.php" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can still distribute the executable from: $ExeOutputPath" -ForegroundColor Green
    Write-Host ""
    exit 0
}

# Build installer
Write-Host "Creating installer using Inno Setup..." -ForegroundColor Cyan
& $InnoPath "AkkDictionaryApp.iss"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Build Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Files created in: $OutputDir" -ForegroundColor Cyan
    Write-Host ""
    Get-ChildItem $OutputDir | ForEach-Object {
        $Size = ([System.IO.FileInfo]$_.FullName).Length
        if ($Size -gt 1MB) {
            $SizeStr = "{0:N2} MB" -f ($Size / 1MB)
        } else {
            $SizeStr = "{0:N2} KB" -f ($Size / 1KB)
        }
        Write-Host "  - $($_.Name) ($SizeStr)" -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "You can now distribute these files to users." -ForegroundColor Green
} else {
    Write-Host "ERROR: Installer creation failed!" -ForegroundColor Red
    exit 1
}
