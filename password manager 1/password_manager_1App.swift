//
//  password_manager_1App.swift
//  password manager 1
//
//  Created by Thiru on 01/05/24.
//

import SwiftUI
import Foundation // or the module where PasswordManagerViewModel is defined

@main
struct password_manager_1App: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
