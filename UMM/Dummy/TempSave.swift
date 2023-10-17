//
//  TempSave.swift
//  UMM
//
//  Created by 김태현 on 10/17/23.
//

import CoreData
import SwiftUI

class TempSave {
    static let shared = TempSave()
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    // dummyData를 위한 프로퍼티
    let dummyName = ["DummyTravel0", "DummyTravel1", "DummyTravel2", "DummyTravel3"]
    let dummyDate = [
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: +1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: +2, to: Date())!,
        Calendar.current.date(byAdding: .day, value: +3, to: Date())!
        
    ]
    let dummyLastUpdate = [
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        
    ]
    
    init() {
        if let isFirst = UserDefaults.standard.object(forKey: "TempSave.isFirst") as? Bool {
            if isFirst {
                addDefaultTravel()
                addDummyTravel(seed: 0)
                addDummyTravel(seed: 1)
                addDummyTravel(seed: 2)
                addDummyTravel(seed: 3)
                save()
                print("Temp Save Init Done!")
            }
        } else {
            addDefaultTravel()
            addDummyTravel(seed: 0)
            addDummyTravel(seed: 1)
            addDummyTravel(seed: 2)
            addDummyTravel(seed: 3)
            save()
            print("Temp Save Init Done!")
        }
        UserDefaults.standard.set(false, forKey: "TempSave.isFirst")
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch let error {
            print("Error while saveDummyTravel: \(error.localizedDescription)")
        }
    }
    
    // dummy Travel을 추가하는 함수
    func addDummyTravel(seed: Int) {
        let tempTravel = Travel(context: viewContext)
        tempTravel.id = UUID()
        tempTravel.name = dummyName[seed]
        tempTravel.startDate = dummyDate[seed]
        tempTravel.endDate = dummyDate[seed]
        tempTravel.lastUpdate = dummyLastUpdate[seed]
    }
    
    // dummy Travel을 추가하는 함수
    func addDefaultTravel() {
        let tempTravel = Travel(context: viewContext)
        tempTravel.id = UUID()
        tempTravel.name = "Default"
        tempTravel.startDate = Date()
        tempTravel.endDate = Date()
        tempTravel.lastUpdate = Date()
    }
}
