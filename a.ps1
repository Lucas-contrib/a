# setup-neovim-ahk.ps1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$user = $env:USERNAME
$tempDir = Join-Path $env:TEMP "nvim-ahk-setup"
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null

Push-Location $tempDir

try {
    Write-Host "Downloading Neovim..."
    $nvimUrl = "https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-win64.zip"
    $nvimZip = Join-Path $tempDir "nvim-win64.zip"
    Invoke-WebRequest -Uri $nvimUrl -OutFile $nvimZip

    Write-Host "Extracting Neovim using tar..."
    Push-Location $tempDir
    & tar -xf $nvimZip
    Pop-Location

    $nvimConfigDir = Join-Path $env:LOCALAPPDATA "nvim"
    New-Item -Path $nvimConfigDir -ItemType Directory -Force | Out-Null

    $initVim = Join-Path $nvimConfigDir "init.vim"
    @"
:colorscheme torte
:set tabstop=2
:set shiftwidth=2
:set nowrap
"@ | Out-File -FilePath $initVim -Encoding utf8

    Write-Host "Downloading AutoHotkey installer..."
    $ahkUrl = "https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.24/AutoHotkey_2.0.24_setup.exe"
    $ahkInstaller = Join-Path $tempDir "AutoHotkey_setup.exe"
    Invoke-WebRequest -Uri $ahkUrl -OutFile $ahkInstaller

    $ahkTempDir = Join-Path $tempDir "ahk"
    New-Item -Path $ahkTempDir -ItemType Directory -Force | Out-Null
    $args = "/silent", "/to=$tempDir"
    Start-Process -FilePath $ahkInstaller -ArgumentList "/SILENT","/TO=`"$ahkTempDir`"" -Wait


    # Copy the bundled capslock script from this repo (assumes script is next to this PS1).
    $scriptRepoDir = Split-Path -Parent $PSCommandPath
    $capsSrc = Join-Path $scriptRepoDir "capslock-rebind.ahk"
    if (-Not (Test-Path $capsSrc)) {
        Write-Error "capslock-rebind.ahk not found in repository root."
    }
    $capsDest = Join-Path $tempDir "capslock-rebind.ahk"
    Copy-Item -Path $capsSrc -Destination $capsDest -Force

    Write-Host "Launching capslock-rebind.ahk..."
    Start-Process -FilePath $capsDest

    Write-Host "Setup complete. Temporary working directory: $tempDir"
    Write-Host "When finished you can remove it with: Remove-Item -Recurse -Force `"$tempDir`""
}
catch {
    Write-Error "Setup failed: $_"
}
finally {
    Pop-Location
}
