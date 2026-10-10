// SR-15 — the /crr-api/* admin proxy trusts only a Cloudflare Access JWT it has
// verified (signature against the team's certs, AUD, issuer, expiry). A request
// that did not come through Access — e.g. a host Access does not front — carries
// at most identity headers, which must get it nowhere.
import { afterAll, beforeAll, describe, expect, it, vi } from "vitest";
import app from "../src/worker/index";

const DOMAIN = "https://team.example.cloudflareaccess.com";
const AUD = "aud-tag-for-this-app";
const KID = "kid-1";

let privateKey: CryptoKey;
let publicJwk: JsonWebKey;
let fetchSpy: ReturnType<typeof vi.spyOn>;

const b64url = (bytes: Uint8Array) =>
  btoa(String.fromCharCode(...bytes)).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
const enc = (o: unknown) => b64url(new TextEncoder().encode(JSON.stringify(o)));

async function jwt(claims: Record<string, unknown>, kid = KID, key = privateKey): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const head = enc({ alg: "RS256", kid, typ: "JWT" });
  const body = enc({ aud: [AUD], iss: DOMAIN, email: "admin@example.com", iat: now, exp: now + 600, ...claims });
  const sig = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(`${head}.${body}`));
  return `${head}.${body}.${b64url(new Uint8Array(sig))}`;
}

function harness(envOverrides: Record<string, unknown> = {}) {
  const seen: Request[] = [];
  const env = {
    CRR_API: { fetch: async (req: Request) => { seen.push(req); return new Response("upstream-ok"); } },
    ACCESS_AUD: AUD,
    ACCESS_TEAM_DOMAIN: DOMAIN,
    ADMIN_KEY: "server-admin-key",
    ADMIN_PROXY_KEY: "server-proxy-key",
    ...envOverrides,
  };
  const call = (path: string, headers: Record<string, string> = {}, host = "vite-react-template.example") =>
    app.fetch(new Request(`https://${host}${path}`, { headers }), env as unknown as Parameters<typeof app.fetch>[1]);
  return { seen, call };
}

