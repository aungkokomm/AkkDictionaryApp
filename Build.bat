@echo off
REM Build and Package Script for AKK Dictionary (Batch Version)
REM This script builds the application executable

setlocal enabledelayedexpansion

cls
echo ========================================
echo AKK Dictionary Build Script
echo ========================================
echo.

set PublishPath=bin\Release\net8.0-windows\win-x64\publish
set OutputDir=bin\Installers
set ExecutableName=AKK En-to-MM Dictionary.exe

REM Create output directory if it doesn't exist
if not exist "%OutputDir%" (
    mkdir "%OutputDir%"
    echo Created output directory: %OutputDir%
)

REM Check if publish folder exists
if not exist "%PublishPath%" (
    echo Building Release executable...
    echo This may take a few minutes...
    echo.
    dotnet publish -c Release -r win-x64 --self-contained
    if errorlevel 1 (
        echo.
        echo ERROR: Build failed!
        pause
        exit /b 1
    )
)

REM Check if executable exists
if not exist "%PublishPath%\%ExecutableName%" (
    echo ERROR: Executable not found at %PublishPath%\%ExecutableName%
    pause
    exit /b 1
)

echo Executable found: %PublishPath%\%ExecutableName%

REM Get file size
for %%A in ("%PublishPath%\%ExecutableName%") do (
    set "FileSize=%%~zA"
)
set /a FileSizeMB=%FileSize% / 1048576
echo File size: %FileSizeMB% MB
echo.

REM Copy executable to Installers directory
echo Copying executable to Installers folder...
copy "%PublishPath%\%ExecutableName%" "%OutputDir%\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy executable
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo Executable location: %OutputDir%\%ExecutableName%
echo.
echo You can now:
echo 1. Run the executable directly
echo 2. Create an installer using Inno Setup
echo 3. Distribute the executable to users
echo.
echo To create an installer:
echo - Install Inno Setup from https://jrsoftware.org/isinfo.php
echo - Right-click AkkDictionaryApp.iss and select "Compile with Inno Setup"
echo.
pause
