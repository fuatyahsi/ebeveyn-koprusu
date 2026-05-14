# IMPLEMENTATION NOTES

## Mock Implementations

- `tone-assistant` currently uses rule-based mock scoring and suggestion text.
- `ocr-expense-receipt` returns an empty extraction result until an OCR provider is configured.
- `generate-report-pdf` creates report metadata, hash and verification token; real PDF rendering/storage upload is represented by the function boundary.
- `send-notification` sanitizes and queues a response shape; real FCM delivery credentials are not configured.
- Flutter repositories currently use in-memory mock providers so the app can open without Supabase credentials.
- Admin panel is an operational scaffold with masked-support assumptions, not a production backoffice.

## Required Production Configuration

- Supabase project URL, anon key and service role key must be configured outside the Flutter client.
- Supabase CLI must be installed to apply migrations and deploy Edge Functions.
- Firebase Android/iOS platform configuration files must be added before push notification builds.
- RevenueCat products, offerings and webhook secret must be created in RevenueCat dashboard.
- App Store and Google Play subscription products must match the entitlement mapping.
- Privacy Policy, Terms, KVKK and account deletion URLs must be published before store review.
- Real PDF rendering should be added inside `generate-report-pdf`.
- Real OCR provider should be connected inside `ocr-expense-receipt`.
- Rate limiting and abuse monitoring should be enforced at Edge Function/API gateway level.

## Intentional Product Constraints

- No child login account.
- No live location tracking.
- No legal guarantee language.
- No message update/delete.
- Sensitive push notification bodies are masked.
- Personal journal records are owner-only by RLS.
