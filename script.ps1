
$ErrorActionPreference = "Stop"

$InstallDir = $PSScriptRoot
$TempDir = Join-Path $InstallDir "temp"

$NvimZipUrl = "https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-win64.zip"
$NvimZip = Join-Path $TempDir "nvim-win64.zip"

$AhkInstallerUrl = "https://github.com/AutoHotkey/AutoHotkey/releases/download/v2.0.24/AutoHotkey_2.0.24_setup.exe"
$AhkInstaller = Join-Path $TempDir "AutoHotkey_2.0.24_setup.exe"
$AhkDir = Join-Path $TempDir "ahk"

$NvimConfigDir = Join-Path $env:LOCALAPPDATA "nvim"
$NvimConfig = Join-Path $NvimConfigDir "init.vim"

Set-WinUserLanguageList -LanguageList es-419 -Force
	
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

Invoke-WebRequest `
    -Uri $NvimZipUrl `
    -OutFile $NvimZip

Expand-Archive `
    -Path $NvimZip `
    -DestinationPath $TempDir `
    -Force

New-Item -ItemType Directory -Path $NvimConfigDir -Force | Out-Null

@"
:colorscheme torte
:set tabstop=2
:set shiftwidth=2
:set nowrap
:set relativenumber
:set number

"@ | Set-Content -Path $NvimConfig -Encoding UTF8

Invoke-WebRequest `
    -Uri $AhkInstallerUrl `
    -OutFile $AhkInstaller

New-Item -ItemType Directory -Path $AhkDir -Force | Out-Null

Write-Host "Instalando autohotkey en temp"

Start-Process `
    -FilePath $AhkInstaller `
    -ArgumentList "/silent", "/to", "`"$AhkDir`"" `
    -Wait `
    -NoNewWindow

$CapsLockScript = Join-Path $InstallDir "capslock-rebind.ahk"
$CapsLockDestination = Join-Path $TempDir "capslock-rebind.ahk"

if (Test-Path $CapsLockScript) {
    Move-Item `
        -Path $CapsLockScript `
        -Destination $CapsLockDestination `
        -Force
}

$AutoHotkeyExe = Get-ChildItem `
    -Path $AhkDir `
    -Filter "AutoHotkey*.exe" `
    -File `
    -Recurse |
    Where-Object {
        $_.Name -match "^AutoHotkey(64|32)?\.exe$"
    } |
    Select-Object -First 1

if ($AutoHotkeyExe -and (Test-Path $CapsLockDestination)) {
    Start-Process `
        -FilePath $AutoHotkeyExe.FullName `
        -ArgumentList "`"$CapsLockDestination`""
}
elseif (Test-Path $CapsLockDestination) {
    Start-Process `
        -FilePath $CapsLockDestination
}

$NvimExe = Get-ChildItem `
    -Path $TempDir `
    -Filter "nvim.exe" `
    -File `
    -Recurse |
    Select-Object -First 1

if ($NvimExe) {
    $StartMenuDir = Join-Path `
        $env:APPDATA `
        "Microsoft\Windows\Start Menu\Programs"

    New-Item `
        -ItemType Directory `
        -Path $StartMenuDir `
        -Force | Out-Null

    $ShortcutPath = Join-Path $StartMenuDir "Neovim.lnk"

    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($ShortcutPath)

    $Shortcut.TargetPath = $NvimExe.FullName
    $Shortcut.WorkingDirectory = Split-Path $NvimExe.FullName
    $Shortcut.IconLocation = "$($NvimExe.FullName),0"
    $Shortcut.Save()
}

Write-Host "Podés borrar el repositorio usando Remove-Item -Recurse -Force `"$InstallDir`""
exit
