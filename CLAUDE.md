# Camera

A macOS app that shows the camera feed as a small floating overlay on the screen. That's the whole
scope.

## Code

- Latest Swift (language mode 6) with strict concurrency. Default actor isolation is `MainActor`.
- SwiftUI first, using the newest APIs the deployment target allows: scene modifiers such as
  `.windowStyle(.plain)`, `.windowLevel`, `.defaultWindowPlacement`, `WindowDragGesture` instead of reaching into `NSWindow`. Drop to AppKit only for what
  SwiftUI can't do yet, such as the `AVCaptureVideoPreviewLayer` host.
- Prefer async/await and structured concurrency over GCD and completion handlers.
- macOS only (`SUPPORTED_PLATFORMS = macosx`), deployment target macOS 27.

## Layout

- `Camera/CameraApp.swift`: the single overlay `Window` scene.
- `Camera/OverlayView.swift`: the overlay and the camera view with its capture session.
- Sources are a file-system-synchronized group, so new files in `Camera/` join the target without
  editing `project.pbxproj`.
- The `.plain` window is borderless, which costs three things `ResizableView` puts back:
  - It isn't resizable (style mask `0`), so the view inserts `.resizable`.
  - It can't become key, so `.pointerStyle` and cursor rects never show. An `.activeAlways`
    tracking area sets the `NSCursor.frameResize` cursors instead.
  - Clicks on fully transparent pixels fall through to the window behind. The resize margin
    around the video has a 1% black fill so it catches them.
  - Don't resize the window by hand from mouse events: it was janky. Let AppKit do it.
- Camera access: `ENABLE_RESOURCE_ACCESS_CAMERA` (sandbox entitlement) and
  `INFOPLIST_KEY_NSCameraUsageDescription` in build settings.

## Verify

```sh
xcodebuild -project Camera.xcodeproj -scheme Camera -destination 'platform=macOS' -derivedDataPath DerivedData build
open DerivedData/Build/Products/Debug/Camera.app
```
