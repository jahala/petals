# DTCG Design Tokens & AdCP brand.json — Research

**Date:** June 3, 2026

---

## 1. W3C Design Tokens Community Group (DTCG) Specification

### Status
- **Stable v1:** October 28, 2025 — "Design Tokens Format Module 2025.10"
- **W3C Community Group** — 40+ orgs (Adobe, Amazon, Atlassian, Figma, Google, Microsoft, Salesforce, Shopify)
- **File extensions:** `.tokens` or `.tokens.json`
- **MIME type:** `application/design-tokens+json`

### Core Structure

**Token:** Any JSON object with a `$value` property.  
**Group:** Any JSON object without `$value` — used for hierarchy.  
**Invalid:** Object has BOTH `$value` and child objects.

Character rules: names MUST NOT start with `$`, and MUST NOT contain `{`, `}`, or `.`.

### Token Properties

| Property | Required | Description |
|----------|----------|-------------|
| `$value` | Yes | The token's value |
| `$type` | No* | Predefined type; inherits from parent group; token invalid without any type |
| `$description` | No | Plain-text explanation |
| `$extensions` | No | Vendor metadata (reverse-domain keys) |
| `$deprecated` | No | `true`, `false`, or string explanation |

### 8+ Base Token Types

| Type | Value Format |
|------|-------------|
| `color` | `{colorSpace, components[], alpha?, hex?}` |
| `dimension` | `{value (number), unit ("px"/"rem")}` |
| `fontFamily` | String or array of strings |
| `fontWeight` | Number [1,1000] or string alias |
| `duration` | `{value (number), unit ("ms"/"s")}` |
| `cubicBezier` | `[P1x, P1y, P2x, P2y]` |
| `number` | Bare JSON number |
| `strokeStyle` | String or `{dashArray, lineCap}` |

### 6 Composite Types
`border`, `shadow`, `gradient`, `transition`, `typography`, `strokeStyle` — group related properties under one `$value` object.

### Aliases: Two Syntaxes
- **Curly brace:** `{path.to.token}` — references complete `$value`
- **JSON Pointer:** `$ref` with RFC 6901 pointer — can reference sub-properties

### Groups & Inheritance
- `$extends` — deep merge inheritance between groups
- `$type` propagates from parent group to child tokens
- Resolution order: token explicit → resolved group → parent group → invalid

### Complete Example
```json
{
  "Button background": {
    "$type": "color",
    "$description": "The background color for buttons in their normal state.",
    "$value": {
      "colorSpace": "srgb",
      "components": [0.467, 0.467, 0.467]
    }
  }
}
```

### Adoption: Industry Standard
**Widely adopted.** Figma, Google (Material Design), Amazon (Style Dictionary), GitHub, Meta, Microsoft, Salesforce, Shopify, Adobe, The Guardian, Disney, GM, New York Times, Sony, Intuit, Cisco, Pinterest, Baidu. By 2026, DTCG compliance is **table stakes, not a differentiator** in enterprise RFPs.

---

## 2. AdCP (Ad Context Protocol) — `.well-known/brand.json`

### What Is It?
An open standard for advertising automation. AI agents discover inventory, buy media, build creatives, activate audiences over MCP and A2A transports.

- **GitHub:** `adcontextprotocol/adcp` (223 stars, 3,667 commits, 34 releases, v3.0.15)
- **Maintainer:** AgenticAdvertising.Org (pending 501(c)(6) nonprofit)
- **License:** Apache 2.0

### brand.json: Full Field Reference
Hosted at `/.well-known/brand.json`. Tells AI advertising agents who the brand is, what it looks like, and how it wants to be represented.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | Yes | Brand identifier |
| `names` | array | Yes | Localized names with language codes |
| `colors` | object | No | Palette roles: primary, secondary, accent, background, text, heading, body, label, border, divider, surface_1, surface_2 |
| `fonts` | object | No | Brand typography |
| `tone` | object | No | `{voice, attributes, dos, donts}` |
| `logos` | array | No | Logo assets with `id`, `slots[]` |
| `tagline` | string | No | Brand tagline |
| `visual_guidelines` | object | No | Extensive: photography, graphic_style, shapes, iconography, composition, border_radius, elevation, spacing, motion, logo_placement, color_constraints, mark_lockups, colorways, type_scale, restrictions |
| `keller_type` | enum | No | `master`, `sub_brand`, `endorsed`, `independent` |
| `house_domain` | string | No | Corporate house pointer |
| `brand_agent` | object | No | `{url, id}` — MCP agent for brand identity |
| `trademarks` | array | No | Registered trademarks |
| `$schema` | string | No | Schema version URL |
| `version` | string | No | Document version |
| `last_updated` | string | No | ISO 8601 timestamp |

### Five Variants
1. **Authoritative Location Redirect** — canonical doc at different URL
2. **House Redirect** — brand rolls up to house domain
3. **Brand Agent** — MCP agent is authoritative source
4. **House Portfolio** — house publishes brands inline
5. **Brand Canonical Document** — brand self-publishes identity

### Trust Model: Mutual Assertion
Inspired by `ads.txt`/`sellers.json`. Brand's own domain document is authoritative for its identity. For relationships, both sides must assert. Max 3 redirect hops. Cache poisoning protection via `redirect_effective_at`.

### Adoption Status: EARLY — NOT WIDELY ADOPTED
- Reference impl by Prebid community only
- No named brand adopters surfaced
- 223 GitHub stars (modest)
- Too new for enterprise adoption
- Companion: `adagents.json` for publisher-side declarations

### Relationship to Other Standards
- **NOT related to `llms.txt`**, `ai.txt`, or general web discovery files
- Narrowly scoped to advertising within the AdCP protocol ecosystem
- Uses `.well-known/` convention (RFC 8615), unlike `llms.txt` at domain root

---

## Summary

| Dimension | DTCG Design Tokens | AdCP brand.json |
|-----------|-------------------|-----------------|
| **Domain** | Design systems | Advertising |
| **Maturity** | Stable v1, widely adopted | Pre-adoption, early dev |
| **Adoption** | 40+ orgs, enterprise RFP standard | Reference impl only |
| **Key adopters** | Figma, Google, Amazon, Adobe, Shopify, Meta, Microsoft | Prebid (reference) |
| **Relevance to Petal** | HIGH — export format for design tokens | LOW — advertising-specific, not adopted |
