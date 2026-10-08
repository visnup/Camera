import SwiftUI

@main struct CameraApp: App {
    var body: some Scene {
        Window("Camera", id: "camera") {
            OverlayView()
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .defaultWindowPlacement { _, context in
            let visible = context.defaultDisplay.visibleRect
            return WindowPlacement(
                CGPoint(x: visible.maxX - 340, y: visible.maxY - 200),
                size: CGSize(width: 320, height: 180)
            )
        }
    }
}
