#requires -RunAsAdministrator
param(
  [switch]$SkipDockerInstall,
  [switch]$SkipWslInstall,
  [switch]$SkipSupabaseStart
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) {
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Add-PathIfExists($PathToAdd) {
  if ((Test-Path $PathToAdd) -and ($env:Path -notlike "*$PathToAdd*")) {
    $env:Path = "$PathToAdd;$env:Path"
  }
}

function Test-Command($Name) {
  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Enable-DockerTcpDaemon {
  $settingsPath = Join-Path $env:APPDATA "Docker\settings-store.json"
  if (-not (Test-Path $settingsPath)) {
    return
  }

  $settings = Get-Content -Raw -LiteralPath $settingsPath | ConvertFrom-Json
  $settings | Add-Member -NotePropertyName exposeDockerAPIOnTCP2375 -NotePropertyValue $true -Force
  $settings | Add-Member -NotePropertyName ExportInsecureDaemon -NotePropertyValue $true -Force
  $settings | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $settingsPath -Encoding UTF8
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

Add-PathIfExists "$env:USERPROFILE\scoop\shims"
Add-PathIfExists "$repoRoot\node_modules\.bin"
Add-PathIfExists "C:\Program Files\Docker\Docker\resources\bin"

Write-Step "Checking Supabase CLI"
if (-not (Test-Command supabase)) {
  if (Test-Path "$env:USERPROFILE\scoop\shims\supabase.exe") {
    Add-PathIfExists "$env:USERPROFILE\scoop\shims"
  } else {
    npm.cmd install supabase --save-dev
    Add-PathIfExists "$repoRoot\node_modules\.bin"
  }
}
supabase --version

if (-not $SkipWslInstall) {
  Write-Step "Enabling WSL and Virtual Machine Platform"
  dism.exe /online /Enable-Feature /FeatureName:Microsoft-Windows-Subsystem-Linux /All /NoRestart
  dism.exe /online /Enable-Feature /FeatureName:VirtualMachinePlatform /All /NoRestart

  Write-Step "Installing WSL package"
  winget install --id Microsoft.WSL -e --source winget --accept-source-agreements --accept-package-agreements --silent

  Write-Step "Configuring WSL 2"
  wsl --set-default-version 2
}

if (-not $SkipDockerInstall) {
  Write-Step "Installing Docker Desktop"
  if (-not (Test-Command docker)) {
    winget install --id Docker.DockerDesktop -e --source winget --accept-source-agreements --accept-package-agreements --silent
    Add-PathIfExists "C:\Program Files\Docker\Docker\resources\bin"
  }
}

Write-Step "Starting Docker Desktop"
$dockerDesktop = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
if (Test-Path $dockerDesktop) {
  Enable-DockerTcpDaemon
  Start-Process -FilePath $dockerDesktop
}

if (-not (Test-Command docker)) {
  throw "Docker CLI was not found. Open a new Administrator PowerShell or restart Windows, then run this script again with -SkipDockerInstall."
}

Write-Step "Waiting for Docker Engine"
$deadline = (Get-Date).AddMinutes(8)
do {
  Start-Sleep -Seconds 5
  & docker info *> $null
  $ready = $LASTEXITCODE -eq 0
} until ($ready -or (Get-Date) -gt $deadline)

if (-not $ready) {
  throw "Docker Engine did not become ready. If WSL or Virtual Machine Platform was just enabled, restart Windows, open Docker Desktop, complete first-run setup, then run: .\scripts\setup_local_supabase_windows.ps1 -SkipDockerInstall -SkipWslInstall"
}

Write-Step "Checking Docker TCP daemon access"
$tcpDeadline = (Get-Date).AddMinutes(2)
do {
  Start-Sleep -Seconds 3
  $tcpReady = (Test-NetConnection -ComputerName 127.0.0.1 -Port 2375 -WarningAction SilentlyContinue).TcpTestSucceeded
} until ($tcpReady -or (Get-Date) -gt $tcpDeadline)

if (-not $tcpReady) {
  Write-Warning "Docker Engine is running, but tcp://localhost:2375 is not reachable. Supabase can still run, but analytics/vector may restart on Windows until Docker Desktop's 'Expose daemon on tcp://localhost:2375 without TLS' setting is enabled."
}

if (-not $SkipSupabaseStart) {
  Write-Step "Cleaning existing local Supabase containers"
  supabase stop --no-backup

  Write-Step "Starting local Supabase"
  supabase start

  Write-Step "Applying migrations"
  supabase db reset

  Write-Step "Local Supabase status"
  supabase status
}
