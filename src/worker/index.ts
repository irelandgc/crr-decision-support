import { Hono } from "hono";

type Bindings = {
  // Mirror of the API worker's ADMIN_KEY. Used to authenticate the proxy
  // when forwarding admin requests to crr-criteria-api. Set with:
  //   npx wrangler secret put ADMIN_KEY
  ADMIN_KEY: string;
  // SR-14 — shared secret with the API worker. The admin proxy injects it as
  // `x-admin-proxy` on every forwarded request (and strips any client-supplied
  // copy); the API worker treats a matching value as proof the request arrived
  // through this proxy over the CRR_API service binding, and lets a mutating
  // /api/admin request through on that basis alone. Same value on both workers;
  // set with `npx wrangler secret put ADMIN_PROXY_KEY` on each. Absent in dev is
  // fine — a two-worker `wrangler dev` still reaches the LOCAL API worker via
  // the binding; the value only matters for distinguishing proxy from direct
  // traffic on a publicly reachable API worker.
  ADMIN_PROXY_KEY?: string;
  // SR-14 — escape hatch ONLY. When set, the proxy/forward targets this base URL
  // instead of the CRR_API service binding. MUST be unset in every dev and
  // production config we control: the binding resolves to the local API worker
  // under two-worker `wrangler dev` and to the bound worker in production, so a
  // hard-coded URL here is exactly the dev→prod cross-wiring SR-14 records.
  API_BASE?: string;
  ASSETS: Fetcher;
  // ARCH-MIG-01 slice 3: service binding to the crr-criteria-api worker (no
  // public HTTP hop), the flag that gates the /api/assess/* forward, and the
  // shared secret the API worker's evaluate route requires (mirror of that
  // worker's ASSESS_INTERNAL_KEY — set with `npx wrangler secret put`).
  CRR_API: Fetcher;
  ASSESS_PIPELINE_ENABLED?: string;
  ASSESS_INTERNAL_KEY?: string;
  // SR-15 — the admin proxy accepts only a Cloudflare Access JWT it has verified
  // against this Access application (AUD tag) and team domain. Not secrets; set
  // as vars in wrangler.json. Unset → admin requests are refused (fail closed).
  ACCESS_AUD?: string;
  ACCESS_TEAM_DOMAIN?: string;
  // SR-15 — LOCAL DEV ONLY, and honoured only on localhost: lets the two-worker
  // `wrangler dev` admin tool identify itself with `x-admin-email` (there is no
  // Access in front of localhost). Set in .dev.vars, never in wrangler.json.
  ACCESS_DEV_BYPASS?: string;
};

const app = new Hono<{ Bindings: Bindings }>();

// ── SR-15: verify the Cloudflare Access JWT ──────────────────────────────────
// Access sends `cf-access-jwt-assertion` on every request it fronts. A request
// that did not pass through Access has no valid token, whatever other headers it
// carries, so this is the only identity the admin proxy trusts.
let certCache: { domain: string; at: number; keys: JsonWebKey[] } | null = null;

// Keys are cached for an hour. An unknown `kid` forces a refresh at most once a
// minute (so random kids cannot drive a fetch per request), and a failed fetch
// falls back to the cached keys.
async function accessKeys(domain: string, refresh: boolean): Promise<JsonWebKey[]> {
  const cached = certCache && certCache.domain === domain ? certCache : null;
  const age = cached ? Date.now() - cached.at : Infinity;
  if (cached && (refresh ? age < 60_000 : age < 3_600_000)) return cached.keys;
  try {
    const res = await fetch(`${domain}/cdn-cgi/access/certs`);
    if (!res.ok) throw new Error(`Access certs fetch failed: ${res.status}`);
    const { keys } = (await res.json()) as { keys: JsonWebKey[] };
    certCache = { domain, at: Date.now(), keys };
    return keys;
  } catch (e) {
    if (cached) return cached.keys;
    throw e;
  }
}

const b64urlBytes = (s: string) =>
  Uint8Array.from(atob(s.replace(/-/g, "+").replace(/_/g, "/")), (ch) => ch.charCodeAt(0));
const b64urlJson = (s: string) => JSON.parse(new TextDecoder().decode(b64urlBytes(s)));

