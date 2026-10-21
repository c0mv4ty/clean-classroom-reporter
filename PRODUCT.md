# Product

## Register

product

## Users

Class presidents (`presidente`) who report the cleaning state of classrooms (`aulas`) from their phones, often between classes and standing up. They are students, not power users: the task must be obvious on first use. Admins (`admin`) review the full report history with evidence photos and create the presidents' accounts.

## Product Purpose

Aulas limpias is a micro app that keeps an honest, current record of whether each classroom is clean. A classroom is either clean (`limpio`) or dirty (`sucio`), and reporting it dirty requires photo evidence, enforced in the database. Success is a trustworthy state per classroom and a history an admin can audit without chasing anyone.

## Brand Personality

Institutional and sober. Serious, trustworthy, administrative in tone, carrying the ESPOCH identity (institutional red) without decoration. Plain, direct copy; the interface reads as an official tool, not a product pitch.

## Anti-references

- Generic SaaS dashboard: identical cards with big numbers, gradients, neon accents.
- Outdated university portal: dense tables, default typography, flat colors from another era.
- Playful consumer app: illustrations, flashy animation, casual tone that undermines seriousness.

## Design Principles

1. **State first.** The cleaning state of a classroom is the primary information on every screen; everything else supports reading or changing it.
2. **Evidence is part of the flow.** The photo requirement for a dirty report is a core rule, so the interface presents it as a natural step rather than an error to recover from; a clean report stays a single tap.
3. **Never color alone.** Every state pairs color with icon and text so it reads in sunlight, on cheap screens, and for color-blind users.
4. **Scan, sign in, report.** The core flow starts from a QR code on the classroom: scan, sign in only if needed (and land back on that classroom), then report. No browsing, searching or extra steps in between. Designed mobile-first for one-handed use, scaling up to a comfortable admin history view.
5. **Quiet authority.** Restraint over ornament: the institutional red is used with intent, and trust comes from clarity and consistency.

## Accessibility & Inclusion

Target WCAG 2.2 AA: contrast of at least 4.5:1 for text, visible focus, comfortable touch targets, full keyboard operation, and `prefers-reduced-motion` respected. Cleaning states must never rely on color alone. Interface available in Spanish and English.
