//
//  UMMApp.swift
//  UMM
//
//  Created by Wonil Lee on 10/5/23.
//

import SwiftUI

@main
struct UMMApp: App {
    let tempSave = TempSave.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
//            TestView()
        }
    }
}
