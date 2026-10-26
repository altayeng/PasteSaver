import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable {
    enum Kind: String, Codable {
        case text
        case image
    }

    let id: UUID
    let kind: Kind
    let text: String?
    let imageFileName: String?
    let contentHash: String
    let sourceApp: String?
    var copiedAt: Date
    var isPinned: Bool

    init(
        id: UUID = UUID(),
        kind: Kind,
        text: String? = nil,
        imageFileName: String? = nil,
        contentHash: String,
        sourceApp: String?,
        copiedAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.text = text
        self.imageFileName = imageFileName
        self.contentHash = contentHash
        self.sourceApp = sourceApp
        self.copiedAt = copiedAt
        self.isPinned = isPinned
    }

    var isLink: Bool {
        guard kind == .text, let text else { return false }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.contains(where: \.isWhitespace), let url = URL(string: trimmed) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }

    var searchableText: String {
        switch kind {
        case .text: return [text, sourceApp].compactMap { $0 }.joined(separator: " ")
        case .image: return ["image", sourceApp].compactMap { $0 }.joined(separator: " ")
        }
    }
}
