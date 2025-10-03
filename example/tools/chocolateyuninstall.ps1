# Admin check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This package must be uninstalled as Administrator."
    exit 1
}

$ErrorActionPreference = 'Stop'

# Load config
$configPath = Join-Path $PSScriptRoot 'config.json'
$config = Get-Content $configPath | ConvertFrom-Json

# Paths
$installDir = Join-Path "C:\Program Files" $config.'app name'
$startMenuShortcut = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\$($config.'app name').lnk"
$startupShortcut = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\StartUp\$($config.'app name').lnk"

# Remove install folder
if (Test-Path $installDir) { Remove-Item -LiteralPath $installDir -Recurse -Force }

# Remove Start Menu shortcut
if (Test-Path $startMenuShortcut) { Remove-Item -LiteralPath $startMenuShortcut -Force }

# Remove Startup shortcut
if (Test-Path $startupShortcut) { Remove-Item -LiteralPath $startupShortcut -Force }

Write-Output "Uninstall complete."
