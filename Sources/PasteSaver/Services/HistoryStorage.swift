import Foundation

struct HistoryStorage {
    private let directory: URL

    private var historyURL: URL {
        directory.appendingPathComponent("history.json")
    }

    private var imagesDirectory: URL {
        directory.appendingPathComponent("Images", isDirectory: true)
    }

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        directory = base.appendingPathComponent("PasteSaver", isDirectory: true)
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }

    func load() -> [ClipboardItem] {
        guard let data = try? Data(contentsOf: historyURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([ClipboardItem].self, from: data)) ?? []
    }

    func save(_ items: [ClipboardItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: historyURL, options: .atomic)
    }

    func saveImage(_ data: Data, fileName: String) -> Bool {
        do {
            try data.write(to: imagesDirectory.appendingPathComponent(fileName), options: .atomic)
            return true
        } catch {
            return false
        }
    }

    func loadImage(fileName: String) -> Data? {
        try? Data(contentsOf: imagesDirectory.appendingPathComponent(fileName))
    }

    func deleteImage(fileName: String) {
        try? FileManager.default.removeItem(at: imagesDirectory.appendingPathComponent(fileName))
    }
}
