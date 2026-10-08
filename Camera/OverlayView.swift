import AVFoundation
import SwiftUI

struct OverlayView: View {
    var body: some View {
        CameraView()
            .allowsHitTesting(false)
            .frame(width: 320, height: 180)
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

        let view = NSView()
        view.layer = layer
        view.wantsLayer = true
        Task.detached { session.startRunning() }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

#Preview {
    OverlayView()
}
