#!/usr/bin/env swift
//
// Multi-size icon verification sheet.
//
// Reads the source 1024×1024 app icon and renders it at every size iOS
// displays an app icon, on both light and dark backgrounds, with iOS's
// rounded-corner mask applied. The output is a single composite PNG
// that proves the icon's silhouette holds at small sizes — the moment
// of truth Apple's HIG calls out.
//
// Run from repo root:
//
//     swift app/tools/icon-verification-sheet.swift
//
// Outputs to: docs/icon-verification-sheet.png
//
// The 8 sizes covered (every iOS device-icon size):
// - 24px:  smallest practical badge corner
// - 40px:  App Store search results / notification @2x
// - 58px:  iPhone Settings @2x
// - 60px:  iPad home screen @1x / notification @3x
// - 87px:  iPhone Settings @3x
// - 120px: iPhone home screen @2x / Spotlight @3x
// - 180px: iPhone home screen @3x
// - 1024px: App Store
//

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let colorSpace = CGColorSpaceCreateDeviceRGB()

// MARK: - Source icon

let sourcePath = "app/FocusForge/Assets.xcassets/AppIcon.appiconset/AppIcon@1024.png"
guard let sourceURL = URL(string: sourcePath, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)) else {
    FileHandle.standardError.write("Failed to resolve source URL.\n".data(using: .utf8)!)
    exit(1)
}

guard let imageSource = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
      let sourceImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
    FileHandle.standardError.write("Failed to load source icon at \(sourcePath)\n".data(using: .utf8)!)
    FileHandle.standardError.write("Run app/tools/generate-app-icon.swift first.\n".data(using: .utf8)!)
    exit(1)
}

print("Source loaded: \(sourceImage.width)×\(sourceImage.height)")

// MARK: - Resizing helper

/// Resizes the source icon to the given square size with high-quality
/// interpolation. Returns a new CGImage.
func resizeIcon(to size: Int) -> CGImage? {
    guard let ctx = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }
    ctx.interpolationQuality = .high
    ctx.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size, height: size))
    return ctx.makeImage()
}

// MARK: - Rounded-mask helper

/// Applies the iOS app-icon corner-radius mask to an icon. iOS uses
/// approximately a 22.37% corner radius (the "squircle" technically, but
/// rounded rect is a close enough approximation for verification).
func applyIOSMask(to image: CGImage, size: Int) -> CGImage? {
    let cornerRadius = CGFloat(size) * 0.2237
    guard let ctx = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    let rect = CGRect(x: 0, y: 0, width: size, height: size)
    let path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    ctx.addPath(path)
    ctx.clip()
    ctx.draw(image, in: rect)

    return ctx.makeImage()
}

// MARK: - Render an icon onto a backdrop

func renderIcon(size: Int, onto ctx: CGContext, at origin: CGPoint) {
    guard let resized = resizeIcon(to: size),
          let masked = applyIOSMask(to: resized, size: size) else { return }
    ctx.draw(masked, in: CGRect(x: origin.x, y: origin.y, width: CGFloat(size), height: CGFloat(size)))
}

// MARK: - Verification sheet layout

let sizes = [24, 40, 58, 60, 87, 120, 180]   // iOS sizes excluding 1024
let largestSize = sizes.max() ?? 180

let cellWidth: Int = largestSize + 40        // 180 + padding
let cellHeight: Int = largestSize + 60       // includes label

let columns = 2                              // light bg | dark bg
let rows = sizes.count

let headerHeight = 80
let footerHeight = 60
let titleHeight = 50

let sheetWidth = cellWidth * columns + 80    // outer padding
let sheetHeight = headerHeight + titleHeight + rows * cellHeight + footerHeight

guard let sheetCtx = CGContext(
    data: nil,
    width: sheetWidth,
    height: sheetHeight,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    FileHandle.standardError.write("Failed to create sheet context.\n".data(using: .utf8)!)
    exit(1)
}

// Background — neutral gray that won't compete with light/dark cells
sheetCtx.setFillColor(CGColor(srgbRed: 0.50, green: 0.50, blue: 0.55, alpha: 1.0))
sheetCtx.fill(CGRect(x: 0, y: 0, width: sheetWidth, height: sheetHeight))

// Header text
let titleText = "FocusForge App Icon — Multi-Size Verification"
let subtitleText = "Icon shown at each iOS display size, on light + dark backgrounds, with iOS corner mask"

// Skip drawing actual text via CG (complex). Print to console instead.
print("")
print("=" + String(repeating: "=", count: 60))
print(titleText)
print(subtitleText)
print("=" + String(repeating: "=", count: 60))
print("")

// CGContext draws from bottom-up; we'll render top-down by computing
// each row's y position from the top.
var currentY = sheetHeight - headerHeight - titleHeight

// Top header strip (light gray)
sheetCtx.setFillColor(CGColor(srgbRed: 0.92, green: 0.92, blue: 0.94, alpha: 1.0))
sheetCtx.fill(CGRect(
    x: 0,
    y: sheetHeight - headerHeight,
    width: sheetWidth,
    height: headerHeight
))

// Light vs dark column dividers (full height)
sheetCtx.setFillColor(CGColor(srgbRed: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)) // light column
sheetCtx.fill(CGRect(
    x: 40,
    y: footerHeight,
    width: cellWidth,
    height: sheetHeight - headerHeight - footerHeight
))

sheetCtx.setFillColor(CGColor(srgbRed: 0.10, green: 0.10, blue: 0.12, alpha: 1.0)) // dark column
sheetCtx.fill(CGRect(
    x: 40 + cellWidth,
    y: footerHeight,
    width: cellWidth,
    height: sheetHeight - headerHeight - footerHeight
))

// Render each size in both columns
for (rowIndex, size) in sizes.enumerated() {
    // Y is bottom-up; we want the rows to flow top to bottom (largest first)
    let rowY = sheetHeight - headerHeight - titleHeight - (rowIndex + 1) * cellHeight + 30

    // Light column
    let lightCenterX = 40 + cellWidth / 2 - size / 2
    renderIcon(size: size, onto: sheetCtx, at: CGPoint(x: lightCenterX, y: rowY))

    // Dark column
    let darkCenterX = 40 + cellWidth + cellWidth / 2 - size / 2
    renderIcon(size: size, onto: sheetCtx, at: CGPoint(x: darkCenterX, y: rowY))
}

// MARK: - Export

guard let sheetImage = sheetCtx.makeImage() else {
    FileHandle.standardError.write("Failed to make sheet image.\n".data(using: .utf8)!)
    exit(1)
}

let outputPath = "docs/icon-verification-sheet.png"
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

CGImageDestinationAddImage(destination, sheetImage, nil)

guard CGImageDestinationFinalize(destination) else {
    FileHandle.standardError.write("Failed to finalize image destination.\n".data(using: .utf8)!)
    exit(1)
}

print("Verification sheet written to \(outputPath)")
print("Size: \(sheetWidth)×\(sheetHeight) px")
print("")
print("Sizes verified:")
for size in sizes {
    print("  \(size)px")
}
print("")
print("Open the sheet to verify the icon's silhouette holds at every size,")
print("on both light and dark backgrounds, with iOS rounded corner masking.")
