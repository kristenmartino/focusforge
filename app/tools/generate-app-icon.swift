#!/usr/bin/env swift
//
// FocusForge app icon generator.
//
// Produces AppIcon@1024.png at the canonical 1024×1024 App Store icon size.
// Run from the repo root:
//
//     swift app/tools/generate-app-icon.swift
//
// The PNG is written to:
//     app/FocusForge/Assets.xcassets/AppIcon.appiconset/AppIcon@1024.png
//
// Design intent (per docs/app-icon-brief.md "Direction B" hybrid):
//
// - Deep purple atmospheric radial gradient background (matches the
//   in-app reward-mode register so the icon reads as part of the same
//   world).
// - Glow progress ring rendered as a complete circle (three layers:
//   subtle track, wide aura at 18% opacity, thin crisp ring at 90%) so
//   the icon carries the timer's visual signature without literally
//   showing time progress.
// - Stylized flame at the center — the streak symbol. Orange gradient
//   from #F0A040 to #FF6B35 with subtle inner glow. Reads at small
//   sizes because the flame silhouette has high contrast against the
//   dark background.
//
// What this carries semantically:
// - The ring = focus / timer (the centerpiece of the app)
// - The flame = streaks / progression (the meaning layer)
// - The atmosphere = the brand's craft-led dark mode
//
// What it doesn't carry (deliberately):
// - The character (too detail-heavy at 24×24)
// - Text (Apple HIG forbids it)
// - Multiple subjects (one focal point reads better at small sizes)
//

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// MARK: - Canvas

let canvasSize = 1024
let canvasCG = CGFloat(canvasSize)
let center = CGPoint(x: canvasCG / 2, y: canvasCG / 2)

// MARK: - Color helpers

/// Build an sRGB CGColor from 0–255 RGB.
func rgb(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat = 1.0) -> CGColor {
    return CGColor(
        srgbRed: CGFloat(r) / 255.0,
        green: CGFloat(g) / 255.0,
        blue: CGFloat(b) / 255.0,
        alpha: a
    )
}

let colorSpace = CGColorSpaceCreateDeviceRGB()

// FocusForge brand colors (from FFTheme)
let bgPurpleMid    = rgb(36, 24, 80)    // #241850 — reward gradient mid
let bgPurpleDeep   = rgb(12, 8, 32)     // #0C0820 — reward gradient deep
let bgNearBlack    = rgb(10, 10, 15)    // #0A0A0F — focus mode background
let accentPurple   = rgb(123, 95, 212)  // #7B5FD4 — reward CTAs / rare
let accentPurpleLight = rgb(180, 120, 255)  // #B478FF — purple glow highlight
let flameOrange    = rgb(240, 160, 64)  // #F0A040 — streak / coins
let flameOrangeHot = rgb(255, 107, 53)  // #FF6B35 — flame hot core
let flameGold      = rgb(255, 220, 120) // #FFDC78 — flame inner highlight
let trackWhite     = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.04)

// MARK: - Context

guard let context = CGContext(
    data: nil,
    width: canvasSize,
    height: canvasSize,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    FileHandle.standardError.write("Failed to create CGContext.\n".data(using: .utf8)!)
    exit(1)
}

context.setShouldAntialias(true)
context.interpolationQuality = .high

// MARK: - 1. Background radial gradient

// Solid dark base first (no transparency in app icons).
context.setFillColor(bgNearBlack)
context.fill(CGRect(x: 0, y: 0, width: canvasSize, height: canvasSize))

// Radial gradient: deep purple center fading to near-black corners.
// Locations tuned so the central glow occupies roughly the inner 60% of
// the canvas — wide enough to "halo" the ring + flame composition, tight
// enough to leave the corners atmospheric and dark.
let bgGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [bgPurpleMid, bgPurpleDeep, bgNearBlack] as CFArray,
    locations: [0.0, 0.55, 1.0]
)!

context.drawRadialGradient(
    bgGradient,
    startCenter: center,
    startRadius: 0,
    endCenter: center,
    endRadius: canvasCG * 0.7,
    options: []
)

// MARK: - 2. Ambient purple glow halo

// A wider, softer purple glow centered behind the ring to amplify the
// atmospheric depth. Layered over the gradient to give the ring a sense
// of "sitting in light."
let haloGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [
        accentPurpleLight.copy(alpha: 0.22)!,
        accentPurple.copy(alpha: 0.10)!,
        CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0)
    ] as CFArray,
    locations: [0.0, 0.4, 1.0]
)!

context.drawRadialGradient(
    haloGradient,
    startCenter: center,
    startRadius: 0,
    endCenter: center,
    endRadius: canvasCG * 0.42,
    options: []
)

// MARK: - 3. Glow progress ring (three layers, full circle)

let ringRadius: CGFloat = canvasCG * 0.32     // ~328pt at 1024 canvas
let ringLineWidth: CGFloat = canvasCG * 0.022 // ~22pt crisp ring stroke
let auraLineWidth: CGFloat = ringLineWidth * 4 // wider aura

