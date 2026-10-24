# Deployment guide

## Supabase project

1. Create a production project in the intended region and set the database password outside source control.
2. Link the repository directory with the Supabase CLI, then run `supabase db push` to apply all three migrations in timestamp order: `202610210001_initial_marketplace.sql`, `202610230001_launch_hardening.sql`, and `202610240001_backend_completion.sql`. Use a staging project first and review the column grants and RLS behavior before applying to production.
3. Inspect the generated tables, policies and functions in the Supabase dashboard. Configure Auth email confirmation, SMTP delivery, password reset, and redirect URLs for both the final domain and any staging domain.
4. Grant the first administrator to a verified user using the owner-only SQL procedure in the README. Review the UUID before executing it.
5. Do not apply `supabase/seed.sql` to production. Keep production charger records sourced from verified hosts or authorized providers.

## Vercel

1. Import the project directory `outputs/voltara` into Vercel.
2. Set the production and preview environment variables `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, and the actual canonical `NEXT_PUBLIC_SITE_URL`. Set `NEXT_PUBLIC_MAP_TILE_URL` only to a tile provider whose usage policy and expected load support the deployment. The default OpenStreetMap endpoint is a prototype choice with visible attribution, not a production tile-service agreement.
3. Configure `SUPABASE_SERVICE_ROLE_KEY` and a randomly generated `CONTACT_HASH_SECRET` (at least 32 characters) as server-only variables for the contact endpoint. Never expose either in browser variables. If email is desired, also configure `RESEND_API_KEY`, `SUPPORT_EMAIL`, and a verified `RESEND_FROM_EMAIL`.
4. Set the build command to `pnpm build` and output mode to the default Next.js deployment. Deploy a preview first and exercise signup, email confirmation, a host submission, an admin approval, a reservation conflict, cancellation, and RLS across separate users.
5. Add the final domain to Supabase Auth URL configuration and mail templates, deploy production, then repeat the smoke workflow on that domain.

The repository archive currently contains no `.env.local`, Supabase project credentials, Vercel CLI session, or Git history. A production URL cannot be claimed until a real project/domain is configured and a deployment is verified.

## Before a real pilot

- Use a contracted geocoder/routing provider and a compliant map tile service; confirm commercial use and attribution.
- Obtain charger source and operator rights, and document data freshness for every provider.
- Add production rate limiting, monitoring, backup/restore, retention, incident response, support, and privacy/legal materials.
- Add image storage policies and upload validation before enabling charger photos.
- Integrate payment checkout only after merchant onboarding; verify webhooks and reconciliation before showing any paid state.
- Review the security checklist in `FEATURE_STATUS.md`; the existing RLS and RPCs are implementation controls, not a security certification.
