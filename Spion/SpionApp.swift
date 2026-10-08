import AVFoundation
import SwiftUI

@main struct SpionApp: App {
    @AppStorage("circle") private var circle = true
    @AppStorage("camera") private var camera = ""
    @AppStorage("mirrored") private var mirrored = true
    @State private var cameras = Cameras()

    var body: some Scene {
        Window("Spion", id: "spion") {
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
                .labelsHidden()

                Divider()
            }
            CommandMenu("Camera") {
                Picker("Camera", selection: selectedCamera) {
                    ForEach(cameras.devices, id: \.uniqueID) { device in
                        Text(device.localizedName).tag(device.uniqueID)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()

                Divider()

                Toggle("Mirror", isOn: $mirrored)
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
