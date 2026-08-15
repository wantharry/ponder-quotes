# QuotesTV (tvOS)

Ambient full-screen quote display for Apple TV: rotates quotes at a
frequency you pick, filterable by topic, over a crossfading background
photo, with optional looped ambient music. Fully offline — everything is
bundled in the app, no backend, no OCI deploy (unlike `moviesearch`, which
needs one for its live movie database/API).

Unlike `moviesearch`'s tvOS app, `QuotesTV.xcodeproj` is a real, checked-in Xcode project
(hand-built to match Xcode 26.2's file-system-synchronized-group format — any file dropped
into `QuotesTV/` is picked up automatically, no manual "add to target" step needed). It's
already been built and run end-to-end on this machine: `xcodebuild ... build` succeeds for
both `generic/platform=tvOS Simulator` and a real booted "Apple TV 4K (3rd generation)"
simulator, and `xcrun simctl launch` + a screenshot confirmed quotes actually render
correctly (crossfading gradient background, serif quote + author, centered layout).

## What's here

```
QuotesTV.xcodeproj/       — real, buildable Xcode project (team KPNYT6G5XD,
                             bundle id com.realintuition.QuotesTV, tvOS 26.2 target)
QuotesTV/
  QuotesTVApp.swift       — app entry point
  Models/
    Quote.swift            — Codable model matching Data/quotes.json
    Topic.swift             — topic enum (must match the tags used in quotes.json)
    RotationFrequency.swift — how-often-to-change-quote options
    AppSettings.swift       — persisted user prefs (topic, frequency, music)
  Store/
    QuoteStore.swift            — loads quotes.json, filters by topic, times rotation
    BackgroundImageCatalog.swift — maps a quote's topic to a background image name
    AudioPlayerService.swift     — loops a bundled ambient track
  Views/
    RootView.swift      — wires settings/store/audio together
    DisplayView.swift   — the fullscreen quote + background + crossfade
    SettingsView.swift  — topic / frequency / music picker (Play/Pause opens it)
  Data/
    quotes.json          — 178 curated, real, attributed quotes across 14 topics
                            (112 original + 66 classical philosophy quotes: Aristotle,
                            Plato, Socrates, Marcus Aurelius, Kant, Descartes, Nietzsche,
                            Gandhi, Ayn Rand)
  Assets.xcassets/        — app icon, top shelf image, accent color (placeholder art —
                             solid navy/indigo/gold layers, see below to replace)
```

## Setup on the MacBook

1. Open `QuotesTV.xcodeproj` in Xcode — no project creation step needed, it's already here.
2. Signing & Capabilities tab → the team is already set to `KPNYT6G5XD` (same free-tier
   personal Apple ID team `moviesearch` uses, sideloading-only, no paid account needed). If
   Xcode complains about the team not matching your signed-in Apple ID, just re-pick your
   own team here — everything else stays the same.
3. Connect the Apple TV: Xcode → Window → Devices and Simulators → pair it (same network,
   or over USB-C the first time). Select it as the run destination, hit Run. (Or just pick
   an Apple TV simulator from the scheme's destination menu — no device needed to try it.)

It'll run immediately with quotes rotating over a placeholder gradient background and no
music — see below to add the actual photos/music.

## Adding backgrounds (the "picture" part)

`BackgroundImageCatalog.swift` expects images in `Assets.xcassets` named `bg-<topic>-1`,
`bg-<topic>-2`, `bg-<topic>-3` for each of the 14 topics, plus `bg-general-1/2/3` as the
fallback pool. Nothing ships by default — any topic with no matching images just shows the
gradient, so the app runs fine before you've added any.

Deliberately left for you to pick, since "feels beautiful" is personal — but if you want a
quick start, Unsplash (https://unsplash.com) is royalty-free for this use (no attribution
legally required, though appreciated) and searches well by mood per topic, e.g.:
- `motivation`/`courage`/`success` → mountain summits, sunrise, open roads
- `love`/`friendship`/`gratitude` → warm light, hands, golden hour
- `mindfulness`/`simplicity` → minimal landscapes, still water, fog
- `wisdom`/`life`/`change` → old trees, night sky, paths
- `creativity` → color, texture, abstract light
- `happiness` → bright open skies, water, laughter-adjacent warmth

Export at 1920×1080 or larger (tvOS scales down fine, not up), add each to
`Assets.xcassets` as an image set named exactly as above.

## Music (the "feels beautiful" part)

Three tracks ship in `QuotesTV/`: `ambient-1.mp3` (Soaring), `ambient-2.mp3` (Healing),
`ambient-3.mp3` (Overheat) — all by Kevin MacLeod (incompetech.com), Creative Commons
Attribution 4.0. `AudioPlayerService.swift` picks one at random each time playback starts
(app launch, or toggling Music back on) and loops it; the required attribution is in
Settings' Music section footer. With none present it'd be a silent no-op, not a crash, so
the app still runs fine if you ever remove them.

To swap in your own instead: replace the `ambient-N.mp3` files (any names, update
`AudioPlayerService.trackNames` to match) and update/remove the Settings attribution line
if the new tracks don't need it. Other royalty-free sources: YouTube Audio Library
(studio.youtube.com → Audio Library, no attribution required) or Pixabay Music
(pixabay.com/music, no attribution required). Keep tracks long (4+ min) and
seamless-looping so the 10s–3min quote rotation doesn't make the loop point obvious.

## Extending the quote deck

`Data/quotes.json` is a flat array of `{ id, text, author, topics: [...] }`. Topics must be
one of the slugs in `Models/Topic.swift`. To add a topic, add a case there and matching
image names in `BackgroundImageCatalog.swift`.
