# Color Audit Guide

This guide documents the structured process for auditing a file's color usage against the brand palette. The canonical source for color values is `.brand/colors.md`.

## Process

### 1. Build the Palette

Read `.brand/colors.md` and extract every hex color value. The palette includes:
- Primary Palette: Primary, Accent, Background, Text
- Semantic Roles: Error, Success, Warning, Info
- Light/Dark Mode Variants: Each role's light and dark variants
- Any additional hex values in the CSS custom properties section

Store these as a set for exact-match comparison. Normalize to uppercase for case-insensitive matching (e.g., `#2f99a4` and `#2F99A4` are the same color).

### 2. Scan the Target File

Use regex to find all hex color patterns in the target file:

```
#[0-9a-fA-F]{3}\b         # #rgb
#[0-9a-fA-F]{6}\b         # #rrggbb
#[0-9a-fA-F]{8}\b         # #rrggbbaa (if the brand uses 8-digit hex)
```

Scan line by line. Record each match with its line number and the full matched value.

### 3. Exclude False Positives

Before matching against the palette, filter out matches that appear in contexts where hex values are not color declarations:

- **Data URIs**: Matches inside `url("data:image/...` strings. These are encoded image data, not style declarations.
- **Base64 strings**: Matches inside base64-encoded strings. Base64 uses hex-like characters but encodes binary data.
- **URLs**: Matches inside `url(...)` that reference external resources (fonts, images).
- **Hash references**: Matches like `#id` selector in CSS, or `#anchor` in URLs.

Guideline for context detection:
- If a hex pattern appears immediately after `data:image/`, skip it.
- If a hex pattern appears within a string that is >100 characters and contains only base64 characters (`[A-Za-z0-9+/=]`), skip it.
- If a hex pattern appears inside `url(...)` that does not start with `data:`, skip it.

### 4. Match Against Palette

For each remaining match, normalise the case (uppercase) and check against the palette set:

- **Match found**: No violation. Skip.
- **No match**: This is a color error. Proceed to step 5.

### 5. Find the Closest Palette Match

For each violation, find the palette color closest to the violating hex. The closest match is the one with the smallest perceptual distance.

Compute distance using the Euclidean distance in RGB space:

```
Given hex #RRGGBB:
  R1 = int(RR, 16), G1 = int(GG, 16), B1 = int(BB, 16)
For each palette color:
  R2, G2, B2 = palette color components
  distance = sqrt((R1-R2)^2 + (G1-G2)^2 + (B1-B2)^2)
```

Return the palette color with the smallest distance. If multiple palette colors have the same distance, prefer the Primary color, then the one most frequently used in the palette.

For 3-digit hex (#rgb), expand to 6-digit before comparison: `#RGB` becomes `#RRGGBB`.

### 6. Classify the Violation

All color mismatches are **errors** (must fix). There are no warnings for color violations. A single off-palette hex means the check does not pass.

### 7. Report Results

For each violation, report:
- **Dimension**: `color`
- **Severity**: `error`
- **Line**: The line number where the violation was found
- **Found**: The hex value found in the file
- **Suggested**: The closest palette match

Format:
```
ERROR [color] line 42: #3B82F6 is not in the palette. Did you mean #2F99A4?
```

If zero violations:
```
PASS [color] All colors match the brand palette.
```

### Reference

- Canonical color source: `.brand/colors.md`
- This guide is used by: `/petal check <file>` (color audit dimension)
