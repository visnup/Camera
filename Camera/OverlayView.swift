import AVFoundation
import SwiftUI

struct OverlayView: View {
    static let margin: CGFloat = 4
    static let cornerRadius: CGFloat = 16

    @AppStorage("circle") private var circle = false
    @State private var hovering = false

    var body: some View {
        let shape = circle ? AnyShape(.circle) : AnyShape(.rect(cornerRadius: Self.cornerRadius))
        CameraView()
            .allowsHitTesting(false)
            .clipShape(shape)
            .contentShape(shape)
            .gesture(WindowDragGesture())
            .allowsWindowActivationEvents(true)
            .padding(Self.margin)
            .background(.black.opacity(hovering ? 0.3 : 0), in: .rect(cornerRadius: Self.cornerRadius + Self.margin))
            .background(.black.opacity(0.01)) // fully transparent pixels click through the window
            .background(WindowBehavior().allowsHitTesting(false))
            .onHover { hovering = $0 }
            .animation(.default, value: hovering)
            .frame(minWidth: 90, minHeight: 90)
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
