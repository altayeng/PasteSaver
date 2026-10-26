import SwiftUI

struct ContentView: View {
    @ObservedObject var store: HistoryStore
    let onSelect: (ClipboardItem) -> Void
    let onQuit: () -> Void

    @State private var query = ""
    @State private var showsSettings = false

    private var filteredItems: [ClipboardItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return store.items }
        return store.items.filter { $0.searchableText.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            if showsSettings {
                SettingsView(store: store, onQuit: onQuit)
            } else {
                historyList
            }
            Divider()
            footer
        }
        .frame(width: 380, height: 520)
    }

    @ViewBuilder
    private var logo: some View {
        if let image = Branding.logo {
            Image(nsImage: image)
                .resizable()
                .frame(width: 22, height: 22)
        } else {
            Image(systemName: "doc.on.clipboard.fill")
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack {
                HStack(spacing: 8) {
                    logo
                    Text("PasteSaver")
                        .font(.system(size: 14, weight: .semibold))
                }
                Spacer()
                Button {
                    showsSettings.toggle()
                } label: {
                    Image(systemName: showsSettings ? "xmark.circle.fill" : "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(showsSettings ? "Close settings" : "Settings")
            }

            if !showsSettings {
                SearchField(text: $query)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var historyList: some View {
        if filteredItems.isEmpty {
            EmptyStateView(isSearching: !query.isEmpty)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    section(title: "Pinned", items: filteredItems.filter(\.isPinned))
                    section(title: "Recent", items: filteredItems.filter { !$0.isPinned })
                }
                .padding(10)
            }
        }
    }

    @ViewBuilder
    private func section(title: String, items: [ClipboardItem]) -> some View {
        if !items.isEmpty {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
                .padding(.top, 4)

            ForEach(items) { item in
                ClipboardRow(
                    item: item,
                    thumbnail: store.image(for: item),
                    onSelect: { onSelect(item) },
                    onTogglePin: { store.togglePin(item) },
                    onDelete: { store.remove(item) }
                )
            }
        }
    }

    private var footer: some View {
        HStack {
            Text("\(store.items.count) items")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            Button("Clear") {
                store.clearUnpinned()
            }
            .buttonStyle(.plain)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
            .disabled(store.items.allSatisfy(\.isPinned))
            .help("Remove all items except pinned ones")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
}
