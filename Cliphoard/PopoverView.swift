//
//  PopoverView.swift
//  Cliphoard
//
//  Created by Jason Qiu on 3/4/25.
//

import SwiftUI

struct PopoverView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ClipboardEntry.title, ascending: true)])
    var entries: FetchedResults<ClipboardEntry>

    @State private var newTitle = ""
    @State private var newHiddenText = ""
    @State private var selectedEntry: ClipboardEntry?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("")
                .padding(.top, 5)
            
            ForEach(entries, id: \.self) {entry in
                HStack {
                    Text(entry.wrappedTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selectedEntry == entry ? Color.blue.opacity(0.7) : Color.clear)
                        .cornerRadius(5)
                        .onTapGesture {
                            selectedEntry = entry
                        }
                    
                    Spacer()
                    
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
    
    private func saveEntry() {
        let newEntry = ClipboardEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.title = newTitle
        newEntry.hiddenText = newHiddenText

        try? viewContext.save()
        newTitle = ""
        newHiddenText = ""
    }
    private func removeEntry () {
        if let entryToRemvoe = selectedEntry {
            viewContext.delete(entryToRemvoe)
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
