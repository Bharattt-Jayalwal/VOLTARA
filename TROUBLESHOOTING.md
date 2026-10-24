# Troubleshooting

- **`pnpm` is not recognized:** install pnpm 9+ or use `corepack enable` with a supported Node.js 20.9+ installation.
- **The local app says “refresh” or “site can’t be reached”:** the local server is not running. Double-click `Start VOLTARA.cmd`, wait for the “VOLTARA is ready” message, then open `http://localhost:3000/`. The `index.html` hosted-preview button opens the public page without a local server.
- **A local account cannot log in:** without Supabase variables, use **Continue as demo driver**. Demo mode intentionally has no password authentication.
- **Email verification or reset link fails:** verify the Supabase site URL, redirect allow-list, SMTP provider, and `/auth/callback` domain. The user must complete email verification before password sign-in.
- **Supabase route returns “not configured”:** confirm `.env.local` is in the project root, variable names match `.env.example`, and restart the dev server after changing environment variables.
- **Listing submission fails:** apply the latest migration, confirm the user session is valid, use a supported connector, choose at least one availability day, and enter a valid timezone and coordinate pair.
- **Booking is rejected:** only approved shared chargers can be booked. The requested future time must fit the host’s local availability and must not overlap another pending or confirmed booking.
- **Admin queue is empty:** a project owner must grant `admin` to a verified Auth UUID. A browser role selector cannot grant production permissions.
- **Map background is missing:** use the results list while the configured OpenStreetMap tile endpoint is unavailable. Production should use a contracted tile provider and comply with its limits.
- **Demo listings disappear:** clear browser storage and reload to restore the bundled simulated stations; locally entered demo records are saved in browser storage.
- **Build fails on a restricted Windows machine:** use the project `.npmrc` hoisted layout and run `pnpm install`. If package scripts are blocked by corporate policy, run the local `node_modules/.bin/tsc`, `eslint`, or `next` executable through Node directly.
