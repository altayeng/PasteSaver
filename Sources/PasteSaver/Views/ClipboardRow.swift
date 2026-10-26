import SwiftUI

struct ClipboardRow: View {
    let item: ClipboardItem
    let thumbnail: NSImage?
    let onSelect: () -> Void
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    private static let dateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            kindIcon
            VStack(alignment: .leading, spacing: 5) {
                preview
                metadata
            }
            Spacer(minLength: 0)
            trailingControls
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(isHovering ? 0.11 : 0.05))
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .onTapGesture(perform: onSelect)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.12), value: isHovering)
    }

    private var kindIcon: some View {
        Image(systemName: iconName)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(item.isLink ? Color.accentColor : Color.secondary)
            .frame(width: 26, height: 26)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(Color.primary.opacity(0.06))
            )
    }

    private var iconName: String {
        switch item.kind {
        case .image: return "photo"
        case .text: return item.isLink ? "link" : "text.alignleft"
        }
    }

    @ViewBuilder
    private var preview: some View {
        switch item.kind {
        case .text:
            Text((item.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(size: 12.5))
                .foregroundStyle(item.isLink ? Color.accentColor : Color.primary)
                .lineLimit(3)
                .truncationMode(.tail)
                .multilineTextAlignment(.leading)
        case .image:
            if let thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240, maxHeight: 90, alignment: .leading)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                Text("Image unavailable")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var metadata: some View {
        let relativeDate = Self.dateFormatter.localizedString(for: item.copiedAt, relativeTo: Date())
        let parts = [item.sourceApp, relativeDate].compactMap { $0 }
        return Text(parts.joined(separator: " · "))
            .font(.system(size: 10.5))
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }

    @ViewBuilder
    private var trailingControls: some View {
        if isHovering {
            HStack(spacing: 4) {
                RowIconButton(
                    systemName: item.isPinned ? "pin.slash.fill" : "pin.fill",
                    help: item.isPinned ? "Unpin" : "Pin",
                    action: onTogglePin
                )
                RowIconButton(systemName: "trash.fill", help: "Delete", action: onDelete)
            }
        } else if item.isPinned {
            Image(systemName: "pin.fill")
                .font(.system(size: 10))
                .foregroundStyle(Color.accentColor)
                .padding(.top, 4)
        }
    }
}

private struct RowIconButton: View {
    let systemName: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.primary.opacity(0.08)))
        }
        .buttonStyle(.plain)
        .help(help)
    }
}
