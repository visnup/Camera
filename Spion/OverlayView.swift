import AVFoundation
import SwiftUI

struct OverlayView: View {
    static let margin: CGFloat = 4
    static let cornerRadius: CGFloat = 16

    @AppStorage("circle") private var circle = false
    @AppStorage("camera") private var camera = ""
    @AppStorage("mirrored") private var mirrored = true
    @State private var authorized: Bool?
    @State private var hovering = false
    @Environment(\.openURL) private var openURL

    var body: some View {
        let shape = circle && authorized != false ? AnyShape(.circle) : AnyShape(.rect(cornerRadius: Self.cornerRadius))
        content
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
            .task { authorized = await AVCaptureDevice.requestAccess(for: .video) }
    }

    @ViewBuilder private var content: some View {
        switch authorized {
        case true?:
            CameraView(deviceID: camera, mirrored: mirrored)
                .allowsHitTesting(false)
        case false?:
            ContentUnavailableView {
                Label("No Camera Access", systemImage: "video.slash")
            } actions: {
                Button("Open Privacy Settings") {
                    openURL(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!)
                }
            }
            .background(.regularMaterial)
        case nil:
            Color.black
        }
    }
}

struct CameraView: NSViewRepresentable {
    var deviceID: String
    var mirrored: Bool

    func makeCoordinator() -> AVCaptureSession { AVCaptureSession() }

    func makeNSView(context: Context) -> NSView {
        // startRunning blocks, and AVFoundation documents calling it off the main thread
        nonisolated(unsafe) let session = context.coordinator
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill

        let view = NSView()
        view.layer = layer
        view.wantsLayer = true
        Task.detached { session.startRunning() }
        return view
    }

    func updateNSView(_ view: NSView, context: Context) {
        let session = context.coordinator
        let device = AVCaptureDevice(uniqueID: deviceID) ?? .default(for: .video)
        let current = (session.inputs.first as? AVCaptureDeviceInput)?.device
        if current?.uniqueID != device?.uniqueID {
            session.beginConfiguration()
            session.inputs.forEach(session.removeInput)
            if let device, let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) {
                session.addInput(input)
            }
            session.commitConfiguration()
        }

        if let connection = (view.layer as? AVCaptureVideoPreviewLayer)?.connection {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = mirrored
        }
    }
}
