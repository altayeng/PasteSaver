import AppKit

final class ClipboardMonitor {
    typealias CaptureHandler = (CapturedContent, String?) -> Void

    private let service: PasteboardService
    private let onCapture: CaptureHandler
    private var timer: Timer?

    init(service: PasteboardService, onCapture: @escaping CaptureHandler) {
        self.service = service
        self.onCapture = onCapture
    }

    func start() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
        timer.tolerance = 0.2
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        guard let content = service.readIfChanged() else { return }
        onCapture(content, NSWorkspace.shared.frontmostApplication?.localizedName)
    }
}
