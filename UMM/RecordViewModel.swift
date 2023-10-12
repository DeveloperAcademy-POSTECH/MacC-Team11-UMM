//
//  RecordViewModel.swift
//  UMM
//
//  Created by 김태현 on 10/12/23.
//

import Foundation
import CoreData

class RecordViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    func saveDD() {
        do {
            try viewContext.save()
        } catch {
            print("error saving: \(error.localizedDescription)")
        }
        print("saved!")
    }
}