// Returns the verified email, or null for any invalid, expired or foreign token.
async function verifyAccessJwt(
  token: string | undefined,
  env: Pick<Bindings, "ACCESS_AUD" | "ACCESS_TEAM_DOMAIN">,
): Promise<string | null> {
  if (!token || !env.ACCESS_AUD || !env.ACCESS_TEAM_DOMAIN) return null;
  const domain = env.ACCESS_TEAM_DOMAIN.replace(/\/+$/, "");
  try {
    const [h, p, sig] = token.split(".");
    const header = b64urlJson(h);
    const payload = b64urlJson(p);
    if (header.alg !== "RS256" || typeof header.kid !== "string" || !sig) return null;
    const byKid = (k: JsonWebKey & { kid?: string }) => k.kid === header.kid;
    let jwk = (await accessKeys(domain, false)).find(byKid);
    if (!jwk) jwk = (await accessKeys(domain, true)).find(byKid);
    if (!jwk) return null;
    const key = await crypto.subtle.importKey(
      "jwk", jwk, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["verify"],
    );
    const ok = await crypto.subtle.verify(
      "RSASSA-PKCS1-v1_5", key, b64urlBytes(sig), new TextEncoder().encode(`${h}.${p}`),
    );
    if (!ok) return null;
    const now = Math.floor(Date.now() / 1000);
    const aud = Array.isArray(payload.aud) ? payload.aud : [payload.aud];
    if (!aud.includes(env.ACCESS_AUD)) return null;
    if (payload.iss !== domain) return null;
    if (typeof payload.exp !== "number" || payload.exp <= now) return null;
    if (typeof payload.nbf === "number" && payload.nbf > now) return null;
    return typeof payload.email === "string" && payload.email ? payload.email : null;
  } catch {
    return null;
  }
}

// Dispatch a proxied / forwarded request to the crr-criteria-api worker.
// Default and only sanctioned path: the CRR_API service binding — the LOCAL API
// worker under two-worker `wrangler dev`, the bound worker in production, never a
// public HTTP hop (SD-11). `env.API_BASE` is an unsanctioned escape hatch for a
// split deployment where the binding is unavailable; it must not be set in any
// dev or production config (SR-14).
export function dispatchToApi(
  env: Pick<Bindings, "API_BASE" | "CRR_API">,
  pathAndQuery: string,
  init: RequestInit,
): Promise<Response> {
  if (env.API_BASE) {
    return fetch(env.API_BASE.replace(/\/+$/, "") + pathAndQuery, init);
  }
  return env.CRR_API.fetch(new Request("https://crr-criteria-api" + pathAndQuery, init));
}

app.get("/api/", (c) => c.json({ name: "Cloudflare" }));

// ── ARCH-MIG-01 assessment pipeline (slice 3, extended slice 5) ──────────────
// Forwards /api/assess and /api/assess/* to the crr-criteria-api worker over the
// CRR_API service binding — same-origin, no public HTTP hop (SD-11). Gated by
// ASSESS_PIPELINE_ENABLED: off in production config until cut-over (slice 10), so
// the pipeline is not reachable by users yet. Identity and client IP travel;
// admin credentials and any browser-supplied x-assess-internal never do.
// `/api/assess` (slice 5) is the one-call pipeline; `/api/assess/propose` +
// `/api/assess/complete` are the two-phase split (AD-25 — extract, confirm the
// exam, then evaluate); `/api/assess/extract` and `/api/assess/evaluate` are the
// internal stages, callable directly for the benchmark and tabletop.
async function forwardAssess(c: any): Promise<Response> {
  if (c.env.ASSESS_PIPELINE_ENABLED !== "true") {
    return c.json({ error: "assessment pipeline not enabled" }, 404);
  }
  const inUrl = new URL(c.req.url);
  const fwd = new Headers();
  c.req.raw.headers.forEach((v: string, k: string) => {
    const lk = k.toLowerCase();
    if (
      lk === "host" ||
      lk === "connection" ||
      lk === "content-length" ||
      lk === "x-admin-key" ||
      lk === "x-admin-email" ||
      lk === "x-assess-internal" || // never trust an internal key from the browser
      lk === "cf-access-jwt-assertion" ||
      lk === "cookie"
    )
      return;
    fwd.set(k, v);
  });
  const cfip = c.req.header("cf-connecting-ip");
  if (cfip) fwd.set("cf-connecting-ip", cfip);
  const email = c.req.header("cf-access-authenticated-user-email");
  if (email) fwd.set("x-assess-identity", email);
  // The API worker's evaluate route is internal — it requires this shared secret.
  if (c.env.ASSESS_INTERNAL_KEY) fwd.set("x-assess-internal", c.env.ASSESS_INTERNAL_KEY);

  const method = c.req.method;
  const init: RequestInit = { method, headers: fwd };
  if (method !== "GET" && method !== "HEAD") {
    init.body = c.req.raw.body;
    // @ts-expect-error — Cloudflare Workers requires duplex for streaming bodies
    init.duplex = "half";
  }
  return dispatchToApi(c.env, inUrl.pathname + inUrl.search, init);
}

