# CRR Criteria Tools — Admin Reference

**Last updated:** 2026-05-16
**Criteria Viewer:** v5.3.0
**Triage Advisor:** v2.1.1
**Admin Tool:** v1.5.8

Internal reference — not for external distribution. Contains infrastructure details, admin endpoints, and authentication information.

---

## Infrastructure

| Component | Details |
|-----------|---------|
| Main site worker | `vite-react-template` on Cloudflare Workers |
| Main site URL | `https://iteratio.nz` |
| API worker | `crr-criteria-api` on Cloudflare Workers |
| API URL | `https://crr-criteria-api.fk4dsrmq5r.workers.dev` |
| D1 database | `crr-criteria` (ID: `1a8307f9-69e9-4315-a8f3-7f6737dd9c55`) |
| KV namespace | ID: `d8e1a512828d4dd7981d7b241213f396` |
| Cloudflare account | `13d95cc559c1c6a7e6808d279d668b75` |

---

## Tool URLs

| Tool | URL |
|------|-----|
| Criteria Viewer | `.../crr-criteria/viewer/` |
| Triage Advisor | `.../crr-criteria/triage/` |
| Admin Tool | `.../crr-criteria/admin/` |

---

## Admin Tool authentication

### Architecture overview

Admin auth uses a two-layer stack:

```
Browser (iteratio.nz/crr-criteria/admin)
    │
    │  Same-origin fetch to /crr-api/api/...
    ▼
Cloudflare Access (iteratio.nz)
    │  Injects cf-access-jwt-assertion (signed Access token)
    │  Returns 302 to login if no valid session
    ▼
Main worker proxy  (src/worker/index.ts)
    │  Verifies the token (signature against the team certs, ACCESS_AUD,
    │  issuer, expiry) — 401 on admin paths if it does not verify (SR-15)
    │  Strips client identity headers; forwards the token's email
    │  Injects x-admin-key from ADMIN_KEY secret
    ▼
API worker  (crr-criteria-api.fk4dsrmq5r.workers.dev)
    │  Validates x-admin-key
    ▼
D1 / KV
```

The admin tool never sends an admin key from the browser. The proxy injects it server-side from the `ADMIN_KEY` secret. The browser only needs a valid Cloudflare Access session.

