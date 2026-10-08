import SwiftUI

@main struct CameraApp: App {
    @AppStorage("circle") private var circle = false

    var body: some Scene {
        Window("Camera", id: "camera") {
            OverlayView()
        }
        .windowStyle(.plain)
        .windowLevel(.floating)
        .defaultSize(width: 320, height: 180)
        .defaultWindowPlacement { _, _ in WindowPlacement(.bottomTrailing) }
        .commands {
            CommandGroup(before: .toolbar) {
                Picker("Shape", selection: $circle) {
                    Text("Rectangle").tag(false)
                    Text("Circle").tag(true)
                }
                .pickerStyle(.inline)
            }
        }
    }
}
