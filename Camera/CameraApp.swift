import AVFoundation
import SwiftUI

@main struct CameraApp: App {
    @AppStorage("circle") private var circle = false
    @AppStorage("camera") private var camera = ""
    @AppStorage("mirrored") private var mirrored = true
    @State private var cameras = Cameras()

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

                Divider()

                Picker("Camera", selection: selectedCamera) {
                    ForEach(cameras.devices, id: \.uniqueID) { device in
                        Text(device.localizedName).tag(device.uniqueID)
                    }
                }
                .pickerStyle(.inline)

                Toggle("Mirror", isOn: $mirrored)

                Divider()
            }
        }
    }

    /// Checks the default camera until one is picked.
    private var selectedCamera: Binding<String> {
        Binding(
            get: { camera.isEmpty ? AVCaptureDevice.default(for: .video)?.uniqueID ?? "" : camera },
            set: { camera = $0 }
        )
    }
}