// Layer A: subtle track (very low opacity, full circle)
context.setStrokeColor(trackWhite)
context.setLineWidth(ringLineWidth)
context.strokeEllipse(in: CGRect(
    x: center.x - ringRadius,
    y: center.y - ringRadius,
    width: ringRadius * 2,
    height: ringRadius * 2
))

// Layer B: glow aura (wide, low opacity, purple gradient via shadow)
// We achieve the "glow" effect by stroking a purple ring with a soft
// shadow on the inside.
context.saveGState()
context.setStrokeColor(accentPurpleLight.copy(alpha: 0.32)!)
context.setLineWidth(auraLineWidth)
context.setLineCap(.round)
context.setShadow(
    offset: .zero,
    blur: canvasCG * 0.03,
    color: accentPurpleLight.copy(alpha: 0.55)
)
context.strokeEllipse(in: CGRect(
    x: center.x - ringRadius,
    y: center.y - ringRadius,
    width: ringRadius * 2,
    height: ringRadius * 2
))
context.restoreGState()

// Layer C: crisp ring (thin, high opacity, gradient stroke)
// CGContext doesn't directly support gradient strokes, so we use a
// solid color and add a subtle shadow to give it presence.
context.saveGState()
context.setStrokeColor(accentPurpleLight)
context.setLineWidth(ringLineWidth)
context.setLineCap(.round)
context.setShadow(
    offset: .zero,
    blur: canvasCG * 0.015,
    color: accentPurpleLight.copy(alpha: 0.7)
)
context.strokeEllipse(in: CGRect(
    x: center.x - ringRadius,
    y: center.y - ringRadius,
    width: ringRadius * 2,
    height: ringRadius * 2
))
context.restoreGState()

// MARK: - 4. Stylized flame

// Flame composed of two filled Bezier shapes — outer hot orange and
// inner gold core. The silhouette is the icon's reading anchor at
// small sizes, so it must read as fire even at 24×24.
//
// Anatomy of the shape:
// - Wide base (looks like fire's "footprint")
// - Slight narrowing in the middle
// - One curl at the upper-left (gives motion / leans into the wind)
// - Sharp pointed tip at top-right
//
// This is the SF Symbols "flame.fill" silhouette logic but
// hand-drawn so we control the gradient and proportions precisely.

let flameHeight: CGFloat = canvasCG * 0.36      // ~370pt — large + bold
let flameWidth: CGFloat = canvasCG * 0.22       // ~225pt
// CGContext Y-axis: 0 is at bottom-left, Y increases going UP. So the
// flame "base" (visually lower on screen) needs a SMALLER y value, and
// the tip (visually higher) needs a LARGER y. flameBottom is anchored
// in the lower portion of the ring interior.
let flameBottom = center.y - flameHeight * 0.42 // anchored below center on screen

// Outer flame: classic asymmetric flame shape with one curl on the left
// and a sharp tip pulling right. Hand-tuned control points; the math is
// path-relative for readability.
let fb = flameBottom
let fx = center.x
let fh = flameHeight
let fw = flameWidth

let flamePath = CGMutablePath()
flamePath.move(to: CGPoint(x: fx, y: fb))

// Right side, base → mid-right bulge
flamePath.addCurve(
    to: CGPoint(x: fx + fw * 0.55, y: fb + fh * 0.48),
    control1: CGPoint(x: fx + fw * 0.45, y: fb + fh * 0.05),
    control2: CGPoint(x: fx + fw * 0.55, y: fb + fh * 0.30)
)

// Mid-right → upper-right pinch (slight narrowing)
flamePath.addCurve(
    to: CGPoint(x: fx + fw * 0.22, y: fb + fh * 0.78),
    control1: CGPoint(x: fx + fw * 0.55, y: fb + fh * 0.65),
    control2: CGPoint(x: fx + fw * 0.40, y: fb + fh * 0.70)
)

// Upper-right → sharp tip (the highest point of the flame)
flamePath.addCurve(
    to: CGPoint(x: fx + fw * 0.10, y: fb + fh * 1.02),
    control1: CGPoint(x: fx + fw * 0.15, y: fb + fh * 0.88),
    control2: CGPoint(x: fx + fw * 0.20, y: fb + fh * 0.98)
)

// Tip → drop back down to the curl region
flamePath.addCurve(
    to: CGPoint(x: fx - fw * 0.18, y: fb + fh * 0.72),
    control1: CGPoint(x: fx - fw * 0.05, y: fb + fh * 0.95),
    control2: CGPoint(x: fx - fw * 0.10, y: fb + fh * 0.85)
)

// The curl: dipping into the body of the flame on the left, then
// looping back out. Creates the classic "lick of fire" effect.
flamePath.addCurve(
    to: CGPoint(x: fx - fw * 0.42, y: fb + fh * 0.58),
    control1: CGPoint(x: fx - fw * 0.32, y: fb + fh * 0.65),
    control2: CGPoint(x: fx - fw * 0.42, y: fb + fh * 0.62)
)

// Curl → left mid bulge
flamePath.addCurve(
    to: CGPoint(x: fx - fw * 0.50, y: fb + fh * 0.30),
    control1: CGPoint(x: fx - fw * 0.42, y: fb + fh * 0.50),
    control2: CGPoint(x: fx - fw * 0.52, y: fb + fh * 0.42)
)

