# FocusForge — App Icon Design Brief

Required for App Store submission. Target deliverable: **1024×1024 PNG**
at the path `app/FocusForge/Assets.xcassets/AppIcon.appiconset/`.

## The constraint

The icon is the smallest, most repeated surface of the brand. It will
appear in:

- App Store search results (24×24 → 90×90 px range)
- App Store product page hero (450×450 px)
- iOS home screen (60×60 → 180×180 px range)
- iOS Spotlight + Settings (29×29 → 87×87 px range)
- Notification badges
- Documentation, screenshots, blog posts

It must read at **24×24 pixels** AND at **1024×1024 pixels** without
re-design. That constraint dominates every other design consideration.

## What it must communicate

In one glance:

1. **This is a focus app.** Not a generic productivity, not a game,
   not a notes app. The vibe should land as "I'm doing deep work."
2. **It has a character/RPG dimension.** Something hints at the
   character meaning layer — without making it look like a kids' game.
3. **It's atmospheric and dark.** Aligns with the in-app two-mode
   philosophy. Not a bright light app on the home screen.

It must NOT look like:

- Generic timer apps (clocks, hourglasses, simple numbers)
- Other Pomodoro apps (tomato icons, fruit icons — table stakes that
  signal "category app")
- Mainstream productivity (gear icons, checkmark icons, list icons)
- AAA RPG games (overly detailed character art, weapons)
- Wellness/meditation (smooth gradients, lotus shapes)

## Visual direction

Three directions worth exploring, ranked by my conviction:

### Direction A: Stylized character bust (recommended)

The FocusForge character — the red imp from the in-app sprite — but
rendered at icon-asset quality. Cropped to just the head/shoulders so
it reads at small sizes. Strong silhouette: distinct horns, simple
face. Background a deep purple gradient (matching reward mode) with a
subtle radial glow behind.

Why this is strong:
- Reinforces "character" positioning at first impression
- Distinctive silhouette holds at 24×24
- Dark purple aligns with brand
- The horns make it instantly recognizable

Reference: think Crossy Road's character heads, or Monument Valley's
princess — character icons that read at any size.

### Direction B: Progress ring + character interior

The FocusForge timer ring (three-layer glow composition) rendered at
icon scale, with a small silhouette of the character INSIDE the ring,
filling about 60% of the ring's interior. The ring is colored deep
purple at the bottom transitioning to blue at the top (focus → reward
mode in one symbol).

Why this is also strong:
- Carries the timer + character meaning together
- The ring is unique to FocusForge (most apps don't use a glow ring)
- Works at small size if the character silhouette stays simple

Risk: ring + interior content can compete at small sizes if not
balanced carefully.

### Direction C: Pure ring with crown/horns silhouette

The glow ring alone, but the ring's stroke at the top forms a
crown-like cluster of horns. Pure symbol. Most abstract.

Why this could work:
- Unique enough to not look like any other timer icon
- Reads at any size
- More "brand-mark" feel, less character-y

Risk: loses the character connection. The horns might read as
generic ornament rather than "this is the character."

## Color palette (use existing FFTheme tokens)

```
Background colors (gradient stops):
  #0C0820  (reward gradient top - deep purple-black)
  #241850  (reward gradient mid - rich purple)
  #1A0E40  (interpolated, for icon depth)

Foreground accents:
  #4A7BF7  (FFTheme.Accent.blue — focus mode signal)
  #7B5FD4  (FFTheme.Accent.purple — reward mode)
  #B478FF  (atmospheric glow highlight)
  #F0A040  (FFTheme.Accent.orange — only if streak flame appears)

Character base colors (if Direction A or B):
  Skin:  #F4D3B8 (light) or per Character.bodyColorHex
  Body:  #CD5C5C (red imp default — most iconic)
  Hair:  #E2B339 (golden — matches default character)
  Horns: #1A1A1A (black) — silhouette weight
```

## Composition rules

- **Centered subject.** No off-center compositions. iOS rounded
  corner mask shaves the corners; subject must survive that.
- **Padding from the edge.** Apple's icon spec gives a generous
  ~80px transparent buffer inside the 1024×1024 canvas. Subject
  occupies the inner ~860×860.
- **No text in the icon.** Apple's HIG explicitly discourages text
  on app icons because it doesn't translate to other sizes/contexts.
- **No transparency in the source PNG.** Background must be opaque.
  Apple applies the rounded mask separately.
- **High contrast.** The icon will sit next to colorful app icons
  on the home screen — atmospheric darks need a strong highlight to
  not get lost in the visual noise.

## Technical specs

- Format: PNG, no transparency, sRGB color space
- Size: 1024×1024 pixels (Apple generates all other sizes from this)
- DPI: 72 (doesn't matter for App Store but conventional)
- Compression: lossless (Apple may re-process)
- File path:
  `app/FocusForge/Assets.xcassets/AppIcon.appiconset/AppIcon@1024.png`
- Update Contents.json to reference the file:
  ```json
  {
    "filename": "AppIcon@1024.png",
    "idiom": "universal",
    "platform": "ios",
    "size": "1024x1024"
  }
  ```

## Pre-submission checks

- [ ] Test the icon at 24×24, 60×60, 87×87, 120×120, 180×180.
      Compose a quick mockup view stacking all sizes side-by-side. If
      the smallest size doesn't read, redesign the silhouette.
- [ ] View on the actual iOS home screen via TestFlight build. Things
      that read on a white App Store search result might disappear on
      a colorful home screen wallpaper.
- [ ] Compare next to 5 well-loved indie app icons on your own home
      screen (Bear, Things, Drafts, Streaks, Daylio). Does it hold its
      own visually?
- [ ] Run through Apple's HIG icon checklist:
      https://developer.apple.com/design/human-interface-guidelines/app-icons

## Design tools that can deliver this

If you're designing yourself:
- Figma (1024×1024 frame, export as PNG)
- Sketch + Sketch Mirror

If you're delegating:
- Hire on Twitter via #portfolio tag — indie iOS icon designers exist
- Briefs.app contracts artists who specialize in icon work
- 99designs / Dribbble for cheaper but variable quality

If you're going AI-assisted:
- Midjourney with prompt + "iOS app icon, 1024x1024, dark purple
  atmospheric, character bust, [direction-specific details]"
- Will need cleanup pass in Figma to remove background artifacts and
  align with FFTheme palette exactly

## Why not ship without an icon

Apple will reject a submission without a 1024×1024 App Store icon.
There's no path around this. The icon is hard requirement #1 on the
"App Store Submission Checklist" in
[`docs/app-store-listing.md`](app-store-listing.md).

The icon is also the single most-seen surface of the brand — every
user who hears about FocusForge will see the icon before they see any
other piece of the app. It deserves real care.

## Recommended next move

1. Sketch all three directions as 1024×1024 thumbnails (30 min
   exploration)
2. Pick the direction that wins
3. Refine to final 1024×1024 (2-4 hours depending on tool comfort)
4. Test at small sizes
5. Drop into the AppIcon.appiconset and rebuild
6. Get a second opinion before submission

Time budget: half a day end-to-end if working solo.
