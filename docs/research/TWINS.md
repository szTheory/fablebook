# Fablebook's twins (fictional showcase products)

Fablebook is a library, so the organizations it serves are the **products that adopt it**. Its twins (see `GLOSSARY.md`) are fictional adopter products. Each one gets the full treatment: its own Book, its own canon (brand book, tokens, voice, glossary, personas, jobs) and a real Shell with Areas and Screens. Only the UI needs to exist, so we can push each design system as far as it will go. (INT-20261028-07, INT-20261028-08)

Each name says its domain. The visual directions are deliberately far apart, so the showcase proves Fablebook works for very different brands.

| Twin | Domain, modeled on | Primary locale(s) | Stresses | Visual direction |
|---|---|---|---|---|
| **Chatly** | Consumer messaging (LINE/WhatsApp-style) | ja (CJK) | Mobile-first, emoji, CJK line breaking, huge counts (unread, members), realtime/presence states, stale/disconnected, B2C | Playful and rounded; vivid violet/coral; dark-first; large radii; bubbly motion |
| **Logistify** | Freight-logistics **product family**: operator console (dispatchers; admin/settings is a section of it), shipper portal (customer membership portal), driver app (mobile-first PWA). Sennder/Flexport-style. One brand canon, three product canons, three Books | en, with **de** and **fr** Gettext translations | Real translation switching, long German compounds, dense data tables, keyboard-driven power users, bulk actions, B2B multi-tenant, many/boundary/pagination | Utilitarian and dense; cool greys with signal orange; compact density; tight radii; tabular numerals |
| **Finanza** | Personal finance (Monzo/YNAB-style) | es | Money (negatives, currency and locale formats, rounding), dates, charts, sensitive data, **brand-new empty account**, onboarding wizard | Bold numerics; deep teal and mint; large figures; confident geometric sans |
| **Shopadelic** | Indie shop platform (Shopify-style): the Shopadelic-branded **admin**, plus a **white-label merchant storefront** in which each merchant (a Shopadelic twin) brings its own theme, and guardrails catch unreadable merchant colors | fr | Imagery and its rights, brand-heavy storefront previews, product media grids, a small-business owner, self-hosted single tenant | Editorial and warm; serif display type; earthy terracotta and cream; image-led layouts |
| **Clinicly** | Clinic booking and patient portal (Zocdoc-style) | ar (**RTL**), with en | RTL mirroring, accessibility-critical flows (low vision, older users), denied/permission states, appointment slots and time zones, forms with validation | Calm and airy; high-contrast blue-green; large base type; generous spacing; minimal motion |

## What the set covers (checked for diminishing returns)
- **Scripts and direction:** Latin (en/de/fr/es), CJK (ja), Arabic RTL.
- **Translation paths:** Logistify uses real Gettext locale switching. The other twins carry their own native-language data.
- **Product shapes:** a single product (Chatly, Finanza, Clinicly), a product family under one brand (Logistify), and branded plus white-label under one company (Shopadelic).
- **Business shapes:** B2C (Chatly, Finanza), B2B multi-tenant (Logistify), small-business self-hosted (Shopadelic), regulated/sensitive (Clinicly, Finanza).
- **State classes:**
  - empty: Finanza new account
  - many and huge: Chatly, Logistify
  - boundary and pagination: Logistify
  - loading and stale: Chatly realtime
  - error: Logistify failed shipments, Finanza failed sync
  - denied: Clinicly permissions
  - long: Logistify de
  - intl: all
- **UI genres:** messaging, dense operator tables, dashboards and charts, media grids, multi-step forms and wizards, calendars and slots.
- **Personas:** each twin has at least one brand-new user and one power user.
- **Brand range:** playful vs utilitarian vs bold vs editorial vs calm; dark-first vs light-first; serif vs sans; compact vs spacious density.

A sixth twin would mostly repeat this matrix. The owner's own developer-infrastructure operator UIs (mailglass, accrue, scrypath, threadline) are covered by real dogfooding in the final (dogfood) phase rather than another fictional twin.

## Where they live
- All five are in `hosts/operator`, one Book per product (seven Books, since Logistify has three), mounted at `/admin/dev/fablebook/<twin>`. Each Book has its own brand theme and canon.
- This also proves that one app can host several Books with separate canons.
- Each brand book is produced with abracabrand (it stress-tests abracabrand too). Fablebook only reads it.
- **Process (INT-20261028-11):**
  1. A Fablebook Claude session and an abracabrand Claude session work together through abracabrand's designer-style interview.
  2. Each twin is described by its industry, its name and the starting direction above. Nothing more is specified, so the interview does the narrowing.
  3. The owner checks in at key moments to confirm the results are good and the process went well.
  4. Lessons learned are written back into abracabrand's planning.
- The twins power the Docker demo, docs screenshots, golden bundles and, later, the static demo site. They never ship in the Hex package.

## Rollout
- **In the design-canon phase:** Logistify, Chatly and Clinicly. Together they cover dense LTR with real translations, CJK mobile, and RTL with accessibility.
- **Before 1.0:** Finanza and Shopadelic.
