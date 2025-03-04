//
//  ContentView.swift
//  Cliphoard
//
//  Created by Jason Qiu on 3/4/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        SwiftUI.Text("Welcome to Cliphoard")
            .padding(64)
    }
}
