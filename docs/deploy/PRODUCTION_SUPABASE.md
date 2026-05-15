# Production Supabase Runbook

## Create The Project

1. Supabase Dashboard > New project.
2. Region: prefer Central EU / Frankfurt for Turkey-facing latency.
3. Save the database password in a password manager.
4. After the project is ready, collect:
   - Project ref
   - Project URL
   - Publishable or anon key
   - Database password

Do not put service role keys into Flutter builds.

## Link And Push

```powershell
supabase projects list
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

## Deploy Edge Functions

```powershell
npm run supabase:functions:deploy
```

Ebeveyn Asistanı vizyon kapsamından kaldırıldı; ilk canlı smoke test için LLM
API zorunlu değildir. Vizyon özelliklerinin servis listesi için
`docs/deploy/VISIONARY_EXTERNAL_SERVICES.md` dosyasını kullan.

## Build A Production-Pointing APK

```powershell
$env:SUPABASE_URL="https://YOUR_PROJECT_REF.supabase.co"
$env:SUPABASE_ANON_KEY="YOUR_PUBLIC_KEY"
.\scripts\build_android_production.ps1
```

For release signing, add Android signing config separately. Keep `android/key.properties`,
`.jks`, `.keystore`, and `.env.production` out of Git.
