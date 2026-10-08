# Camera

A macOS app that shows the camera feed as a small floating overlay on the screen. That's the whole
scope.

## Code

- Latest Swift (language mode 6) with strict concurrency. Default actor isolation is `MainActor`.
- SwiftUI first, using the newest APIs the deployment target allows: scene modifiers such as
  `.windowStyle(.plain)`, `.windowLevel`, `.defaultWindowPlacement`, `WindowDragGesture`.
  Drop to AppKit only for what SwiftUI can't do yet, and say why where it happens.
- Commands go in menus, per the HIG, not behind hidden gestures like double-click.
- Prefer async/await and structured concurrency over GCD and completion handlers.
- macOS only (`SUPPORTED_PLATFORMS = macosx`), deployment target macOS 27.

## Layout

- `Camera/CameraApp.swift`: the single overlay `Window` scene.
- `Camera/OverlayView.swift`: the overlay and the camera view with its capture session.
- `Camera/WindowBehavior.swift`: AppKit fixes for the borderless window, as a background view.
- `Camera/Icon.icon`: the Icon Composer app icon, set by `ASSETCATALOG_COMPILER_APPICON_NAME`.
  It's compiled by the Resources build phase, so keep that phase even when it looks empty.
- Sources are a file-system-synchronized group, so new files in `Camera/` join the target without
  editing `project.pbxproj`.
- The `.plain` window is borderless, and `WindowBehavior` works around what that costs:
  - It isn't resizable (style mask `0`), so the view inserts `.resizable`.
  - It can't become key, so `.pointerStyle` and cursor rects never show. An `.activeAlways`
    tracking area sets the `NSCursor.frameResize` cursors instead.
  - Clicks on fully transparent pixels fall through to the window behind. The margin around
    the video, corners included, has a 1% black fill so it catches them. Transparent corners
    break corner resizing.
  - AppKit's resize zone is only a few points wide and there's no public API to hand it a
    drag (`performDrag`/`WindowDragGesture` only move), so the 4pt `margin` is sized to
    roughly match it. Resizing the window by hand from mouse events was janky; don't.
- SwiftUI never restores the window with macOS's default "Close windows when quitting an
  application" setting, and resizes it on launch itself (to 900×450 without `.defaultSize`).
  `WindowBehavior` sets a frame autosave name one task after it gets its window, so the saved
  frame lands after SwiftUI's sizing. `defaultWindowPlacement` only applies before there's
  a saved frame.
- Camera access: `ENABLE_RESOURCE_ACCESS_CAMERA` (sandbox entitlement) and
  `INFOPLIST_KEY_NSCameraUsageDescription` in build settings.

## Before committing

Review the whole change, not just the last edit, for accretion: approaches tried and then
abandoned but still in the code, two mechanisms for one job, code that ended up in the wrong
place because it was convenient, and comments or this file describing an earlier approach.
Remove or fix them before the commit.

## Verify

```sh
xcodebuild -project Camera.xcodeproj -scheme Camera -destination 'platform=macOS' -derivedDataPath DerivedData/Camera build
open DerivedData/Camera/Build/Products/Debug/Camera.app
```

`DerivedData/Camera` is where Xcode itself builds (project-relative DerivedData), so both share
one build.
