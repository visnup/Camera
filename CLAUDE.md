# Camera

A macOS app that shows the camera feed as a small floating overlay on the screen. That's the whole
scope.

## Code

- Keep the code as small and tight as possible. This is a single-purpose app: it should do that
  one thing very well and nothing else. Reach for whatever macOS and SwiftUI already provide
  before writing code, and prefer deleting code to adding it.
- Latest Swift (language mode 6) with strict concurrency. Default actor isolation is `MainActor`.
- SwiftUI first, using the newest APIs the deployment target allows: scene modifiers such as
  `.windowStyle(.plain)`, `.windowLevel`, `.defaultWindowPlacement`, `WindowDragGesture`.
  Drop to AppKit only for what SwiftUI can't do yet, and say why where it happens.
- Commands go in menus, per the HIG, not behind hidden gestures like double-click.
- Prefer async/await and structured concurrency over GCD and completion handlers.
- macOS only (`SUPPORTED_PLATFORMS = macosx`), deployment target macOS 27.

## Layout

- `Camera/CameraApp.swift`: the single overlay `Window` scene.
- `Camera/OverlayView.swift`: the overlay, the camera-access check, and the camera view with
  its capture session. The camera, mirroring and shape are `@AppStorage`, set from the View menu.
- `Camera/Cameras.swift`: the camera list for the View menu, kept current as devices connect.
- `Camera/WindowBehavior.swift`: AppKit fixes for the borderless window, as a background view.
- `Camera/Icon.icon`: the Icon Composer app icon, set by `ASSETCATALOG_COMPILER_APPICON_NAME`.
  It's compiled by the Resources build phase, so keep that phase even when it looks empty.
- Sources are a file-system-synchronized group, so new files in `Camera/` join the target without
  editing `project.pbxproj`.
- The `.plain` window is borderless, and `WindowBehavior` works around what that costs:
  - It isn't resizable (style mask `0`), so the view inserts `.resizable`.
  - SwiftUI has no scene modifier for Spaces, so `collectionBehavior` gets `.canJoinAllSpaces`.
    It doesn't show over other apps' full-screen Spaces, and `.fullScreenAuxiliary` doesn't
    change that. Per Apple DTS that takes an `.accessory` activation policy (no Dock icon or
    menu bar) plus a non-activating `NSPanel`.
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

## Todo

Delete items when they're done; the history is in git.

- Animate between circle and rectangle. `AnyShape` doesn't interpolate, so this probably
  wants one shape with an animatable corner radius (a rect whose radius goes to half the
  shorter side) plus a square frame in circle mode.
- Animate mirroring, if it can look good. A preview layer's `isVideoMirrored` snaps; a
  SwiftUI flip (`scaleEffect(x: -1)` or a `rotation3DEffect`) would animate.
- Research resizing and do it in the most idiomatic macOS way. Today it's AppKit's narrow
  borderless resize zone, a 4pt margin sized to roughly match it, and hand-set cursors.
  Look at how other borderless and shaped utility windows do it, whether SwiftUI or AppKit
  now has a resize affordance for plain windows, `NSPanel`, and how a titled window with a
  hidden title bar and buttons compares.
- In circle mode, make the window square, or resize it to a square, so there's no dead
  transparent area beside the circle. Match the hover frame to the circle too.
- Show over other apps' full-screen Spaces. Per Apple DTS this needs an `.accessory`
  activation policy and a non-activating `NSPanel`. It goes with moving to a menu bar extra,
  since accessory apps have no menu bar for the View menu.
- If the saved frame is off-screen (a display was unplugged), check that it comes back on
  screen.
- Before sharing builds: a real bundle identifier (this resets camera permission), a README,
  and a signed, notarized release.
