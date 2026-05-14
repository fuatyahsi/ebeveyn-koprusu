param(
  [string]$Output = "build\outputs\ebeveyn-koprusu-production-debug.apk",
  [switch]$Release
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($env:SUPABASE_URL)) {
  throw "SUPABASE_URL is required. Set it from Supabase Project Settings > API."
}

if ([string]::IsNullOrWhiteSpace($env:SUPABASE_ANON_KEY)) {
  throw "SUPABASE_ANON_KEY is required. Use the public publishable/anon key, never service_role."
}

$mode = if ($Release) { "release" } else { "debug" }
$flutterArgs = @(
  "build",
  "apk",
  $(if ($Release) { "--release" } else { "--debug" }),
  "--dart-define=APP_ENV=production",
  "--dart-define=APP_NAME=Ebeveyn Köprüsü",
  "--dart-define=SUPABASE_URL=$env:SUPABASE_URL",
  "--dart-define=SUPABASE_ANON_KEY=$env:SUPABASE_ANON_KEY"
)

Write-Host "Building Android $mode with production Supabase URL: $env:SUPABASE_URL"
& flutter @flutterArgs

New-Item -ItemType Directory -Force -Path (Split-Path $Output) | Out-Null
$sourceApk = if ($Release) {
  "build\app\outputs\flutter-apk\app-release.apk"
} else {
  "build\app\outputs\flutter-apk\app-debug.apk"
}
Copy-Item -LiteralPath $sourceApk -Destination $Output -Force
Get-Item -LiteralPath $Output
