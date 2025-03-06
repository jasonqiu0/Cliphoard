//
//  PopoverView.swift
//  Cliphoard
//
//  Created by Jason Qiu on 3/4/25.
//

import SwiftUI

struct PopoverView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ClipboardEntry.dateAdded, ascending: true)])
    var entries: FetchedResults<ClipboardEntry>

    @State private var newTitle = ""
    @State private var newHiddenText = ""
    @State private var selectedEntry: ClipboardEntry?

    private var enumeratedEntries: [(Int, ClipboardEntry)] {
        return Array(entries.enumerated())
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("")
                .padding(.top, 5)

            ScrollView {
                VStack {
                    ForEach(enumeratedEntries, id: \.1) { index, entry in
                        let keyEquivalent: KeyEquivalent? = index < 10 ? KeyEquivalent("\(index)".first!) : nil

                        EntryRow(entry: entry, index: index, selectedEntry: $selectedEntry)
                            .overlay(ShortcutButton(entry: entry, key: keyEquivalent))
                    }
                }
            }

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


struct EntryRow: View {
    var entry: ClipboardEntry
    var index: Int
    @Binding var selectedEntry: ClipboardEntry?

    var body: some View {
        HStack {

            Text(entry.wrappedTitle)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(selectedEntry == entry ? Color.blue.opacity(0.7) : Color.clear)
                .cornerRadius(5)
                .onTapGesture {
                    selectedEntry = entry
                }

            if index < 10 {
                Text("⌘\(index)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.5))
            }

            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(entry.wrappedHiddenText, forType: .string)
            }) {
                Image(systemName: "arrow.right.page.on.clipboard")
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding(.horizontal)
    }
}

struct ShortcutButton: View {
    var entry: ClipboardEntry
    var key: KeyEquivalent?

    var body: some View {
        Group {
            if let key = key {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(entry.wrappedHiddenText, forType: .string)
                }) {
                    Text("")
                }
                .keyboardShortcut(key, modifiers: .command)
                .hidden()
            }
        }
    }
}

#Preview {
    PopoverView()
}

