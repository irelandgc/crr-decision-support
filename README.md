# React + Vite + Hono + Cloudflare Workers

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/cloudflare/templates/tree/main/vite-react-template)

This template provides a minimal setup for building a React application with TypeScript and Vite, designed to run on Cloudflare Workers. It features hot module replacement, ESLint integration, and the flexibility of Workers deployments.

![React + TypeScript + Vite + Cloudflare Workers](https://imagedelivery.net/wSMYJvS3Xw-n339CbDyDIA/fc7b4b62-442b-4769-641b-ad4422d74300/public)

<!-- dash-content-start -->

🚀 Supercharge your web development with this powerful stack:

- [**React**](https://react.dev/) - A modern UI library for building interactive interfaces
- [**Vite**](https://vite.dev/) - Lightning-fast build tooling and development server
- [**Hono**](https://hono.dev/) - Ultralight, modern backend framework
- [**Cloudflare Workers**](https://developers.cloudflare.com/workers/) - Edge computing platform for global deployment

### ✨ Key Features

- 🔥 Hot Module Replacement (HMR) for rapid development
- 📦 TypeScript support out of the box
- 🛠️ ESLint configuration included
- ⚡ Zero-config deployment to Cloudflare's global network
- 🎯 API routes with Hono's elegant routing
- 🔄 Full-stack development setup
- 🔎 Built-in Observability to monitor your Worker

Get started in minutes with local development or deploy directly via the Cloudflare dashboard. Perfect for building modern, performant web applications at the edge.

<!-- dash-content-end -->

## Getting Started

To start a new project with this template, run:

```bash
npm create cloudflare@latest -- --template=cloudflare/templates/vite-react-template
```

A live deployment of this template is available at:
[https://react-vite-template.templates.workers.dev](https://react-vite-template.templates.workers.dev)

## Development

Install dependencies:

```bash
npm install
```

Start the development server with:

```bash
npm run dev
```

Your application will be available at [http://localhost:5173](http://localhost:5173).

## Local dev: the two-worker assessment pipeline (ARCH-MIG-01)

Running the assessment pipeline locally needs two workers together: this
repo's root worker (`vite-react-template`, `wrangler.json`) and the API
worker (`crr-criteria-api`, `public/crr-criteria/wrangler.json`), forwarding
over a Cloudflare service binding — no public HTTP hop (SD-11).

Copy each `.dev.vars.example` to `.dev.vars` (both gitignored) and fill in
`ASSESS_INTERNAL_KEY` — the **same** value in both files. Both examples set
`ASSESS_PIPELINE_ENABLED=true`. This is intentional and does **not** match
the committed `wrangler.json` default of `"false"` (the production-safe
value, unchanged until the slice 10 cut-over): a `.dev.vars` value always
overrides the committed config locally, so with both files in place the
pipeline runs ON in local dev even though every committed config reads OFF.
If you only check `wrangler.json`, you'll get the wrong answer for what's
running locally (KI-54, KI-64).

Launch the two-worker dev with a single shared persist path so the server,
the seed commands and `run-pipeline-e2e.mjs` all read/write the same local
D1 + KV (KI-54 — the two configs default to different directories if you
don't):

```bash
npx wrangler dev -c wrangler.json -c public/crr-criteria/wrangler.json \
  --persist-to ./public/crr-criteria/.wrangler/state
```

See `tooling/criteria-bundle/benchmark/run-pipeline-e2e.mjs`'s header for
the full local seed sequence (schema, migrations, publishing
`national-redflags` + a site bundle to local KV/D1).

## Production

Build your project for production:

```bash
npm run build
```

Preview your build locally:

```bash
npm run preview
```

Deploy your project to Cloudflare Workers:

```bash
npm run build && npm run deploy
```

Monitor your workers:

```bash
npx wrangler tail
```

## Additional Resources

- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Vite Documentation](https://vitejs.dev/guide/)
- [React Documentation](https://reactjs.org/)
- [Hono Documentation](https://hono.dev/)