// Left mid bulge → back to base
flamePath.addCurve(
    to: CGPoint(x: fx, y: fb),
    control1: CGPoint(x: fx - fw * 0.48, y: fb + fh * 0.18),
    control2: CGPoint(x: fx - fw * 0.30, y: fb + fh * 0.04)
)

flamePath.closeSubpath()

// Fill outer flame with vertical orange gradient: hot orange at base,
// brighter orange toward tip (real flames are hotter at the bottom but
// in icon convention the tip is the focal point so we reverse this for
// readability)
context.saveGState()
context.addPath(flamePath)
context.clip()

let flameGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [flameOrange, flameOrangeHot, flameOrange] as CFArray,
    locations: [0.0, 0.55, 1.0]
)!

context.drawLinearGradient(
    flameGradient,
    start: CGPoint(x: fx, y: fb),
    end: CGPoint(x: fx, y: fb + fh),
    options: []
)
context.restoreGState()

// Inner highlight: a smaller, brighter flame nested inside the outer.
// Shape mirrors the outer but with proportionally smaller dimensions
// and the curl smoothed out (just a teardrop).
let innerScale: CGFloat = 0.50
let innerFh = fh * innerScale
let innerFw = fw * innerScale * 0.85
let innerFb = fb + fh * 0.05

let innerFlamePath = CGMutablePath()
innerFlamePath.move(to: CGPoint(x: fx, y: innerFb))

// Right side
innerFlamePath.addCurve(
    to: CGPoint(x: fx + innerFw * 0.5, y: innerFb + innerFh * 0.5),
    control1: CGPoint(x: fx + innerFw * 0.4, y: innerFb + innerFh * 0.05),
    control2: CGPoint(x: fx + innerFw * 0.5, y: innerFb + innerFh * 0.30)
)

// Right → tip (slightly right of center, mirrors outer)
innerFlamePath.addCurve(
    to: CGPoint(x: fx + innerFw * 0.08, y: innerFb + innerFh),
    control1: CGPoint(x: fx + innerFw * 0.5, y: innerFb + innerFh * 0.78),
    control2: CGPoint(x: fx + innerFw * 0.18, y: innerFb + innerFh * 0.94)
)

// Tip → left
innerFlamePath.addCurve(
    to: CGPoint(x: fx - innerFw * 0.5, y: innerFb + innerFh * 0.5),
    control1: CGPoint(x: fx - innerFw * 0.15, y: innerFb + innerFh * 0.92),
    control2: CGPoint(x: fx - innerFw * 0.45, y: innerFb + innerFh * 0.78)
)

// Left → base
innerFlamePath.addCurve(
    to: CGPoint(x: fx, y: innerFb),
    control1: CGPoint(x: fx - innerFw * 0.5, y: innerFb + innerFh * 0.30),
    control2: CGPoint(x: fx - innerFw * 0.4, y: innerFb + innerFh * 0.05)
)

innerFlamePath.closeSubpath()

// Fill inner with gold-to-orange gradient (gold at base, orange-hot at tip)
context.saveGState()
context.addPath(innerFlamePath)
context.clip()

let innerFlameGradient = CGGradient(
    colorsSpace: colorSpace,
    colors: [flameGold, flameOrangeHot] as CFArray,
    locations: [0.0, 1.0]
)!

context.drawLinearGradient(
    innerFlameGradient,
    start: CGPoint(x: fx, y: innerFb),
    end: CGPoint(x: fx, y: innerFb + innerFh),
    options: []
)
context.restoreGState()

// Outer flame glow (soft halo so the flame "burns" into the dark)
context.saveGState()
context.setBlendMode(.screen)
context.addPath(flamePath)
context.setStrokeColor(flameOrangeHot.copy(alpha: 0.45)!)
context.setLineWidth(canvasCG * 0.012)
context.setShadow(
    offset: .zero,
    blur: canvasCG * 0.035,
    color: flameOrange.copy(alpha: 0.55)
)
context.strokePath()
context.restoreGState()

// MARK: - Export

guard let image = context.makeImage() else {
    FileHandle.standardError.write("Failed to make image.\n".data(using: .utf8)!)
    exit(1)
}

// Output path relative to repo root.
let outputPath = "app/FocusForge/Assets.xcassets/AppIcon.appiconset/AppIcon@1024.png"
let outputURL = URL(fileURLWithPath: outputPath)

guard let destination = CGImageDestinationCreateWithURL(
    outputURL as CFURL,
    UTType.png.identifier as CFString,
    1,
    nil
) else {
    FileHandle.standardError.write("Failed to create image destination.\n".data(using: .utf8)!)
    exit(1)
}

CGImageDestinationAddImage(destination, image, nil)

guard CGImageDestinationFinalize(destination) else {
    FileHandle.standardError.write("Failed to finalize image destination.\n".data(using: .utf8)!)
    exit(1)
}

print("App icon written to \(outputPath)")
print("Size: \(canvasSize)×\(canvasSize) px")
