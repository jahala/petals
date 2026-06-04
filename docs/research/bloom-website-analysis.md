# Bloom Website Analysis

**Research Date:** June 3, 2026
**Source:** https://www.trybloom.ai/ and all discoverable subpages

---

## 1. Core Value Proposition

Bloom is **"The brand layer for agents"** — a platform that transforms a company's brand into a unified, operational system that powers creative output through AI. It ingests brand-defining materials from disparate sources (websites, Figma files, PDFs, social media, slide decks, images, fonts, etc.) and systemizes them into a single coherent brand system covering aesthetics, voice, references, and products. From that canonical source of truth, users and AI agents can generate on-brand content — images, video, copy, campaigns — consistently.

The key insight: instead of manually writing brand guidelines into prompts every time, Bloom encodes the brand once and makes it callable from anywhere (app, API, or MCP server). Every AI agent then draws from the same source of truth.

**Tagline:** "Bloom turns your brand into a working system."

---

## 2. How It Works (Three Steps)

1. **Ingest from any source** — Upload brand materials: PDFs, PNGs, Figma files, MP4s, MOVs, slide decks, Markdown docs, JSON, TTF fonts, and social handles. Also accepts website URLs and Instagram profiles for automated scraping.

2. **Systemise your brand** — Bloom runs "visual DNA analysis" (asynchronously) that extracts colors, fonts, visual style, tone, and aesthetics from all ingested materials. Results in a structured brand profile with fields like palette, typography, and voice.

3. **Start creating** — Generate images, video, copy, campaigns, logos, ads, reels, OG images, t-shirts, posters, stickers, carousels, Lottie animations, and icon sets — all referencing the canonical brand. Changes to the brand (logo, palette, voice) propagate automatically to all future assets.

---

## 3. Architecture

### 3.1 Brand Onboarding & Visual DNA Analysis

- **Endpoint:** `POST /api/v1/brands` — accepts a `url` (website or Instagram profile), optional `workspaceId`, optional `logoUrl`.
- Returns immediately with HTTP 202 and a brand `id`.
- Analysis runs asynchronously in the background.
- Status lifecycle: `analyzing` → `ready` (or `failed` / `logo_required`).
- Polling endpoint: `GET /api/v1/brands/{id}` supports `?wait=true` for long-poll behavior.
- Brands are scoped to workspaces; unlimited brands per workspace.

### 3.2 Image Generation Pipeline

- **Endpoint:** `POST /api/v1/images/generations`
- Required: `brandSessionId` (UUID) + `prompt` (1-2000 chars).
- Optional: `aspectRatio` (10 presets), `imageSize` (`2K` or `4K`), `model` (`fast`, `standard`, `pro`), `variantCount` (1-5), `referenceImageIds` (up to 10).
- Returns 202 immediately with image ID(s). The brand session acts as the constraint layer ensuring outputs are "on-palette, on-tone, on-aesthetic."
- Retrieval: `GET /api/v1/images/{id}?wait=true` holds connection open until terminal state.
- Batch retrieval: `GET /api/v1/images?ids=id1,id2,...&wait=true`.

### 3.3 Image Operations Suite

