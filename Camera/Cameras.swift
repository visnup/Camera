import AVFoundation

/// The video devices to choose from, kept current as cameras connect and disconnect.
@Observable final class Cameras {
    private(set) var devices: [AVCaptureDevice] = []

    @ObservationIgnored private let discovery = AVCaptureDevice.DiscoverySession(
        deviceTypes: [.builtInWideAngleCamera, .external, .continuityCamera, .deskViewCamera],
        mediaType: .video,
        position: .unspecified
    )
    @ObservationIgnored private var observation: NSKeyValueObservation?

    init() {
        devices = discovery.devices
        observation = discovery.observe(\.devices) { [weak self] _, _ in
            Task { @MainActor in
                guard let self else { return }
                self.devices = self.discovery.devices
            }
        }
    }
}
