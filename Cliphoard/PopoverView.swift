import SwiftUI

struct PopoverView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ClipboardEntry.dateAdded, ascending: true)])
    var entries: FetchedResults<ClipboardEntry>

    @State private var newTitle = ""
    @State private var newHiddenText = ""
    @State private var selectedEntry: ClipboardEntry?

    var body: some View {
        VStack(alignment: .leading) {
            Text("")
                .padding(.top, 5)

            ScrollView {
                VStack {
                    ForEach(Array(entries.enumerated()), id: \.element) { index, entry in
                        HStack {
                            Text("⌘\(index): \(entry.wrappedTitle)")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(selectedEntry == entry ? Color.blue.opacity(0.7) : Color.clear)
                                .cornerRadius(5)
                                .onTapGesture {
                                    selectedEntry = entry
                                }
                            
                            Spacer()
                            Button(action: {
                                copyToClipboard(entry.wrappedHiddenText)
                            }) {
                                Image(systemName: "arrow.right.page.on.clipboard")
                            }
                            .buttonStyle(BorderedButtonStyle())
                            .keyboardShortcut(KeyEquivalent(Character("\(index)")), modifiers: .command)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(height: min(CGFloat(entries.count) * 30, 200))

            Divider()

            VStack {
                TextField("Title (shows Hidden Text if empty)", text: $newTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Hidden Text", text: $newHiddenText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack {
                    Button("Save") { saveEntry() }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(newHiddenText.isEmpty)

                    Button("Remove") { removeEntry() }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(selectedEntry == nil)

                    Button("Clear All") { removeAllEntries() }
                        .buttonStyle(BorderedButtonStyle())

                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(BorderedButtonStyle())
                }
            }
            .padding(20)
        }
    }


    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func saveEntry() {
        let newEntry = ClipboardEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.title = newTitle.isEmpty ? newHiddenText : newTitle
        newEntry.hiddenText = newHiddenText
        newEntry.dateAdded = Date()

        try? viewContext.save()
        newTitle = ""
        newHiddenText = ""
    }

    private func removeEntry() {
        if let entryToRemove = selectedEntry {
            viewContext.delete(entryToRemove)
            try? viewContext.save()
            selectedEntry = nil
        }
    }

    private func removeAllEntries() {
        for entry in entries {
            viewContext.delete(entry)
        }
        try? viewContext.save()
    }
}

#Preview {
    PopoverView()
}