| Operation | Endpoint | Description |
|-----------|----------|-------------|
| Generate | `POST /images/generations` | AI image generation from prompt + brand |
| Edit | `POST /images/{id}/edit` | Edit existing image; aspect ratio locked to original |
| Resize | `POST /images/{id}/resize` | Resize to new aspect ratio (recomposes, doesn't crop) |
| Remove Background | `POST /images/{id}/remove-background` | Strip background → transparent PNG |
| Vectorize | `POST /images/{id}/vectorize` | Raster to SVG (best for logos, icons, flat art) |
| Semantic Search | `POST /images/search` | Vector search over uploaded/scraped images in brand library |
| Upload (URL) | `POST /images/uploads` | Upload image from remote URL |
| Upload (file) | `POST /images/uploads/file` | Upload local file (PNG/JPEG/WebP/AVIF, max 10MB) |
| Upload (signed) | `POST /images/uploads/file/signed/{token}` | Upload via MCP-tool-minted token |

### 3.4 Semantic Search Architecture

- Vector-embedding-based search over a brand's image library.
- Only searches `source = "uploaded"` or `"scraped"` images (excludes generated).
- Uses cosine distance as similarity metric; default cutoff 0.7.
- Supports cursor-based pagination; "plain noun phrases work best" for queries.
- Available in-app and via API/MCP.

### 3.5 MCP Server Architecture

Bloom runs an MCP (Model Context Protocol) server that acts as a connective layer between the brand system and AI agents.

**MCP Endpoint URL:** `https://www.trybloom.ai/api/mcp`

**Setup Process:**
1. Open AI client (Claude Desktop, ChatGPT, Cursor, VS Code, etc.) → Settings → Connectors
2. Add custom connector, paste the MCP endpoint URL
3. Authenticate with Bloom once in-browser

**Known MCP Tools (from documentation and screenshots):**

| Tool Name | Function |
|-----------|----------|
| `bloom_onboard_brand` | Ingest a brand from URL into the system |
| `bloom_generate_image` | Generate on-brand images from text prompts |
| `bloom_edit_image` | Edit existing images while staying on-brand |
| `bloom_resize_image` | Intelligent resizing / re-composition |
| `bloom_create_logo_upload_url` | Mint single-use, short-lived token for logo upload via signed URL |
| `bloom_create_image_upload_url` | Mint single-use, short-lived token for image upload via signed URL |

**Key Design Decision — Signed Upload Tokens:** The MCP tools `bloom_create_logo_upload_url` and `bloom_create_image_upload_url` mint single-use, short-lived tokens that are placed directly in the URL path (e.g., `PUT /brands/{id}/logo/file/signed/{token}`). These upload endpoints require no `Authorization` header — the token in the URL is the credential. This pattern enables AI agents to upload files without managing API keys for the upload step.

### 3.6 Supported AI Agent Platforms

Claude Desktop, Claude Code, claude.ai, ChatGPT, Cursor, VS Code, OpenCode, OpenAI Codex, Manus, OpenClaw, Hermes Agent, Notion.

### 3.7 API Design Details

- **Base URL:** `https://www.trybloom.ai/api/v1`
- **OpenAPI Spec:** 3.1.1, available live at `/api/v1/spec.json`
- **Auth:** API key (`x-api-key` header, format `bloom_sk_...`) or Bearer token
- **Rate Limit:** 120 requests/minute per API key (sliding window)
- **Response Envelope:** `{ data: {...} }` for success, `{ error: { code, status, message, defined } }` for errors
- **Error handling guidance:** Branch on `code` (machine-readable), not `message` (human-readable)
- **Async pattern:** Generations return 202 immediately; poll or use `?wait=true` for long-poll
- **Pagination:** Cursor-based throughout (not offset/page-based)
- **Stability guarantee:** "We only add fields, never remove or rename without a versioned migration path."
- **OpenAPI spec:** Generated directly from running API — no doc/code drift

### 3.8 Workflow Automation Integrations

Documented integrations with Zapier, n8n, Make, and Gumloop. Pattern: 3-step call sequence (POST generate → GET retrieve → use CDN URL). Each platform uses different names for credential storage ("auth connection", "credentials", "connections", "secrets"). For platforms with hard per-step timeouts (Zapier), polling with delay loops is the fallback instead of `?wait=true`.

---

## 4. Pricing & Credit System

**Published Plan: Scale** — $90/month or $1,080/year (~28% discount for annual)

**Credit Tiers (slider):** 300, 500, 1,000, or 2,000 credits/month

**Credit Costs:**
- 2K resolution: 1 credit per generation
- 4K resolution: 2 credits per generation
- Variants multiply the base cost (3 variants at 4K = 6 credits)

**Other Plan Tiers (from usage limits docs):**
| Plan | Monthly Credits |
|------|----------------|
| Plus | 50 |
| Pro | 100 |
| Max | 200 |
| Scale | 300-2,000 |

**Key Features Included:**
- API and MCP access in every plan
- Shared workspaces and brand assets
- Pooled team credits
- Unlimited members, no per-seat fees
- Single invoice / unified billing
- Volume discounts on credits
- One-off top-ups (20-200 credits) that never expire

**No free tier or free trial is mentioned.** Higher volume needs (high concurrency, bulk batch, white-label) handled via direct sales.

---

## 5. Target Audience & Positioning

**Four explicit segments:**

| Segment | Value Proposition |
|---------|------------------|
| **Marketers** | Every team member, every channel, always on-brand |
| **Software/platforms** | Embed Bloom to skip building brand infrastructure |
| **Founders** | Plug Bloom into their stack via API or MCP |
| **Agents** (Claude, ChatGPT, Cursor, Notion) | Every agent calls the same canonical source of truth |

**Messaging themes:**
- Centralize brand truth, distribute it everywhere
- Brand as infrastructure, not just guidelines
- AI-native from the ground up (YC-backed, built for the agent era)
- Eliminate the "brand drift" that happens when humans or agents work from memory or inconsistent references

---

## 6. Key Differentiators

1. **MCP-first architecture** — Bloom is one of the first commercially available MCP servers for brand management, making it natively callable from any MCP-compatible AI agent.

2. **Canonical brand source of truth** — Not a prompt library or style guide, but an encoded, machine-readable brand that constrains all outputs.

3. **Seamless brand updates** — Change the logo or palette once, and all future (and presumably existing) assets reflect it.

4. **Unlimited brands, no per-seat pricing** — Designed for agencies and platforms managing multiple brands.

5. **Reference-based generation** — Upload product photos, competitor ads, or moodboards as references; Bloom matches the look while staying on-brand.

6. **Signed upload tokens via MCP** — Novel pattern enabling AI agents to handle file uploads without managing API keys directly.

---

## 7. Company & Credibility Signals

- **YC-backed** (Y Combinator)
- **Copyright 2026** — recently established or recently refreshed
- **Domain:** trybloom.ai (the "try" prefix is common for SaaS tools)
- **Contact:** support@trybloom.ai
- **Social presence:** X (Twitter) and Discord community
- **Last privacy policy update:** December 5, 2025
- **Last terms update:** December 5, 2025
- **Pages found:** Homepage, Features, Teams, MCP, Docs (API), Pricing, FAQ, Careers, Affiliates, Terms, Privacy
- **Pages returning 404:** /about, /blog, /changelog, /docs/mcp, /docs/guides/mcp, /docs/agents
- **Pages returning 405:** /docs/mcp (method not allowed)

---

## 8. Gaps & Unknowns

- **Blog content** — /blog returned 404; no public thought-leadership content found
- **About/team page** — /about returned 404; company story and team not publicly available
- **MCP tool full specification** — Individual tool schemas (input/output parameters) not publicly documented; only inferred from API endpoints and screenshots
- **Video/copy generation** — Marketed on the homepage but only image endpoints are documented in the API; video and copy generation capabilities are not surfaced in the OpenAPI spec
- **Changelog** — /changelog returned 404; no product update history visible
- **Exact brand data model** — What fields does the "visual DNA" extract? Palette format? Typography spec? These details are not documented publicly

---

## 9. Competitive Context

Bloom sits at the intersection of **brand management** (Frontify, Brandfolder, Canva Brand Kit) and **AI content generation** (Midjourney, DALL-E, Adobe Firefly). Its key distinction is the MCP-first approach — making brand directly callable by AI agents rather than requiring humans to be the intermediary. This positions it for the emerging paradigm where AI agents autonomously generate marketing content, and consistent branding becomes an infrastructure problem rather than a review process problem.
