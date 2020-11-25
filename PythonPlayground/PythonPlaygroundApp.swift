//
//  PythonPlaygroundApp.swift
//  PythonPlayground
//
//  Created by 안창범 on 2020/11/25.
//

import SwiftUI

@main
struct PythonPlaygroundApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
