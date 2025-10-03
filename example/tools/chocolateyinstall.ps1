# Admin check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This package must be run as Administrator."
    exit 1
}

$ErrorActionPreference = 'Stop'

# Load config
$configPath = Join-Path $PSScriptRoot 'config.json'
$config = Get-Content $configPath | ConvertFrom-Json

# Install directory
$installDir = Join-Path "C:\Program Files" $config.'app name'

# Create install directory
if (-not (Test-Path $installDir)) {
    Write-Output "Creating install directory: $installDir"
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# Extract ZIP
$zipPath = Join-Path $PSScriptRoot $config.'zip name'
Write-Output "Extracting $zipPath to $installDir"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $installDir)

# Create global Start Menu shortcut
if ($config.'start menu') {
    $globalStartMenu = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs\$($config.'app name').lnk"
    Write-Output "Creating global Start Menu shortcut: $globalStartMenu"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($globalStartMenu)
    $shortcut.TargetPath = Join-Path $installDir $config.'Main Path'
    $shortcut.Save()
}

# Create per-user Startup shortcuts
if ($config.'startup') {
    $excludedUsers = @('Public','Default','Default User','All Users')

    $users = Get-ChildItem 'C:\Users' | Where-Object { 
        ($_.PSIsContainer) -and ($excludedUsers -notcontains $_.Name) -and (Test-Path (Join-Path $_.FullName "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"))
    }

    foreach ($user in $users) {
        $userStartup = Join-Path $user.FullName "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\$($config.'app name').lnk"
        Write-Output "Creating Startup shortcut for user $($user.Name): $userStartup"
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($userStartup)
        $shortcut.TargetPath = Join-Path $installDir $config.'Main Path'
        $shortcut.Save()
    }
}

Write-Output "Installation complete."
