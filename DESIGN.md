---
name: Aulas limpias
description: Institutional classroom-cleaning ledger for ESPOCH, in restrained red, ink and hairline neutrals.
colors:
  brand: '#bc0613'
  brand-strong: '#9a0510'
  brand-deep: '#7a040d'
  brand-tint: '#fbeaeb'
  on-brand: '#ffffff'
  institutional-bronze: '#b5a880'
  ink: '#212121'
  ink-heading: '#292929'
  ink-muted: '#5c646e'
  ink-subtle: '#69727d'
  hairline: '#e3e3e3'
  hairline-strong: '#c9ccd1'
  surface: '#ffffff'
  surface-alt: '#f4f4f4'
  page: '#f7f7f7'
  limpio-fg: '#085d3a'
  limpio-bg: '#ecfdf3'
  limpio-border: '#abefc6'
  limpio-solid: '#17b26a'
  warning-fg: '#93370d'
  warning-bg: '#fffaeb'
  warning-border: '#fedf89'
  warning-solid: '#f79009'
  sucio-fg: '#912018'
  sucio-bg: '#fef3f2'
  sucio-border: '#fecdca'
  sucio-solid: '#d92d20'
typography:
  headline-lg:
    fontFamily: 'Work Sans, system-ui, -apple-system, Segoe UI, Roboto, sans-serif'
    fontSize: '1.75rem'
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: 'normal'
  headline-md:
    fontFamily: 'Work Sans, system-ui, -apple-system, Segoe UI, Roboto, sans-serif'
    fontSize: '1.375rem'
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: 'normal'
  title:
    fontFamily: 'Work Sans, system-ui, -apple-system, Segoe UI, Roboto, sans-serif'
    fontSize: '1.125rem'
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: 'normal'
  body:
    fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif'
    fontSize: '1rem'
    fontWeight: 400
    lineHeight: 1.5
    letterSpacing: 'normal'
  label:
    fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif'
    fontSize: '0.875rem'
    fontWeight: 600
    lineHeight: 1.5
    letterSpacing: 'normal'
  caption:
    fontFamily: 'Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif'
    fontSize: '0.75rem'
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: 'normal'
rounded:
  sm: '6px'
  md: '10px'
  lg: '14px'
  pill: '999px'
spacing:
  space-1: '4px'
  space-2: '8px'
  space-3: '12px'
  space-4: '16px'
  space-5: '24px'
  space-6: '32px'
  space-7: '48px'
components:
  button-primary:
    backgroundColor: '{colors.brand}'
    textColor: '{colors.on-brand}'
    typography: '{typography.label}'
    rounded: '{rounded.sm}'
    height: '44px'
    padding: '8px 16px'
  button-primary-hover:
    backgroundColor: '{colors.brand-strong}'
    textColor: '{colors.on-brand}'
  button-primary-active:
    backgroundColor: '{colors.brand-deep}'
    textColor: '{colors.on-brand}'
  button-secondary:
    backgroundColor: '{colors.surface}'
    textColor: '{colors.ink}'
    typography: '{typography.label}'
    rounded: '{rounded.sm}'
    height: '44px'
    padding: '8px 16px'
  button-secondary-hover:
    backgroundColor: '{colors.surface-alt}'
    textColor: '{colors.ink}'
  input:
    backgroundColor: '{colors.surface}'
    textColor: '{colors.ink}'
    typography: '{typography.body}'
    rounded: '{rounded.sm}'
    height: '44px'
    padding: '8px 12px'
  card:
    backgroundColor: '{colors.surface}'
    textColor: '{colors.ink}'
    rounded: '{rounded.md}'
    padding: '16px'
  aula-card:
    backgroundColor: '{colors.surface}'
    textColor: '{colors.ink-heading}'
    typography: '{typography.title}'
    rounded: '{rounded.md}'
    padding: '12px'
  badge-limpio:
    backgroundColor: '{colors.limpio-bg}'
    textColor: '{colors.limpio-fg}'
    typography: '{typography.caption}'
    rounded: '{rounded.pill}'
    padding: '4px 8px'
  badge-sucio:
    backgroundColor: '{colors.sucio-bg}'
    textColor: '{colors.sucio-fg}'
    typography: '{typography.caption}'
    rounded: '{rounded.pill}'
    padding: '4px 8px'
  app-header:
    backgroundColor: '{colors.brand}'
    textColor: '{colors.on-brand}'
---

# Design System: Aulas limpias

## 1. Overview

**Creative North Star: "The Official Ledger"**

Aulas limpias is a register, not a dashboard. Each classroom is a line in an institutional ledger: its state is the first thing read, the time of the last entry sits beneath it, and the photo evidence is part of the record rather than an apology for a failed check. The system speaks in the plain, steady voice of an administrative document that happens to be usable one-handed in a corridor.