app.all("/api/assess", forwardAssess);
app.all("/api/assess/*", forwardAssess);

// ── Same-origin proxy to the CRR API worker ───────────────────────────────────
// The Admin tool calls /crr-api/... rather than crossing origins, so the
// Cloudflare Access cookie set for iteratio.nz/crr-criteria/admin/* travels
// with each request. Admin paths require a CF Access JWT that verifies against
// ACCESS_AUD / ACCESS_TEAM_DOMAIN (SR-15) — identity headers alone are never
// trusted, so a host Access does not front cannot reach admin routes.
// Public paths (criteria, regions, etc.) pass through with no auth check.

type IdentityContext = { req: { url: string; header: (name: string) => string | undefined }; env: Bindings };

async function adminIdentity(c: IdentityContext): Promise<string | null> {
  const host = new URL(c.req.url).hostname;
  if (c.env.ACCESS_DEV_BYPASS === "true" && (host === "localhost" || host === "127.0.0.1")) {
    return c.req.header("x-admin-email") || null;
  }
  return verifyAccessJwt(c.req.header("cf-access-jwt-assertion"), c.env);
}

async function proxy(c: any, requireAdmin: boolean): Promise<Response> {
  const inUrl = new URL(c.req.url);
  const downstreamPath = inUrl.pathname.replace(/^\/crr-api/, "");

  const email = requireAdmin ? await adminIdentity(c) : null;

  if (requireAdmin && !email) {
    return c.json(
      {
        error:
          "Admin endpoints require Cloudflare Access — sign in at the admin page first",
      },
      401,
    );
  }

  const fwdHeaders = new Headers();
  c.req.raw.headers.forEach((v: string, k: string) => {
    const lk = k.toLowerCase();
    if (
      lk === "host" ||
      lk === "connection" ||
      lk === "content-length" ||
      lk === "x-admin-key" || // never trust an x-admin-key from the browser
      lk === "x-admin-proxy" || // nor a forged "came via the proxy" marker (SR-14)
      lk === "x-admin-email" || // nor any identity the proxy has not verified (SR-15)
      lk === "cf-access-authenticated-user-email" ||
      lk === "cf-access-jwt-assertion"
    )
      return;
    fwdHeaders.set(k, v);
  });
  if (email) fwdHeaders.set("x-admin-email", email);
  if (requireAdmin && c.env.ADMIN_KEY) {
    fwdHeaders.set("x-admin-key", c.env.ADMIN_KEY);
  }
  // SR-14 — mark every admin-proxied request as having arrived through this
  // proxy over the CRR_API binding. The API worker lets a mutating /api/admin
  // request through on a matching value without needing ADMIN_WRITES_ENABLED.
  if (requireAdmin && c.env.ADMIN_PROXY_KEY) {
    fwdHeaders.set("x-admin-proxy", c.env.ADMIN_PROXY_KEY);
  }

  const method = c.req.method;
  const init: RequestInit = { method, headers: fwdHeaders };
  if (method !== "GET" && method !== "HEAD") {
    init.body = c.req.raw.body;
    // @ts-expect-error — Cloudflare Workers requires duplex for streaming bodies
    init.duplex = "half";
  }

  return dispatchToApi(c.env, downstreamPath + inUrl.search, init);
}

app.all("/crr-api/api/admin/*", (c) => proxy(c, true));
// Admin endpoints that live outside the /api/admin/* namespace on the upstream
// worker. These are protected by requireAccess on the API and need x-admin-key
// injected by the proxy.
app.all("/crr-api/api/qa-reviews", (c) => proxy(c, true));
app.all("/crr-api/api/qa-viewer-reviews", (c) => proxy(c, true));
app.all("/crr-api/api/triage/usage-logs", (c) => proxy(c, true));
app.all("/crr-api/api/*", (c) => proxy(c, false));

// Fall through to static assets for everything the worker doesn't handle
app.all("*", (c) => c.env.ASSETS.fetch(c.req.raw));

export default app;
