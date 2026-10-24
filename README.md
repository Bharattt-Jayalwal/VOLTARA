# VOLTARA EV Charging Marketplace

VOLTARA is a responsive EV charger discovery and host-sharing prototype built with Next.js App Router, React, TypeScript, Tailwind CSS, Leaflet, Supabase SSR, and PostgreSQL. It includes a local browser demo and an optional connected Supabase mode.

## Start locally

Requirements: Node.js 22.18 or newer and an internet connection for the first dependency install (the included Node test script uses native TypeScript stripping).

```powershell
cd outputs/voltara
pnpm install
Copy-Item .env.example .env.local
pnpm dev
```

Open `http://localhost:3000`. Leave Supabase variables empty to use demo mode. Demo identities, vehicles, charger submissions, availability, favorites, booking requests, and problem reports are saved in the current browser’s `localStorage`. Demo data is fictional. Demo login does not collect passwords or authenticate a real account.

On Windows, you can instead double-click **Start VOLTARA.cmd**. It uses pnpm or Corepack if available, otherwise obtains pnpm through npm, installs dependencies on first run, creates `.env.local` from the blank example if needed, starts the existing Next.js app, and opens it in your browser at `http://localhost:3000`. The root `index.html` is a small local entry page; the full existing application remains the Next.js project. Do not upload `.env.local` or `node_modules` to GitHub.

Useful commands:

```powershell
pnpm typecheck
pnpm lint
pnpm test
pnpm build
pnpm start
```

The exact dependency versions are pinned in `package.json` and `pnpm-lock.yaml`.

## Demo walkthrough

1. Open **Explore** and search/filter the fictional Brooklyn Demo Loop stations. The OpenStreetMap basemap is real geography; the VOLTARA stations are simulated pins and do not represent actual chargers.
2. Open a shared station detail, start a demo driver session at `/login`, and request a future time. The browser checks overlapping demo bookings and records a pending request.
3. Visit `/dashboard` and use the prototype role preview to switch to Host. Open `/host`, submit a charger with a recurring availability window, then switch to the simulated Admin preview at `/admin` to approve it.
4. Return to Driver and request the newly approved shared demo station. Host approval/rejection appears in the Host workspace.
5. From a demo booking, select **Simulate issue** to show compatible backup suggestions with explicitly labeled straight-line distance.

Demo role previews are client-only and grant no permissions to a connected server. They exist to demonstrate screens in the no-credentials environment.

## Connect Supabase

1. Create a non-production Supabase project and set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` in `.env.local`. Older projects can use `NEXT_PUBLIC_SUPABASE_ANON_KEY`. These values are browser publishable keys; never place a service-role key in a `NEXT_PUBLIC_` variable.
2. Apply all three database migrations in timestamp order:

   ```powershell
   pnpm dlx supabase login
   pnpm dlx supabase link --project-ref YOUR_PROJECT_REF
   pnpm dlx supabase db push
   ```

3. Configure Supabase Auth email confirmation, a production SMTP provider, and the local and deployed redirect URLs (for example `http://localhost:3000/auth/callback` and `https://YOUR_DOMAIN/auth/callback`).
4. In Auth URL settings, set the deployed site URL. Configure email templates and test signup, verification, password reset, and sign-out using real email accounts.
5. Optional local seed data is in `supabase/seed.sql`. It is simulated content; use it only in a local or explicitly demo project. It is not automatically applied by migrations.

Supabase user sessions use cookie-based SSR refresh through `proxy.ts`. Protected marketplace routes call `auth.getUser()` and rely on database policies/RPC authorization for the final decision. The contact endpoint alone uses `SUPABASE_SERVICE_ROLE_KEY` on the server to write to a table browser roles cannot read or alter. Keep it server-only and never add a `NEXT_PUBLIC_` prefix.

### Contact form activation

The contact form persists requests to `public.contact_requests` after the launch-hardening migration is applied. Configure `SUPABASE_SERVICE_ROLE_KEY` and a random `CONTACT_HASH_SECRET` of at least 32 characters in `.env.local` and the deployment platform. The secret HMACs email and proxy-IP identifiers for database rate limits; raw IP addresses are not stored. Optional Resend delivery requires `RESEND_API_KEY`, `SUPPORT_EMAIL`, and a verified `RESEND_FROM_EMAIL`. If email is not configured, requests are still saved and the form says delivery is not configured.

The IP rate limit depends on trustworthy client-IP headers from the chosen hosting platform; verify those headers before relying on it. A per-email limit also applies. No automated contact-record retention purge is currently configured.

### Production and local demo separation

An unconfigured local development server uses the clearly labeled browser demo. A production build never falls back to demo identities, role switching, or fictional Brooklyn stations. If Supabase is missing or unreachable, the app shows an unavailable/empty state. The seed file is optional and must not be applied to production.

### First administrator

There is no public admin signup. A project owner must verify the intended user first, copy the exact UUID from Supabase Auth, review it out of band, then grant the role in the Supabase SQL editor:

```sql
insert into public.user_roles (user_id, role, granted_by)
values ('VERIFIED_AUTH_USER_UUID', 'admin', 'PROJECT_OWNER_AUTH_UUID')
on conflict (user_id, role) do nothing;
```

Run this only as a trusted Supabase project owner. Never substitute an email from an untrusted browser request. Admin review RPCs independently check `is_admin()` and record audit entries.

## Architecture

- `app/` — App Router pages, Supabase SSR auth callback, support form/API, and marketplace route handlers, including notifications, vehicle management, and administrator report triage.
- `components/` — responsive UI, Leaflet map, browser demo store and dashboards.
- `lib/chargers.ts` — demo station records, confidence threshold, freshness label and distance calculation.
- `lib/supabase-browser.ts`, `lib/supabase-server.ts`, `proxy.ts` — optional Supabase clients and session refresh.
- `supabase/migrations/` — PostgreSQL schema, indexes, exclusion constraint, RLS policies, booking operations, support storage, launch hardening, and audited report triage.
- `supabase/seed.sql` — explicitly fictional local seed records.
- `tests/logic.test.mjs` — confidence threshold, stale status and distance checks.

The coordinate index uses latitude/longitude B-tree columns because it is adequate for this prototype’s small listings. A production regional search should add PostGIS and a bounded radius query.

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for Vercel and Supabase setup, environment values, and launch checks.

## Limits and launch review

This is a deployable app codebase, but it is not yet an operational charging network. It has no operator/OCPI integration, live status feed, payment provider, real charging control, production routing/geocoding, image upload, push notifications, or dispute operations. Authentication, bookings, charger listings, and support require the external Supabase setup described above. Demo data never claims live telemetry or real completed transactions. Legal pages are factual drafts and still need review by the service owner and qualified counsel.

Before public pilot use, apply and review all three migrations in a staging project; test RLS under multiple real accounts, booking race conditions, admin grants, session refresh, abuse limits, privacy retention, cancellation policy, support escalation, accessibility, and provider licensing/attribution. This archive has no Git history; initialize Git in the extracted project or copy the updated sources into the intended repository.