The ESPOCH red works as a seal. It stamps the header band and the one primary action, and nowhere else carries it for decoration. Everything between is ink on near-white (or its dark-theme counterpart), separated by hairlines instead of shadows or fills. Hierarchy comes from type weight and position; surfaces stay quiet so the two cleaning states are the only colors that ever compete for attention.

This system explicitly rejects the three looks named in PRODUCT.md: the generic SaaS dashboard (identical cards with big numbers, gradients, neon accents), the outdated university portal (dense tables, default typography, flat colors from another era), and the playful consumer app (illustrations, flashy animation, casual tone).

**Key Characteristics:**

- Restrained color: ink, hairlines and one institutional red, with state colors reserved for state.
- State is never color alone: every cleaning state pairs tint, icon and text.
- Mobile-first with a 44px touch floor, scaling to a stacked-to-table admin history.
- Flat at rest: hairline borders carry structure; shadow is feedback, not decoration.
- Fixed rem type scale and exact motion budget (150 to 200 ms), no choreography.

## 2. Colors

A restrained palette: neutral ink and hairlines, one institutional red, and a two-color state vocabulary (green and red) used only for cleaning states.

### Primary

- **ESPOCH Seal Red** (#bc0613): The header band, the primary button, links and the focus ring. White on it measures 6.6:1. Its deeper steps (#9a0510 hover, #7a040d pressed) are interaction states only.
- **Seal Tint** (#fbeaeb): The faint wash behind brand-tinted callouts. Text on it uses the deep red (#7a040d).

### Secondary

- **Institutional Bronze** (#b5a880): A 3px rule under the header and nothing else. It is a structural trim, never a fill and never text.

### Neutral

- **Ink** (#212121): Body text on the page. 15:1 on the page color.
- **Ink Heading** (#292929): Headings and classroom names.
- **Ink Muted** (#5c646e): Secondary text and table labels. 5.6:1 on the page color.
- **Ink Subtle** (#69727d): Timestamps, placeholders, chevrons. 4.55:1 on the page color, the floor of the system.
- **Hairline** (#e3e3e3) and **Hairline Strong** (#c9ccd1): Card edges, dividers and input borders respectively.
- **Page** (#f7f7f7), **Surface** (#ffffff), **Surface Alt** (#f4f4f4): The three flat layers; table headers and hover rows use Surface Alt.

### State colors (one set per cleaning state, each with foreground, background, border and solid)

- **Limpio**: green foreground #085d3a on #ecfdf3, border #abefc6, solid #17b26a.
- **Sucio**: red foreground #912018 on #fef3f2, border #fecdca, solid #d92d20.

### Warning (not a cleaning state)

- **Warning Amber**: foreground #93370d on #fffaeb, border #fedf89, solid #f79009. Used for the required-photo field and for notices. It never appears on a badge or a classroom tile.

A dark theme exists (selected by `data-theme` or the system preference) with its own values for every token; the red lifts to #b0050f with a #8f040e header, text to #ececec on #121212, and state foregrounds brighten (#75e0a7, #fda29b) and the warning amber lifts to #fec84b on deep tinted backgrounds.

### Named Rules

**The Seal Rule.** Brand red covers the header and the single primary action per view, roughly 10% of any screen at most. If red appears on a card, a heading or a divider, it is wrong.
**The Never Color Alone Rule.** A cleaning state is always tint + icon + text. Removing the color must leave the state fully readable.
**The Subtle Floor Rule.** Ink Subtle (#69727d) is the lightest text the system allows. Never go lighter "for elegance"; it already sits at 4.55:1.

## 3. Typography

**Display Font:** Work Sans (with system-ui sans fallbacks), used for headings and classroom names only.
**Body Font:** Inter (with system-ui sans fallbacks), used for everything else: body, labels, buttons, data.

**Character:** A sturdy grotesque for headings over a neutral workhorse sans for reading. The pairing is administrative and unfussy; no display face ever appears in controls or data.

### Hierarchy

- **Headline Large** (700, 1.75rem, 1.2): Page titles (h1).
- **Headline Medium** (700, 1.375rem, 1.2): Section titles (h2) and the header wordmark.
- **Title** (700, 1.125rem, 1.2): Card titles and classroom names on wide screens (h3).
- **Body** (400, 1rem, 1.5): Default text. Prose caps at 65 to 75ch; table cells run denser.
- **Label** (600, 0.875rem, 1.5): Field labels, buttons, table headers.
- **Caption** (600, 0.75rem, 1.2): Badges and timestamps.

### Named Rules

**The Fixed Scale Rule.** The scale is rem-based and fixed, a step ratio near 1.2. No `clamp()` headings: this is a tool users open at consistent sizes, and fluid type only misbehaves in the header and cards.
**The Headings-Only Display Rule.** Work Sans never sets a button, input, badge or table cell.

## 4. Elevation

Flat by default. Structure comes from hairline borders and the three flat layers (Page, Surface, Surface Alt), not from shadow. A shadow appears only to answer a state: a card lifting on hover, a menu opening.

### Shadow Vocabulary

- **Rest** (`box-shadow: 0 1px 2px rgb(16 24 40 / 6%)`): Cards and classroom tiles, barely there, so they read as paper on the page.
- **Hover** (`box-shadow: 0 4px 12px rgb(16 24 40 / 8%), 0 1px 3px rgb(16 24 40 / 6%)`): Interactive cards on hover, paired with a 1px lift.
- **Overlay** (`box-shadow: 0 12px 32px rgb(16 24 40 / 14%)`): The user menu and the login card.

### Named Rules

**The Hairline First Rule.** Reach for a 1px hairline before a shadow. If a surface needs separating from its neighbor and a border does it, no shadow.

## 5. Components

### Buttons

- **Shape:** Gently squared corners (6px), 44px minimum height, 8px 16px padding, label type.
- **Primary:** ESPOCH Seal Red with white text. Hover steps to the strong red (#9a0510), pressed to the deep red (#7a040d) with a 1px downward nudge. One per view.
- **Secondary (default):** White surface, strong hairline border, ink text; hover fills with Surface Alt.
- **Ghost:** Transparent with no border, for low-emphasis actions. Defined in the Button component but not used in any view yet.
- **Disabled:** 65% opacity with a progress cursor; no color change.
- **Focus:** A 2px red outline with 2px offset, plus a soft 3px red ring on inputs.

### Inputs / Fields

- **Style:** White surface, 1px strong hairline, 6px radius, 44px minimum height; label above in Label type, hint below in Ink Muted.
- **Focus:** Border turns seal red and a 35% red ring appears; the outline is replaced, never removed.
- **Placeholder:** Ink Subtle, holding the 4.5:1 floor.
- **Error:** The sucio colors as an alert block above or below the field, with icon and text.

### Cards / Containers

- **Corner Style:** 10px.
- **Background:** Surface on a Page backdrop.
- **Shadow Strategy:** Rest shadow, hairline border.
- **Padding:** 16px, 24px from 640px up. Cards are never nested.

### Cleaning-state badge

The signature component. A pill (999px) with a 1px border, icon, and caption-weight label, built from the state colors. Always icon + text, never a bare dot.

### Classroom tile (grid)

A linked card showing the classroom name (Work Sans, 700), the state badge, and the last-updated time in Caption. The grid is a genuine repetition of the same record, so state is what differentiates tiles: a `sucio` tile also takes the sucio border. Hover lifts 1px with the Hover shadow and turns the chevron red.

### Navigation

- **Header:** Full-width seal-red band with a 3px Institutional Bronze rule beneath it, white ESPOCH wordmark in Work Sans next to the app name, separated by a thin divider. Sticky.
- **Links:** Inline bar from 640px; collapses into the user menu below that. Language switch and theme toggle sit beside the menu on wide screens.
- **Current page:** Indicated by the active link treatment plus `aria-current`, never color alone.

### Admin history table

Stacked label/value rows on mobile; a real table from 640px with Surface Alt headers in Label type and hairline row dividers. The row, not a card, is the unit.

## 6. Do's and Don'ts

### Do:

- **Do** let the cleaning state be the first and heaviest thing on every screen: badge, icon and text together.
- **Do** keep the ESPOCH red to the header band and one primary action per view (The Seal Rule).
- **Do** use 44px as the minimum touch target and keep every text pair at 4.5:1 or better; Ink Subtle (#69727d) is the floor.
- **Do** separate surfaces with 1px hairlines first, shadow only as hover or overlay feedback.
- **Do** keep motion to 150 to 200 ms with `cubic-bezier(0.22, 1, 0.36, 1)` and honor `prefers-reduced-motion`.
- **Do** present the photo-evidence requirement as a natural step in the flow, with a clear label and hint, not as an error state. Ask for the photo only when the report is `sucio`; a `limpio` report stays a single tap.
- **Do** write labels as verb + object ("Save report", "Create user") in plain, direct, institutional language.

### Don't:

- **Don't** build a generic SaaS dashboard: no identical cards with big numbers, no gradients, no neon accents.
- **Don't** drift into an outdated university portal: no dense default-typography tables, no flat colors from another era.
- **Don't** add playful consumer-app touches: no illustrations, no flashy animation, no casual tone.
- **Don't** signal a state with color alone; every state needs its icon and text.
- **Don't** use `border-left` or `border-right` wider than 1px as a colored stripe on cards, rows or alerts.
- **Don't** use gradient text, glassmorphism, or a hero-metric block (big number, small label, gradient accent).
- **Don't** set Work Sans on buttons, inputs, badges or table cells; it is for headings and classroom names.
- **Don't** nest cards, or open a modal where an inline or progressive pattern works.
- **Don't** animate layout properties or add page-load choreography; state change and feedback only.
