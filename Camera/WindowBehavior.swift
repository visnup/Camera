import SwiftUI

/// Fills the window and puts back what `.windowStyle(.plain)`'s borderless window lacks
/// and SwiftUI has no API for:
/// - it isn't resizable, so this inserts `.resizable`
/// - it can't become key, so cursor rects and `.pointerStyle` never apply; an always-active
///   tracking area sets the resize cursors over the margin instead
/// - SwiftUI only restores windows when macOS's "Close windows when quitting an application"
///   setting is off, so the frame is autosaved
struct WindowBehavior: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { WindowBehaviorView() }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class WindowBehaviorView: NSView {
    override init(frame: NSRect) {
        super.init(frame: frame)
        addTrackingArea(NSTrackingArea(
            rect: .zero,
            options: [.mouseMoved, .mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self
        ))
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidMoveToWindow() {
        guard let window else { return }
        window.styleMask.insert(.resizable)
        // after SwiftUI's own initial sizing, which would override the restored frame
        Task { window.setFrameAutosaveName("Camera") }
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
        let inset = OverlayView.margin
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
