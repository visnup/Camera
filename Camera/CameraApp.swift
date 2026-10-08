import SwiftUI

@main struct CameraApp: App {
    var body: some Scene {
        Window("Camera", id: "camera") {
            OverlayView()
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .defaultSize(width: 320, height: 180)
        .defaultWindowPlacement { _, _ in WindowPlacement(.bottomTrailing) }
    }
}
