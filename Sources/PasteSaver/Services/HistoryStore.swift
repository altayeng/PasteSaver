import AppKit
import CryptoKit

final class HistoryStore: ObservableObject {
    static let historyLimitOptions = [25, 50, 100, 200, 500]

    private enum Defaults {
        static let historyLimitKey = "historyLimit"
        static let historyLimit = 100
    }

    @Published private(set) var items: [ClipboardItem]
    @Published var historyLimit: Int {
        didSet {
            UserDefaults.standard.set(historyLimit, forKey: Defaults.historyLimitKey)
            trim()
            persist()
        }
    }

    private let pasteboard: PasteboardService
    private let storage: HistoryStorage
    private let imageCache = NSCache<NSUUID, NSImage>()

    init(pasteboard: PasteboardService, storage: HistoryStorage = HistoryStorage()) {
        self.pasteboard = pasteboard
        self.storage = storage
        self.items = storage.load()

        let storedLimit = UserDefaults.standard.integer(forKey: Defaults.historyLimitKey)
        self.historyLimit = storedLimit > 0 ? storedLimit : Defaults.historyLimit
    }

    func capture(_ content: CapturedContent, sourceApp: String?) {
        switch content {
        case .text(let text):
            captureText(text, sourceApp: sourceApp)
        case .image(let data):
            captureImage(data, sourceApp: sourceApp)
        }
        trim()
        persist()
    }

    func copyToPasteboard(_ item: ClipboardItem) {
        switch item.kind {
        case .text:
            guard let text = item.text else { return }
            pasteboard.write(.text(text))
        case .image:
            guard let fileName = item.imageFileName,
                  let data = storage.loadImage(fileName: fileName) else { return }
            pasteboard.write(.image(data))
        }
        moveToTop(contentHash: item.contentHash)
        persist()
    }

    func togglePin(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isPinned.toggle()
        trim()
        persist()
    }

    func remove(_ item: ClipboardItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        discardAssets(of: items.remove(at: index))
        persist()
    }

    func clearUnpinned() {
        items.filter { !$0.isPinned }.forEach(discardAssets)
        items.removeAll { !$0.isPinned }
        persist()
    }

    func image(for item: ClipboardItem) -> NSImage? {
        guard let fileName = item.imageFileName else { return nil }
        let key = item.id as NSUUID
        if let cached = imageCache.object(forKey: key) { return cached }
        guard let data = storage.loadImage(fileName: fileName), let image = NSImage(data: data) else { return nil }
        imageCache.setObject(image, forKey: key)
        return image
    }

    private func captureText(_ text: String, sourceApp: String?) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let hash = Self.hash(of: Data(text.utf8))
        guard !moveToTop(contentHash: hash) else { return }

        items.insert(
            ClipboardItem(kind: .text, text: text, contentHash: hash, sourceApp: sourceApp),
            at: 0
        )
    }

    private func captureImage(_ data: Data, sourceApp: String?) {
        let hash = Self.hash(of: data)
        guard !moveToTop(contentHash: hash) else { return }

        let id = UUID()
        let fileName = "\(id.uuidString).png"
        guard storage.saveImage(data, fileName: fileName) else { return }

        items.insert(
            ClipboardItem(id: id, kind: .image, imageFileName: fileName, contentHash: hash, sourceApp: sourceApp),
            at: 0
        )
    }

    @discardableResult
    private func moveToTop(contentHash: String) -> Bool {
        guard let index = items.firstIndex(where: { $0.contentHash == contentHash }) else { return false }
        var item = items.remove(at: index)
        item.copiedAt = Date()
        items.insert(item, at: 0)
        return true
    }

    private func trim() {
        var unpinnedCount = 0
        var kept: [ClipboardItem] = []

        for item in items {
            if item.isPinned {
                kept.append(item)
                continue
            }
            unpinnedCount += 1
            if unpinnedCount <= historyLimit {
                kept.append(item)
            } else {
                discardAssets(of: item)
            }
        }

        if kept.count != items.count {
            items = kept
        }
    }

    private func discardAssets(of item: ClipboardItem) {
        imageCache.removeObject(forKey: item.id as NSUUID)
        if let fileName = item.imageFileName {
            storage.deleteImage(fileName: fileName)
        }
    }

    private func persist() {
        storage.save(items)
    }

    private static func hash(of data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