beforeAll(async () => {
  const pair = (await crypto.subtle.generateKey(
    { name: "RSASSA-PKCS1-v1_5", modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" },
    true,
    ["sign", "verify"],
  )) as CryptoKeyPair;
  privateKey = pair.privateKey;
  publicJwk = { ...((await crypto.subtle.exportKey("jwk", pair.publicKey)) as JsonWebKey), kid: KID } as JsonWebKey;
  fetchSpy = vi.spyOn(globalThis, "fetch").mockImplementation(async (input: RequestInfo | URL) => {
    const url = typeof input === "string" ? input : input instanceof URL ? input.href : input.url;
    if (url === `${DOMAIN}/cdn-cgi/access/certs`) return Response.json({ keys: [publicJwk] });
    throw new Error(`unexpected fetch ${url}`);
  });
});
afterAll(() => fetchSpy.mockRestore());

describe("SR-15 — admin proxy identity", () => {
  it("refuses a forged x-admin-email (and a forged Access email header) with no JWT", async () => {
    const { seen, call } = harness();
    const res = await call("/crr-api/api/admin/versions", {
      "x-admin-email": "attacker@example.com",
      "cf-access-authenticated-user-email": "attacker@example.com",
    });
    expect(res.status).toBe(401);
    expect(seen).toHaveLength(0);
  });

  it("forwards a verified request with the token's email, never the client's headers", async () => {
    const { seen, call } = harness();
    const res = await call("/crr-api/api/admin/versions", {
      "cf-access-jwt-assertion": await jwt({}),
      "x-admin-email": "someone-else@example.com",
    });
    expect(res.status).toBe(200);
    expect(seen).toHaveLength(1);
    expect(seen[0].headers.get("x-admin-email")).toBe("admin@example.com");
    expect(seen[0].headers.get("x-admin-key")).toBe("server-admin-key");
    expect(seen[0].headers.get("x-admin-proxy")).toBe("server-proxy-key");
    expect(seen[0].headers.get("cf-access-jwt-assertion")).toBeNull();
  });

  it.each([
    ["another Access app (wrong AUD)", { aud: ["some-other-app"] }],
    ["another team (wrong issuer)", { iss: "https://other.cloudflareaccess.com" }],
    ["an expired token", { exp: Math.floor(Date.now() / 1000) - 5 }],
    ["a token not yet valid", { nbf: Math.floor(Date.now() / 1000) + 600 }],
    ["a token with no email", { email: undefined }],
  ])("refuses %s", async (_label, claims) => {
    const { seen, call } = harness();
    const res = await call("/crr-api/api/admin/versions", { "cf-access-jwt-assertion": await jwt(claims) });
    expect(res.status).toBe(401);
    expect(seen).toHaveLength(0);
  });

  it("refuses a token whose payload was altered after signing", async () => {
    const { seen, call } = harness();
    const [h, , s] = (await jwt({})).split(".");
    const forged = `${h}.${enc({ aud: [AUD], iss: DOMAIN, email: "attacker@example.com", exp: Math.floor(Date.now() / 1000) + 600 })}.${s}`;
    const res = await call("/crr-api/api/admin/versions", { "cf-access-jwt-assertion": forged });
    expect(res.status).toBe(401);
    expect(seen).toHaveLength(0);
  });

  it("refuses an unsigned token (alg none)", async () => {
    const { seen, call } = harness();
    const [, body] = (await jwt({})).split(".");
    const res = await call("/crr-api/api/admin/versions", {
      "cf-access-jwt-assertion": `${enc({ alg: "none", kid: KID, typ: "JWT" })}.${body}.`,
    });
    expect(res.status).toBe(401);
    expect(seen).toHaveLength(0);
  });

  it("refuses a token signed by a key that is not in the team's certs", async () => {
    const { seen, call } = harness();
    const other = (await crypto.subtle.generateKey(
      { name: "RSASSA-PKCS1-v1_5", modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" },
      true,
      ["sign", "verify"],
    )) as CryptoKeyPair;
    const res = await call("/crr-api/api/admin/versions", {
      "cf-access-jwt-assertion": await jwt({}, "unknown-kid", other.privateKey),
    });
    expect(res.status).toBe(401);
    expect(seen).toHaveLength(0);
  });

  it("fails closed when ACCESS_AUD is not configured", async () => {
    const { seen, call } = harness({ ACCESS_AUD: undefined });
    const res = await call("/crr-api/api/admin/versions", { "cf-access-jwt-assertion": await jwt({}) });
    expect(res.status).toBe(401);
    expect(seen).toHaveLength(0);
  });

  it("ACCESS_DEV_BYPASS is honoured on localhost only", async () => {
    const { seen, call } = harness({ ACCESS_DEV_BYPASS: "true" });
    const remote = await call("/crr-api/api/admin/versions", { "x-admin-email": "dev@example.com" });
    expect(remote.status).toBe(401);
    const local = await call("/crr-api/api/admin/versions", { "x-admin-email": "dev@example.com" }, "localhost:8787");
    expect(local.status).toBe(200);
    expect(seen).toHaveLength(1);
    expect(seen[0].headers.get("x-admin-email")).toBe("dev@example.com");
  });

  it("public paths pass through without forwarding any client identity header", async () => {
    const { seen, call } = harness();
    const res = await call("/crr-api/api/criteria", {
      "x-admin-email": "attacker@example.com",
      "cf-access-authenticated-user-email": "attacker@example.com",
      "cf-access-jwt-assertion": "not-a-token",
    });
    expect(res.status).toBe(200);
    expect(seen[0].headers.get("x-admin-email")).toBeNull();
    expect(seen[0].headers.get("cf-access-authenticated-user-email")).toBeNull();
    expect(seen[0].headers.get("cf-access-jwt-assertion")).toBeNull();
    expect(seen[0].headers.get("x-admin-key")).toBeNull();
  });
});
