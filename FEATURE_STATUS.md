# Feature status and pre-launch review

## Implemented for this prototype

- Responsive VOLTARA landing, host information, how-it-works, about, privacy and terms pages, plus the Supabase auth callback route.
- Leaflet map, list alternative, local search/filter, charger detail pages, connector/power/access details, route-link generation, and permission-based browser location.
- Supabase email/password signup, verification callback, password sign-in, reset email, cookie session refresh, and server-side identity checks when configured.
- PostgreSQL migrations for the requested marketplace entities, indexes, booking overlap exclusion constraint, RLS, audit records, and role-checked booking/charger RPCs.
- Host charger registration with recurring weekday/time window, pending review, and admin approve/reject workflow in connected mode.
- Booking request, transactional overlap/availability checks, host accept/reject, driver cancellation, in-app notifications, demo-only failure path, and browser backup suggestions.
- Driver vehicle profiles and charger favorites. Demo mode saves these in local browser storage; connected mode saves favorites and bookings to Supabase.
- Connected backend APIs for a driver's notification inbox and owner-scoped vehicle updates/deletion. Notification read state is changed through the existing owner-checked database RPC.
- Admin charger-report queue and triage API. Triage is administrator-only, restricts status transitions, and records each change in the audit log.
- Driver display name and optional phone profile fields. The phone number is user-entered and is not treated as verified contact data.
- Confidence score threshold and explicit stale status label. Unit tests cover the score threshold/range and distance helpers.
- `.env.example`, migration, local demo seed, setup/deployment/troubleshooting docs.
- Production/local-demo separation: production does not use browser demo identities, fake role switching, or bundled fictional chargers when Supabase is missing. Public directory queries filter out rows flagged as demo.
- A support page and server endpoint validate requests, store them in a RLS-protected contact table, apply database-backed email/IP rate limits, and optionally send through Resend. Delivery status is reported honestly.
- Launch hardening migration: public charger column grants exclude private street addresses, client edits cannot change verification/status fields, listing review no longer implies host identity verification, report writes are capped, and only the notification owner can mark `read_at`.
- Public SEO files are generated from `NEXT_PUBLIC_SITE_URL`; private workspaces and account routes are marked noindex, and a VOLTARA favicon plus baseline security headers are present.

## Simulated or limited

- Bundled demo stations, map markers, status timestamps, rates, verification examples, and host activity are fictional and marked as demo. They are not physical chargers or telemetry.
- Demo identities, role switching, bookings, reports, availability, and listings are browser-local only; there is no real account or server authorization in demo mode.
- The “simulate issue” action is a demo-only backup scenario. Backup distances are straight-line distances, not travel distances or ETAs.
- Hero and charger art are procedural SVG/CSS illustrations; no WebGL/Three.js scene or external 3D model is used.
- Map search filters loaded station text; it is not an address geocoder. Directions open an external map app; no route or detour is calculated.
- Connected explore uses approved Supabase charger listings, but public provider data is not connected and booking is limited to shared host listings.
- Status confidence in this prototype is computed from explicit host/session inputs but connected provider evidence ingestion and explainability history are not yet implemented.
- Earnings remain blank. Payments are not collected. No refund, settlement, or charger start action is simulated as real.
- Legal copy is a prototype placeholder, not reviewed policy.

## Not implemented

- OCPI/operator onboarding, public network ingestion, tariffs, live charger status, reservations for public stations, charging-session control.
- Payment provider, signed payment webhooks, settlement, refunds, and fee accounting.
- Charger images/storage, geocoding, production routing, clustering, notifications over email/push, host maintenance workflow, user moderation, and full admin user/dispute tools. Report triage has an API but no dedicated admin screen yet.
- Availability editing after submission, booking completion/in-progress lifecycle, booking expiry job, and general API/Auth rate limiting. Contact and charger-report endpoints have database-backed rate limits; other actions still need platform-wide abuse controls.
- Notification preference controls, host profile verification, vehicle compatibility catalog, and full host listing/schedule edits after submission.
- PostGIS radius search; current coordinate index is a latitude/longitude B-tree for small prototype datasets.
- Support inbox/admin triage UI. Requests persist in Supabase and optional Resend delivery can notify a configured support address; staff workflow/retention still needs setup.
- Automated end-to-end/RLS integration tests against a live Supabase project.

## Security checks still needed before public launch

- Run RLS assertions using separate driver, host, and administrator accounts; verify every exposed table and function, including attempted role escalation.
- Apply the new hardening migration in staging and verify its column-level grants with anonymous, driver, host, and administrator sessions before production.
- Verify the support IP headers from the actual deployment platform and configure retention/access for `contact_requests`.
- Load-test simultaneous booking requests for the same charger/time and validate exclusion handling across database sessions.
- Test Auth email confirmation, password reset, cookie refresh, logout and revocation on production domains.
- Review security-definer function grants/search paths and SQL policies with an independent reviewer; verify audit logs cannot be written or altered by a client.
- Add API rate limiting, abuse controls, upload scanning/storage policies, logging/alerting, database backup/restore checks, incident handling and privacy retention.
- Test screen-reader semantics, keyboard navigation, reduced motion, contrast, responsive behavior, and map fallbacks on supported mobile browsers.
- Confirm map/geocoder/operator data licensing, local charger/host legal requirements, privacy notices, consumer cancellation terms, and support processes.
