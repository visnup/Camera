import AVFoundation
import SwiftUI

struct OverlayView: View {
    var body: some View {
        CameraView()
            .allowsHitTesting(false)
            .frame(minWidth: 90, minHeight: 90)
            .clipShape(.rect(cornerRadius: 16))
            .contentShape(.rect)
            .gesture(WindowDragGesture())
            .allowsWindowActivationEvents(true)
    }
}

struct CameraView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.automaticallyAdjustsVideoMirroring = false
        layer.connection?.isVideoMirrored = true

        let view = ResizableView()
        view.layer = layer
        view.wantsLayer = true
        Task.detached { session.startRunning() }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// `.windowStyle(.plain)` makes a borderless window that SwiftUI gives no way to resize.
private final class ResizableView: NSView {
    override func viewDidMoveToWindow() {
        window?.styleMask.insert(.resizable)
    }
}
