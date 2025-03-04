//
//  CliphoardApp.swift
//  Cliphoard
//
//  Created by Jason Qiu on 3/4/25.
//

import SwiftUI
import CoreData

@main
struct CliphoardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
            // Empty Scene: No main window (menu bar app only)
            Settings {}  // Required to conform to `App` protocol
        }
}
