//
//  todolistApp.swift
//  todolist
//
//  Created by 黃皓澤 on 2025/5/28.
//

import SwiftUI

@main
struct todolistApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
