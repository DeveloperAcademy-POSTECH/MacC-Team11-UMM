//
//  UMMApp.swift
//  UMM
//
//  Created by Wonil Lee on 10/5/23.
//

import SwiftUI

@main
struct UMMApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