`ACCESS_AUD` (the Access application's Audience tag) and `ACCESS_TEAM_DOMAIN` (`https://crr-admin.cloudflareaccess.com`) are vars in `wrangler.json`. If the Access application is ever recreated, its AUD tag changes, and `ACCESS_AUD` must be updated before admin works again. Local two-worker dev has no Access, so `.dev.vars` sets `ACCESS_DEV_BYPASS=true`. The proxy then takes `x-admin-email` instead, on localhost only (SR-15).

### Cloudflare Access application

| Field | Value |
|-------|-------|
| Application name | vite-react-template.fk4dsrmq5r.workers.dev |
| Application ID | `0c011c32-833d-45dc-8304-068e4b6064c1` |
| Team domain | `crr-admin.cloudflareaccess.com` |
| Auth method | Email OTP |
| Policy | CRR Admin Users (4 email addresses, 0 exclusions) |

**Public hostnames covered by the Access app (all four are required):**

| Hostname | Path |
|----------|------|
| `vite-react-template.fk4dsrmq5r.workers.dev` | `/crr-criteria/admin` |
| `iteratio.nz` | `/crr-criteria/admin` |
| `iteratio.nz` | `/crr-api/*` |
| `vite-react-template.fk4dsrmq5r.workers.dev` | `/crr-api/*` |

The fourth row was added on 2026-10-06 (SR-15). Its Subdomain box must read `vite-react-template`; left empty, it protects the bare `fk4dsrmq5r.workers.dev`, not the app. Workers Builds Preview URLs are turned off on `vite-react-template` (SR-15) by `"preview_urls": false` in `wrangler.json`. The dashboard toggle alone does not hold, because each `wrangler deploy` re-applies the config. They carry the production worker's bindings and secrets and are not covered by Access.

The third row (`/crr-api/*`) is critical — it ensures CF Access injects the email header on the proxy requests that the admin tool makes. Without it, every API call gets redirected to the Access login page with a CORS error. Use the broader `/crr-api/*` wildcard, not `/crr-api/api/*` — CF Access wildcard matching does not reliably cover nested paths with the narrower pattern.

### Proxy routing (src/worker/index.ts)

The main worker proxies all `/crr-api/*` requests to the API worker. Admin paths get the `x-admin-key` injected; public paths pass through without it.

| Path pattern | Admin auth applied |
|---|---|
| `/crr-api/api/admin/*` | Yes |
| `/crr-api/api/qa-reviews` | Yes |
| `/crr-api/api/qa-viewer-reviews` | Yes |
| `/crr-api/api/triage/usage-logs` | Yes |
| `/crr-api/api/*` (all others) | No |

Note: `qa-reviews`, `qa-viewer-reviews`, and `triage/usage-logs` are admin-only on the API worker but live outside the `/api/admin/*` namespace — so they need explicit proxy routes to get the key injected.

### ADMIN_KEY secrets

The `ADMIN_KEY` secret must be set on **both** workers and the values must match. The proxy reads the key from the main worker's secret and forwards it to the API worker, which validates it.

```bash
# Set on main worker (vite-react-template)
npx wrangler secret put ADMIN_KEY

# Set on API worker (crr-criteria-api)
npx wrangler secret put ADMIN_KEY --config public/crr-criteria/wrangler.json
```

To generate a new key:
```bash
openssl rand -base64 32
```

To avoid the interactive prompt, pipe the value directly:
```bash
printf '%s' 'your-key-here' | npx wrangler secret put ADMIN_KEY
printf '%s' 'your-key-here' | npx wrangler secret put ADMIN_KEY --config public/crr-criteria/wrangler.json
```

To verify a secret is set (values are never shown, only names):
```bash
npx wrangler secret list
npx wrangler secret list --config public/crr-criteria/wrangler.json
```

### Session management

CF Access sets a `CF_AppSession` cookie scoped to `iteratio.nz` (Path=`/`, Domain=`iteratio.nz`). This cookie is automatically sent with all same-origin fetch calls from the admin tool.

**CF Access session duration** must not be set to "No duration, expires immediately". That setting authenticates the first request then immediately invalidates the session, causing all subsequent API calls to return 401. Set to a real duration (e.g. 24 hours) in the Access app settings — check both the app-level and global session duration overrides.

**After editing the Access app configuration** (adding hostnames, changing policies), existing browser sessions may not pick up the changes. Force a fresh session:

```
1. Visit:  https://iteratio.nz/cdn-cgi/access/logout
2. Close all iteratio.nz tabs
3. Reopen: https://iteratio.nz/crr-criteria/admin
4. Re-authenticate via email OTP
```

### Using the API directly (Claude Code / scripts)

The API worker still accepts `x-admin-key` directly — useful for scripted updates or Claude Code sessions. Call the API worker URL directly, bypassing the proxy:

```bash
curl -H "x-admin-key: YOUR_KEY" \
  https://crr-criteria-api.fk4dsrmq5r.workers.dev/api/admin/versions
```

The audit log records these calls with actor "Claude Code" (falls back when no CF Access email header is present).

---

## Admin API endpoints

**Browser base URL (via proxy):** `/crr-api/api/...` (same-origin, credentials included automatically)

**Direct base URL (scripts/CLI):** `https://crr-criteria-api.fk4dsrmq5r.workers.dev`

All admin endpoints require one of:
- `x-admin-key: <key>` header (direct/script access)
- CF Access session cookie + email header injected by proxy (browser via iteratio.nz)

### Criteria management

| Method | Endpoint | Body / Params | Description |
|--------|----------|---------------|-------------|
| `GET` | `/api/admin/criteria` | — | All criteria from D1 working copy |
| `GET` | `/api/admin/criteria/:id` | — | Single criteria record |
| `PUT` | `/api/admin/criteria/:id` | `{ data, updatedBy }` | Update a criteria record |
| `POST` | `/api/admin/criteria` | `{ id, title, modality, type, data, ... }` | Create a new criteria record |
| `DELETE` | `/api/admin/criteria/:id` | — | Delete a criteria record |

### Version management

| Method | Endpoint | Body / Params | Description |
|--------|----------|---------------|-------------|
| `GET` | `/api/admin/versions` | — | List all saved versions |
| `POST` | `/api/admin/versions` | `{ versionLabel, notes, createdBy }` | Save a new version snapshot from current D1 state |
| `POST` | `/api/admin/versions/:id/publish` | — | Publish a saved version to KV (makes it live) |
| `POST` | `/api/admin/publish` | `{ data, matchData, versionLabel, notes }` | Publish directly to KV (bypasses D1 snapshot flow) |
| `POST` | `/api/admin/versions/:id/rollback` | — | Restore a past version to KV |

### Region overrides

| Method | Endpoint | Body / Params | Description |
|--------|----------|---------------|-------------|
| `GET` | `/api/admin/regions` | — | All region override records |
| `PUT` | `/api/admin/regions/:regionId` | `{ overrides: { examId: url, ... } }` | Update a region's HealthPathways URL overrides |

### QA reviews

| Method | Endpoint | Query params | Description |
|--------|----------|--------------|-------------|
| `GET` | `/api/qa-reviews` | `?reviewer=&from=&to=` | All Triage Advisor QA reviews, newest first |
| `GET` | `/api/qa-viewer-reviews` | `?reviewer=&exam=&site=&from=&to=` | All Criteria Viewer QA reviews, newest first |

QA review submissions (`POST /api/qa-review`, `POST /api/qa-viewer-review`) do not require authentication and are rate-limited at 100 per hour per IP.

### Audit log

| Method | Endpoint | Query params | Description |
|--------|----------|--------------|-------------|
| `GET` | `/api/admin/audit` | `?limit=N` (default 50) | Audit log of publish/update/rollback actions |

### Debug / maintenance

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/debug` | KV key list and env var presence check |
| `GET` | `/api/debug/seed` | Write test version record to KV and verify |
| `POST` | `/api/seed?key=published\|match-data\|version` | Write raw seed data to KV directly |

---

## D1 database schema

### `criteria`
Working copy of all exam criteria, edited via the Admin Tool.

### `versions`
Snapshots of the criteria at publish time, used for version history and rollback.

### `audit_log`
Every create/update/delete/publish/rollback action with actor and timestamp.

### `qa_reviews`
Triage Advisor QA submissions from evaluators.

| Column | Type | Description |
|--------|------|-------------|
| `timestamp` | TEXT | ISO datetime |
| `session_id` | TEXT | Browser session ID |
| `reviewer_name` | TEXT | |
| `reviewer_role` | TEXT | GP / Radiologist / PCRL / MIT / Nurse Practitioner / Other |
| `scenario_type` | TEXT | `clear_approve` / `borderline` / `should_decline` / `emergency_redirect` |
| `score_criteria_id` | TEXT | `wrong` / `partial` / `correct` |
| `score_suggestion_quality` | TEXT | `wrong` / `partial` / `correct` |
| `score_compound_handling` | TEXT | `wrong` / `partial` / `correct` |
| `score_safety_redirect` | TEXT | `wrong` / `partial` / `correct` |
| `overall_assessment` | TEXT | `accurate` / `minor_issues` / `significant_issues` / `wrong` |
| `comments` | TEXT | Optional free text |
| `presentation_text` | TEXT | Full clinical note submitted |
| `ai_response_summary` | TEXT | AI verdict + met/missing criteria |
| `exam_identified` | TEXT | Exam the AI identified |
| `model_used` | TEXT | e.g. `claude-sonnet-4-20250514` |
| `documentation_standard` | TEXT | `strict` (locked for pilot) |
| `region` | TEXT | Currently null (no region selector in triage) |

### `qa_viewer_reviews`
Criteria Viewer QA submissions from content validators.

| Column | Type | Description |
|--------|------|-------------|
| `timestamp` | TEXT | ISO datetime |
| `session_id` | TEXT | Browser session ID |
| `reviewer_name` | TEXT | |
| `reviewer_role` | TEXT | |
| `exam_type` | TEXT | Modality, e.g. `ct`, `us`, `xr` |
| `site_code` | TEXT | Site ID, e.g. `ct_colonography` |
| `site_label` | TEXT | Human-readable exam + site label |
| `region` | TEXT | Selected region key |
| `view_mode` | TEXT | `indication` or `urgency` |
| `score_accuracy` | TEXT | `significant_errors` / `minor_issues` / `accurate` |
| `score_usability` | TEXT | `difficult` / `adequate` / `easy` |
| `score_value` | TEXT | `would_not_use` / `maybe` / `definitely` |
| `checklist_*` | INTEGER | 9 boolean fields (0/1): criteria, priority, gateway, labvalue, altmgmt, notfunded, guidance, healthpathways, groupings |
| `comments` | TEXT | Optional free text |

---

## Bundle states as the Criteria Viewer sees them (ARCH-MIG-01 slice 6)

Each exam/site bundle has a state in the `bundles` D1 table
(`transcribed` → `signed-off` → `published`, AD-10/AD-12). The Viewer renders a
site from its **published** bundle and from nothing else:

| Bundle state for the site's key | What the Viewer shows |
|---|---|
| no bundle row, or highest row is `transcribed` / `signed-off` | the current editable criteria JSON (`/api/criteria`), rendered by the legacy Viewer code path — **unchanged** |
| highest row is `published` | the frozen bundle (`/crr-api/api/criteria/:id`), rendered by `shared/criteria-render.js`: exam title + source-document section and pages, per-row page references, explicit compound structure, badges from the action codes, redirects and not-funded as rows, and — when `ASSESS_PIPELINE_ENABLED` is on — a "Check against criteria" self-check button |

Publishing a bundle (`POST /api/admin/bundles/:examSite/state` → `published`, never
raw SQL) is therefore what switches that one exam/site over in the Viewer and the
Triage reference column at the same time; rolling the state back switches it
straight back to the JSON path. The `bundle:<key>:latest-published` KV key and the
`bundles.state` D1 value are both consulted (`GET /api/criteria/:id` overlays the
live D1 state per AD-12). Only `ct_cap` maps to a published bundle today; every
other id is on the JSON path.


## Deployment

Both workers are deployed from the project root:

Always deploy from the repo root. Never `cd` into `public/crr-criteria/` — use `--config` to target the API worker.

```bash
# Deploy main site (viewer, triage, admin HTML + proxy worker)
npm run build && npx wrangler deploy

# Deploy API worker separately
npx wrangler deploy --config public/crr-criteria/wrangler.json
```

The main site build uploads all static files under `public/crr-criteria/` as Cloudflare Pages assets and deploys `src/worker/index.ts` as the edge worker (which includes the `/crr-api/*` proxy). The API worker compiles `api/worker.ts` separately.

### Staging (AD-34)

**Renamed 2026-10-11** from `vite-react-template-staging` to `crr-tools-staging`; the staging API worker keeps `crr-criteria-api-staging`. To move an existing deployment:
1. Workers & Pages → `vite-react-template-staging` → **Settings** → **General** → change the Worker name to `crr-tools-staging`, if your dashboard offers it. Renaming in place keeps the worker's secrets and its Worker Access policy, and the AUD should stay `b5160ef3…`: check it on the Access tab and tell Claude if it changed.
2. If renaming isn't offered: run step 3 (which creates `crr-tools-staging`), step 4 (Worker Access on the new worker; its new AUD goes into `env.staging.vars.ACCESS_AUD`) and step 5's three main-worker secrets, then delete `vite-react-template-staging`.
3. Either way, redeploy the API worker (step 1) so its allowed-origins list has the new host, then step 3.
4. Remove the old `/crr-criteria/admin` row for `vite-react-template-staging` from the production Access application as part of the rename. Left in place, it sent production admin logins on workers.dev to the old hostname (KI-70; removed 2026-10-11).

A second copy of both workers for side-by-side evaluation with synthetic cases only. It has its own D1 (`crr-criteria-staging`), KV and secrets. Since 2026-10-17 both staging workers are deployed by Workers Builds on every merge to `main` (AD-34 amendment 2026-10-16, SD-16); see **Automatic deploys** below. The manual steps below are for first-time setup, secrets, migrations, seeding, and testing an unmerged branch.

| | Production | Staging |
|---|---|---|
| Main worker | `vite-react-template` | `crr-tools-staging` (`https://crr-tools-staging.fk4dsrmq5r.workers.dev`) |
| API worker | `crr-criteria-api` (public workers.dev) | `crr-criteria-api-staging` (no public URL; reached only over the binding) |
| Pipeline flag | off | on (`ASSESS_PIPELINE_ENABLED=true`) |
| Access | admin paths only | the whole hostname |

Pages pick their API by hostname: on localhost, 127.0.0.1 and the staging host they call `/crr-api` (their own API worker). Every other host calls the production API URL (KI-39).

**First-time setup** (in order; the worker-level Access switch only exists once the worker is deployed):

```bash
# 1. API worker
npx wrangler deploy --config public/crr-criteria/wrangler.json --env staging
# 2. Database: schema (current to migration 0011), then the exam_sites seed, which lives only in 0008.
#    Run 0008 ONCE: its CREATEs are IF NOT EXISTS, but its INSERTs are plain.
npx wrangler d1 execute crr-criteria-staging --remote --config public/crr-criteria/wrangler.json --env staging --file public/crr-criteria/api/schema.sql
npx wrangler d1 execute crr-criteria-staging --remote --config public/crr-criteria/wrangler.json --env staging --file public/crr-criteria/api/migrations/0008_bundle_registry.sql
# 3. Main worker. The vite plugin picks the environment at build time and redirects
#    `wrangler deploy` to the built staging config.
CLOUDFLARE_ENV=staging npm run build && npx wrangler deploy
# Rebuild for production so a later plain deploy is not staging:
npm run build
```

4. **Access, straight after step 3.** Workers & Pages → `crr-tools-staging` → **Access** tab → Worker policies → **Manage access**. Set Scope to **All traffic** and the policy to **CRR Admin Users**.
   - This creates a Worker-level Access application with its own AUD. That AUD goes in `env.staging.vars.ACCESS_AUD` in `wrangler.json` (`b5160ef3…`, set 2026-10-11).
   - If the application is ever recreated, copy its new AUD (Access tab → Application values → AUD tag) into the config and redo step 3.
   - Between steps 3 and 4 the host is public, but nothing is exposed: there is no Anthropic key yet, and admin calls fail closed.
   - A hostname row for `/crr-criteria/admin` on the staging host also exists in the production CRR admin application. It covers only the admin page and does not change the AUD the proxy needs.

```bash
# 5. Secrets: new random values (e.g. `openssl rand -hex 32`), NOT production's.
#    Each command prompts for the value. Paste one command at a time: zsh does not
#    treat `#` as a comment in pasted commands, so never paste these comment lines.
npx wrangler secret put ADMIN_KEY           --config public/crr-criteria/wrangler.json --env staging
npx wrangler secret put ADMIN_PROXY_KEY     --config public/crr-criteria/wrangler.json --env staging
npx wrangler secret put ASSESS_INTERNAL_KEY --config public/crr-criteria/wrangler.json --env staging
npx wrangler secret put ANTHROPIC_API_KEY   --config public/crr-criteria/wrangler.json --env staging
# The next three take the SAME values as the API worker's above.
npx wrangler secret put ADMIN_KEY --name crr-tools-staging
npx wrangler secret put ADMIN_PROXY_KEY --name crr-tools-staging
npx wrangler secret put ASSESS_INTERNAL_KEY --name crr-tools-staging
# Check (names only): the main worker lists 3, the API worker lists 4.
npx wrangler secret list --name crr-tools-staging
npx wrangler secret list --config public/crr-criteria/wrangler.json --env staging
```

6. **Seed** from the repo root:
   ```bash
   node tooling/staging/seed-staging.mjs
   ```
   - **Stage A:** it runs the staging API worker code entirely on your machine, against a fresh local copy of the staging schema (127.0.0.1 only, one-off admin key). It loads everything through the real admin routes:
     - production's published criteria, match data and region overrides, read from production's public endpoints (production is never written);
     - production's active system prompt, created then activated;
     - the latest bundle of each key in the script's `BUNDLES` list (national-redflags, CT CAP, CT Colonography and the seven slice 7 W1 sites) from the registry, in their real state (`transcribed`). With `--demo-published` the script also marks those exam/site ids live on staging (AD-35 amendment) and fails if any stays off.
   - **Stage B:** it copies the resulting D1 rows and KV values to remote staging with wrangler, then checks that every copied KV value matches.
     - `wrangler dev --remote` cannot open a preview session on this account, which is why the work happens locally first.
   - It refuses if remote staging already holds seeded rows or KV keys, so it never loads on top. If a copy fails part-way, it says which half finished and prints the commands to empty staging and retry.
   - If your Cloudflare login covers more than one account, set `CLOUDFLARE_ACCOUNT_ID=13d95cc559c1c6a7e6808d279d668b75` first.
   - Needs `npx wrangler login`, steps 1–5 done, and port 8799 free.
   - Add `--demo-published` (AD-35; Gary must accept it first) to also move those bundles to `published` on staging. Each gets the sign-off reference "STAGING DEMO ONLY: not clinically signed off". The new pipeline only evaluates published bundles. Never do this on production (AD-10).
   - No audit, usage, QA or assessment rows are copied.

Notes:
- The staging API worker inherits the production cron (`0 3 * * *`, purging expired notes and stale proposals in the staging DB), which is intended.
- With an `env` block defined, every production deploy prints "Multiple environments are defined … no target environment specified". It is a warning only; the production config is used.

**Automatic deploys (Workers Builds, since 2026-10-17).** Each staging worker is connected to `irelandgc/crr-decision-support`, production branch `main`, with **Enable Preview builds** unticked (no builds for PR branches):

| Worker | Build command | Deploy command |
|---|---|---|
| `crr-criteria-api-staging` | `npm ci` | `npx wrangler deploy --config public/crr-criteria/wrangler.json --env staging` |
| `crr-tools-staging` | `CLOUDFLARE_ENV=staging npm run build` | `npx wrangler deploy` |

- A merge to `main` deploys both, in separate builds. Each build reports as a "Workers Builds: <worker>" check on the merge commit.
- Still manual: secrets, D1 migrations and resources (apply to staging **before** merging the PR that needs them; a migration applied early must suit the code still running), and seeding. Data does not follow code: bundles and criteria on staging change only by seeding or a staging publish.
- The `crr-criteria-api-staging` Builds page shows "Update wrangler.json … `"name": "crr-criteria-api-staging"`", because Cloudflare reads the root `wrangler.json`, which names the production worker. Do **not** apply it, and close any pull request Cloudflare opens to change that name. The deploy command uses the staging config, so the build is correct.
- A merge that changes what evaluators see (a CL row) carries its staging Release Log entry in the same PR.

**Redeploy by hand** (to test an unmerged branch; the next merge overwrites it): step 1 and/or step 3 (with the production rebuild after it).

**Do not** copy production D1 rows into staging: they include audit data (AD-34).

---

## LocalStorage keys

| Key | Used by | Description |
|-----|---------|-------------|
| `crr-region` | Viewer | Last selected HealthPathways region |
| `crr-admin-key` | Admin Tool | ~~Admin API key~~ — no longer used. Auth now handled by CF Access session cookie + server-side proxy. |
| `crr-qa-reviewer-name` | Triage + Viewer QA | Reviewer name (shared between tools) |
| `crr-qa-reviewer-role` | Triage + Viewer QA | Reviewer role (shared between tools) |

### SessionStorage

| Key | Used by | Description |
|-----|---------|-------------|
| `crr-qa-session-id` | Triage + Viewer QA | Random session ID grouping all reviews from one sitting (shared between tools) |
