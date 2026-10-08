import AVFoundation
import SwiftUI

struct OverlayView: View {
    @AppStorage("circle") private var circle = false
    @State private var hovering = false

    var body: some View {
        let shape = circle ? AnyShape(.circle) : AnyShape(.rect(cornerRadius: 16))
        CameraView()
            .allowsHitTesting(false)
            .clipShape(shape)
            .contentShape(shape)
            .onTapGesture(count: 2) { circle.toggle() }
            .gesture(WindowDragGesture())
            .allowsWindowActivationEvents(true)
            .padding(ResizableView.margin)
            .background(.black.opacity(hovering ? 0.3 : 0), in: .rect(cornerRadius: 16 + ResizableView.margin))
            .background(.black.opacity(0.01)) // fully transparent pixels click through the window
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

        let view = ResizableView()
        view.layer = layer
        view.wantsLayer = true
        Task.detached { session.startRunning() }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// `.windowStyle(.plain)` makes a borderless window that SwiftUI gives no way to resize.
/// It also can't become key, so cursor rects and `.pointerStyle` never apply; an
/// always-active tracking area over the window's margin sets the resize cursors instead.
final class ResizableView: NSView {
    static let margin: CGFloat = 4

    override func viewDidMoveToWindow() {
        window?.styleMask.insert(.resizable)
        window?.contentView?.addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self
        ))
    }

    override func mouseMoved(with event: NSEvent) {
        if let position = edge(at: event.locationInWindow) {
            NSCursor.frameResize(position: position, directions: .all).set()
        } else {
            NSCursor.arrow.set()
        }
    }

    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }

    private func edge(at point: NSPoint) -> NSCursor.FrameResizePosition? {
        guard let size = window?.frame.size else { return nil }
        let inset = Self.margin
        let top = point.y > size.height - inset
        let bottom = point.y < inset
        let left = point.x < inset
        let right = point.x > size.width - inset
        return switch (top, bottom, left, right) {
        case (true, _, true, _): .topLeft
        case (true, _, _, true): .topRight
        case (_, true, true, _): .bottomLeft
        case (_, true, _, true): .bottomRight
        case (true, _, _, _): .top
        case (_, true, _, _): .bottom
        case (_, _, true, _): .left
        case (_, _, _, true): .right
        default: nil
        }
    }
}
