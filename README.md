# GrowFi

GrowFi is now a mobile-first full-stack finance app prototype. The original static preview is still kept, and the new production direction is a Next.js app with API routes and Supabase persistence.

## What Works

- Mobile web app UI with four tabs: 首页、记账、理财、我的.
- Real backend endpoints for summary, transactions, saving goals, and favorite stocks.
- Supabase schema for durable database storage.
- Demo fallback data when Supabase environment variables are not configured.
- Existing iOS SwiftUI source remains in `GrowFiApp/`.

## Local Development

```bash
npm install
npm run dev
```

Open `http://localhost:3000`.

## Supabase Setup

1. Create a Supabase project.
2. Open Supabase SQL Editor.
3. Run `supabase/schema.sql`.
4. Copy `.env.example` to `.env.local`.
5. Fill in:

```bash
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
```

The service role key must only be used on the server, never in client code.

## Deploy

Deploy the repository to Vercel, then add the same environment variables in Vercel Project Settings.

The old files are kept for reference:

- `index.html` - static Figma preview.
- `qr.html` - QR entry page.
- `GrowFi.xcodeproj` and `GrowFiApp/` - native iOS source.
