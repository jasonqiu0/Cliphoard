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
    @State private var isEditing = false
    @State private var refreshID = UUID()

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
            .id(refreshID)

            Divider()

            VStack {
                TextField("Title (shows Hidden Text if empty)", text: $newTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Hidden Text", text: $newHiddenText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if !newHiddenText.isEmpty {
                            saveEntry() }
                    }
                
                HStack {
                    Button(isEditing ? "Save Changes" : "Save") { saveEntry() }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(newHiddenText.isEmpty)
                        .keyboardShortcut(.return)

                    Button("Remove") { removeEntry() }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(selectedEntry == nil)
                        .disabled(isEditing == true)

                    Button("Clear All") { removeAllEntries() }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(isEditing == true)

                    Button("Quit") { NSApplication.shared.terminate(nil) }
                        .buttonStyle(BorderedButtonStyle())
                        .disabled(isEditing == true)
                }
                HStack{
                    Button("Move ↑") { moveEntryUp() }
                        .disabled(selectedEntry == nil)
                        .disabled(isEditing == true)
                    
                    Button("Move ↓") { moveEntryDown() }
                        .disabled(selectedEntry == nil)
                        .disabled(isEditing == true)
                    
                    Button("Edit") { editMode() }
                        .disabled(selectedEntry == nil)
                        .disabled(isEditing == true)
                }
            }
            .padding(20)
        }
        .frame(width: 360)
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func saveEntry() {
        
        if isEditing, let selected = selectedEntry {
            selected.title = newTitle.isEmpty ? newHiddenText : newTitle
            selected.hiddenText = newHiddenText
            isEditing = false
            
        } else {
            let newEntry = ClipboardEntry(context: viewContext)
            newEntry.id = UUID()
            newEntry.title = newTitle.isEmpty ? newHiddenText : newTitle
            newEntry.hiddenText = newHiddenText
            newEntry.dateAdded = Date()
        }
        

        try? viewContext.save()
        newTitle = ""
        newHiddenText = ""
        refreshID = UUID()
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
    
    private func moveEntryUp() {
        guard let selected = selectedEntry,
              let currentIndex = entries.firstIndex(of: selected),
              currentIndex > 0 else { return }
        
        let previousEntry = entries[currentIndex-1]
        let tempDate = selected.dateAdded
        selected.dateAdded = previousEntry.dateAdded
        previousEntry.dateAdded = tempDate
        
        try? viewContext.save()

    }
    
    private func moveEntryDown() {
        guard let selected = selectedEntry,
              let currentIndex = entries.firstIndex(of: selected),
              currentIndex < entries.count-1 else { return }
        
        let nextEntry = entries[currentIndex+1]
        let tempDate = selected.dateAdded
        selected.dateAdded = nextEntry.dateAdded
        nextEntry.dateAdded = tempDate
        
        try? viewContext.save()
        
    }
    
    private func editMode() {
        guard let selected = selectedEntry else { return }
        newTitle = selected.wrappedTitle
        newHiddenText = selected.wrappedHiddenText
        isEditing = true
                
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
                Image(systemName: "document.on.clipboard.fill")
                    .frame(width: 20, height: 20)
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
