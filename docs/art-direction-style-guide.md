# FocusForge — Art Direction & Visual Style Guide

**Direction:** Soft Illustration  
**Aesthetic:** Organic, warm, atmospheric — premium but approachable  
**Reference mood:** Headspace companion warmth × Hollow Knight silhouette economy × Genshin chibi charm  
**Version:** 0.1.0  

---

## 1. Design philosophy

FocusForge has two emotional registers that work in contrast:

**Focus mode** is a tool. Near-black canvas. One accent color (the progress ring). Typography is the hero. Everything else recedes. The character is absent — this is distraction-free deep work.

**Reward mode** is a world. Atmospheric depth, layered radial glows, dramatic character lighting. This is where investment in art pays off. The contrast between modes *is* the dopamine hit — the shift from restraint to richness.

The character exists at the intersection: a consistent emotional anchor that bridges both states. In focus mode, a small streak badge with a tiny character silhouette. In reward mode, the full character celebrating on a lit stage.

---

## 2. Character style

### 2.1 Proportions

- **Head-to-body ratio:** ~1.4:1 (large head, compact body — not as extreme as chibi, more like children's book illustration)
- **Overall silhouette:** Rounded, organic, slightly pear-shaped. No sharp angles on the body.
- **Limbs:** Stubby, tapered at the wrist/ankle. No visible fingers — hands are rounded nubs. Feet are oval pads.
- **Face:** Eyes are simple filled circles (3-5px radius at standard scale) with a single specular highlight dot. No iris detail. Mouths are a single curved stroke. Blush is a low-opacity warm ellipse on each cheek.

### 2.2 Shading technique (the "soft" in soft illustration)

Every shape uses exactly three layers:

| Layer | Purpose | Opacity | Placement |
|-------|---------|---------|-----------|
| Base fill | The solid flat color | 85-100% | Full shape |
| Highlight | Lighter shade, organic blob | 30-55% | Offset toward top-left (global light source) |
| Shadow | Darker shade, organic blob | 20-35% | Opposite side (bottom-right) |

The "softness" comes from two things:
1. Highlight and shadow shapes are **organic paths**, not hard circles or rects
2. Opacity is low enough that transitions feel gradual, not sharp

**Production note:** In Procreate, this is literally one layer per step with a soft round brush at the listed opacity. In Figma, it's blurred ellipses clipped to the parent shape. In code (SVG), it's overlapping `<path>` elements with `opacity` attributes.

### 2.3 Color construction per body part

| Part | Base hex | Highlight hex | Shadow hex |
|------|----------|---------------|------------|
| Skin (Light) | #ECC8A8 | #F8E0CC | #D4A888 |
| Skin (Medium) | #C68642 | #D49A58 | #A06A30 |
| Skin (Dark) | #6B4226 | #8A5A38 | #4A2E1A |
| Blue body | #5A80D0 | #7AA0E8 | #3A60A0 |
| Red body | #C85040 | #E07060 | #903830 |
| Green body | #48A068 | #68C088 | #2E7848 |
| Blue hair | #6888D8 | #88A8F0 | #5070B8 |
| Red hair | #B83828 | #D85040 | #8A2820 |
| Green hair | #38A058 | #58C078 | #288040 |

### 2.4 Expression system

Minimum viable emotion set for MVP:

| Expression | Eyes | Mouth | When shown |
|------------|------|-------|------------|
| Neutral (idle) | Filled circles + highlight | Gentle upward curve | Default state |
| Happy (celebrate) | Larger circles, bigger highlights | Wide upward curve, open | Session complete, milestone |
| Determined (focus) | Slight squint (flattened top) | Flat line, slight upturn at one end | During active session (if shown) |
| Peaceful (rest) | Closed (curved strokes, concave up) | Soft smile | Break time |
| Sad (streak lost) | Normal circles, no highlight | Downward curve | Streak break |
| Excited (reward) | Very large, sparkle highlight | Open wide smile | Rare item unlock |

### 2.5 Preset characters

| Name | Personality | Color scheme | Distinguishing feature |
|------|-------------|--------------|----------------------|
| Spark | Cheerful, eager | Blue body, blue hair, light skin | Wide-open eyes, upbeat default expression |
| Ember | Determined, fierce | Red body, red hair, medium skin | Slight smirk, angled eyebrows |
| Sage | Calm, wise | Green body, green hair, fair skin | Closed peaceful eyes, flowing side hair |

---

## 3. Sprite layer system

### 3.1 Layer order (back to front)

```
1. Wings (optional cosmetic)
2. Feet (left, right)
3. Body
4. Head
5. Hand left
6. Weapon (optional cosmetic, behind right hand)
7. Hand right
8. Eyes
9. Mouth
10. Hair
11. Horns (optional cosmetic, on top of everything)
```

### 3.2 Sprite sheet specifications

- **Canvas size per layer:** 512×512px (exports at 1x; use @2x for retina = 1024×1024)
- **Character should occupy ~60-70% of the canvas** vertically, centered
- **File format:** PNG with transparency
- **Naming convention:** `{part}{variant}.png` — e.g., `head1.png`, `eyes3.png`, `horn2.png`

### 3.3 How cosmetics attach to organic shapes

Unlike geometric characters where cosmetics tile cleanly, soft illustration cosmetics need to be **drawn for the specific body shape**. This means:

- Horns are drawn with their anchor point matching the head's crown curve
- Wings are drawn matching the body's shoulder line
- Weapons are drawn matching the right hand's position and angle
- Each cosmetic includes its own highlight/shadow layers baked in

**This is why the launch catalog should be small but polished** — each cosmetic is a hand-crafted piece, not a recolor.

### 3.4 Color tinting strategy

The current codebase uses `colorMultiply` for runtime tinting. This works with soft illustration **if the source sprites are painted in a neutral warm gray** that accepts tint well.

Recommended base sprite colors for tintable parts:
- Skin sprites: Paint in #E0D0C0 (warm neutral). `colorMultiply` with skin hex produces correct result.
- Hair sprites: Paint in #C0C0C0 (cool neutral). `colorMultiply` with hair hex produces correct result.
- Body sprites: Paint in #B0B0B0 (mid neutral). `colorMultiply` with body hex produces correct result.

**Important:** Highlights and shadows survive tinting because they're lighter/darker variants of the same neutral. The relative luminance relationship is preserved.

---

## 4. Cosmetic items — rarity visual language

| Rarity | Shading | Border treatment | Animation | Inventory card |
|--------|---------|-----------------|-----------|----------------|
| Common | Standard 3-layer | Thin gray stroke (#888) | None | Gray border |
| Rare | 3-layer + extra specular highlight | Purple stroke (#9B59B6) | None | Purple border, subtle inner glow |
| Animated Rare | 3-layer + specular + shimmer | Orange stroke (#E67E22) | Slow shimmer cycle (2s CSS animation) | Orange border, animated sparkle |

### Rarity differentiation at small sizes (inventory grid ~72px)

At 72px the shading detail is invisible. Rarity reads through:
1. **Border color** (most important — instant visual scan)
2. **Silhouette distinctiveness** (rare items have more complex shapes)
3. **Animated badge** for animated rare (small particle or shimmer on the thumbnail)

---

## 5. App environment design

### 5.1 Focus mode

- **Background:** #0A0A0F (near-black with slight blue undertone)
- **Ambient light:** Single radial gradient, rgba(99,140,255,0.06), centered on progress ring
- **Progress ring:** #4A7BF7 primary stroke, same color at 0.15 opacity for glow aura
- **Typography:** SF Pro (or system default), ultralight/thin weight for timer, medium for labels
- **Accent colors:** Only the ring color. Everything else is white at 30-90% opacity.
- **Character presence:** None during active session. Optional: tiny silhouette in streak badge.

### 5.2 Reward / celebration mode

- **Background:** Gradient from #0C0820 → #241850 → #0C0820 (deep purple atmosphere)
- **Ambient light:** Multiple radial gradients — purple primary (rgba(180,120,255,0.15)), warm secondary (rgba(255,180,60,0.05))
- **Particle effects:** Small dots (1-2px) at low opacity, scattered. Static positions (animate on display only).
- **Character platform:** Radial gradient ellipse beneath feet, matches character's primary body color at 15-25% opacity
- **Reward cards:** rgba(255,255,255,0.05) background, rgba(255,255,255,0.1) border. Frosted glass feel.
- **XP/Coin numerals:** Color-coded — XP is gold (#F0C840), Coins are amber (#F0A040), Freezes are cyan (#60C8FF)

### 5.3 Character tab / dressing room

- **Background:** Same near-black as focus mode (#0E0E1A → #1A1A30 gradient)
- **Character display area:** Centered, with subtle ambient glow and ground plane line
- **Ground plane:** 1px horizontal line at rgba(255,255,255,0.06), with small radial glow beneath
- **Inventory grid:** Dark card cells with rarity-colored borders. Locked items at 30-40% opacity.
- **Color picker swatches:** 32px circles with 2.5px selection stroke

### 5.4 The mode shift (focus → reward transition)

This is the highest-leverage design moment. The transition should feel cinematic:

1. Timer hits zero → ring completes to full circle, brief pulse
2. Background shifts from near-black to deep purple (0.6s ease-out)
3. Character fades up from below center (0.4s, slight scale 0.9→1.0)
4. Reward card slides up from bottom (0.3s, after character settles)
5. XP/Coin numbers count up from 0 (0.8s, eased)
6. If milestone: additional beat — trophy icon scales in, item card reveals with rarity-appropriate treatment

Total sequence: ~2.5 seconds. Must be skippable (tap to complete instantly). Must respect `UIAccessibility.isReduceMotionEnabled` (cross-fade variant, no spatial movement).

---

## 6. Color system

### 6.1 App-wide palette

| Token | Hex | Usage |
|-------|-----|-------|
| Background Primary | #0A0A0F | Focus mode, main canvas |
| Background Secondary | #0E0E1A | Cards, elevated surfaces |
| Background Tertiary | #161628 | Dressing room mid-zone |
| Background Reward | #0C0820 → #241850 | Celebration mode gradient |
| Accent Blue | #4A7BF7 | Focus ring, primary actions |
| Accent Purple | #7B5FD4 | Reward mode CTAs, rare items |
| Streak Orange | #F0A040 | Streak badge, coin indicators |
| XP Gold | #F0C840 | XP indicators |
| Freeze Cyan | #60C8FF | Streak freeze indicators |
| Success Green | #4CAF50 | Completed states, checkmarks |
| Text Primary | rgba(255,255,255,0.92) | Headings, timer |
| Text Secondary | rgba(255,255,255,0.5) | Labels, descriptions |
| Text Tertiary | rgba(255,255,255,0.3) | Hints, disabled |
| Border Default | rgba(255,255,255,0.06) | Cards, dividers |
| Border Emphasis | rgba(255,255,255,0.12) | Selected states, hover |

### 6.2 Rarity colors

| Rarity | Primary | Background (10%) | Border |
|--------|---------|-------------------|--------|
| Common | #888888 | rgba(136,136,136,0.1) | rgba(136,136,136,0.3) |
| Rare | #9B59B6 | rgba(155,89,182,0.1) | rgba(155,89,182,0.3) |
| Animated Rare | #E67E22 | rgba(230,126,34,0.1) | rgba(230,126,34,0.3) |

---

## 7. Typography

| Element | Weight | Size | Tracking | Color |
|---------|--------|------|----------|-------|
| Timer display | Ultralight (100) or Thin (200) | 56pt | -1pt | Text Primary |
| Session type label | Regular (400) | 11pt | 2pt, uppercase | Text Tertiary |
| Navigation title | Medium (500) | 17pt | -0.3pt | Text Primary |
| Reward headline | Medium (500) | 22pt | -0.3pt | Text Primary |
| Reward subhead | Regular (400) | 13pt | 0pt | Text Secondary |
| Stat number | Medium (500) | 24pt | 0pt | Per-category color |
| Stat label | Regular (400) | 11pt | 0pt | Text Secondary |
| Inventory label | Regular (400) | 10pt | 0pt | Text Secondary |
| Badge text | Bold (600) | 10pt | 0.3pt | Per-context |

Font: System default (SF Pro on iOS). Monospaced variant for timer digits.

---

## 8. Production paths

### Option A: Commission an illustrator ($300-800)

**Best for:** Highest quality, most distinctive result  
**Where to find:** ArtStation (search "chibi character design" or "cute game character"), Fiverr (search "game character sprite sheet"), or reach out to illustrators whose style you like on Instagram/Twitter.

**Creative brief to send:**
> "I need a character sprite system for a mobile productivity app. Style reference: soft children's book illustration — organic shapes, 3-layer shading (base/highlight/shadow), simple dot eyes with specular highlight. Each character needs: base body, 3 head variants, 3 hair variants, 7 eye variants, 8 mouth variants, 5 horn variants, 1 wing set, 3 weapon variants, 2 hand variants, 2 foot variants. All on separate PNG layers at 512×512 with transparency. Characters are painted in neutral gray tones for runtime color tinting. I have an existing layer system in SwiftUI that composites these. Budget: [your range]. Timeline: 2-3 weeks."

**Attach this style guide as reference.**

### Option B: AI-generated → cleaned up ($0-50)

**Best for:** Rapid iteration on the look, then manual cleanup  
**Process:**
1. Generate concept art in Midjourney/DALL-E: "soft illustration character design, chibi proportions, children's book style, simple dot eyes, rounded organic shapes, [skin tone], [hair color], [body color], white background, character sheet"
2. Use the output as a *reference* (not a final asset) — trace over it in Procreate or Illustrator
3. Separate into layers manually
4. Paint each layer in neutral tones for tinting

**Strengths:** Fast concept exploration, good for finding the exact "feel"  
**Weaknesses:** You still need to manually separate layers and ensure tintability. AI won't generate sprite-sheet-ready layered assets.

### Option C: Self-produced in Procreate ($0 + time)

**Best for:** Full creative control, no dependency on others  
**Process:**
1. Set up a 1024×1024 canvas (for @2x) with a centered guide grid
2. Paint each body part on a separate Procreate layer using a soft round brush
3. For each part: base fill layer → highlight layer (lighter color, 40% opacity) → shadow layer (darker color, 25% opacity)
4. Export each layer as individual PNG
5. Use neutral gray tones and test with `colorMultiply` in SwiftUI

**Estimated time:** 8-15 hours for the full launch catalog if you're comfortable with a drawing tablet  
**Learning curve:** Moderate. The shading technique is simple; the challenge is consistency across many parts.

### Option D: Figma/SVG production ($0 + time)

**Best for:** Developers who think in code, not paint  
**Process:**
1. Build characters as layered SVG in Figma or directly in code
2. Use overlapping ellipses with blur for the "soft" shading effect
3. Export as SVG, convert to PNG at target sizes
4. Or: render directly in SwiftUI using paths and opacity layers (similar to what's demonstrated in this guide's visual examples)

**Strengths:** Infinitely editable, scales perfectly, no drawing skill needed  
**Weaknesses:** Hardest to get the "organic" feel — tends toward vector-clean rather than illustrated-warm

---

## 9. Launch catalog (MVP)

Keep it small and polished. Every item should feel crafted.

### Base characters: 3 (Spark, Ember, Sage)
### Eyes: 7 variants
### Mouths: 8 variants  
### Heads: 3 shapes
### Hair: 3 styles

### Cosmetics:

| Item | Slot | Rarity | Acquisition |
|------|------|--------|-------------|
| Imp Points | Horns | Common | Day 3 milestone |
| Wide Spikes | Horns | Common | 50 coins |
| Alicorn | Horns | Rare | Day 30 milestone |
| Battle Scarred | Horns | Rare | 100 coins |
| Ram Curls | Horns | Animated Rare | 200 coins |
| Shadow Wings | Wings | Rare | Day 14 milestone |
| Pea Shooter | Weapon | Common | Day 7 milestone |
| Boomstick | Weapon | Rare | 100 coins |
| Ray Gun | Weapon | Animated Rare | Day 60 milestone |

**Total cosmetic items:** 9 (5 horns, 1 wing, 3 weapons)  
**Total art assets needed:** ~45-50 individual PNG layers (including base character parts, expressions, and cosmetics)

---

## 10. What "expensive" means — a checklist

Before shipping any screen, verify:

- [ ] Does every surface have atmospheric depth? (Radial glow, ground plane, or gradient — never flat solid backgrounds)
- [ ] Do transitions between states feel intentional? (Not default SwiftUI `.sheet` presentation)
- [ ] Is there exactly one focal element per screen? (Timer OR character OR reward — never competing)
- [ ] Are colors used sparingly and with purpose? (Max 2-3 accent colors per screen)
- [ ] Does the character have a visible light source? (Highlight always top-left, shadow always bottom-right)
- [ ] Are cosmetic items visually distinct at 72px? (Silhouette test: can you tell them apart in grayscale?)
- [ ] Is vertical rhythm consistent? (Spacing follows a scale: 4, 8, 12, 16, 20, 24, 32, 40px)
- [ ] Is typography using specific weights, not defaults? (Thin for timer, Medium for headlines, Regular for body)
- [ ] Does the reward moment feel like a *sequence*, not a *screen*? (Elements animate in order, not all at once)
- [ ] Does `Reduce Motion` get a considered alternative? (Cross-fade, not "disable all animation")
