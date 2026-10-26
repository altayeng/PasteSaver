import AppKit

enum Branding {
    static let logo: NSImage? = {
        guard let url = Bundle.main.url(forResource: "MenuBarIcon", withExtension: "png") else { return nil }
        return NSImage(contentsOf: url)
    }()

    static func statusBarImage(side: CGFloat = 18) -> NSImage? {
        guard let logo else { return nil }
        let image = NSImage(size: NSSize(width: side, height: side), flipped: false) { rect in
            logo.draw(in: rect)
            return true
        }
        image.isTemplate = false
        return image
    }
}
