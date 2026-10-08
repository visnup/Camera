import SwiftUI

@main struct CameraApp: App {
    var body: some Scene {
        Window("Camera", id: "camera") {
            OverlayView()
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .windowResizability(.contentSize)
        .defaultWindowPlacement { _, context in
            let visible = context.defaultDisplay.visibleRect
            return WindowPlacement(CGPoint(x: visible.maxX - 340, y: visible.maxY - 200))
        }
    }
}
