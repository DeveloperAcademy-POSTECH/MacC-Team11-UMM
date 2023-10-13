//
//  RecordViewModel.swift
//  UMM
//
//  Created by 김태현 on 10/12/23.
//

import Foundation
import CoreData

class DummyRecordViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    @Published var savedTravels: [Travel] = []

    // dummyData를 위한 프로퍼티
    let dummyName = ["관광관광", "TravelTravel", "탐사탐사", "여행가자", "여기어때", "야놀자"]
    let dummyStartDate = ["2023-01-09", "2023-02-25", "2023-04-08"]
//    let dummyEndDate = ["2023-10-06", "2023-10-29", "2023-08-18"]
    
    func fetchDummyTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            savedTravels = try viewContext.fetch(request)
        } catch let error {
            print("Error during fetchDummyTravel: \(error.localizedDescription)")
        }
    }
    
    // dummy Travel을 추가하는 함수
    func addDummyTravel() {
        let tempTravel = Travel(context: viewContext)
        tempTravel.id = UUID()
        tempTravel.name = dummyName.randomElement()
        tempTravel.startDate = dummyStartDate.randomElement()
        tempTravel.endDate = Date()
        print("tempTravel.id: \(String(describing: tempTravel.id))")
        print("tempTravel.name: \(tempTravel.name ?? "no name")")
        print("tempTravel.startDate: \(tempTravel.startDate ?? "no startDate")")
        print("tempTravel.endDate: \(tempTravel.endDate ?? Date())")
        saveDummyTravel()
    }
    
    func saveDummyTravel() {
        do {
            try viewContext.save()
            fetchDummyTravel()
        } catch let error {
            print("Error while saveDummyTravel: \(error.localizedDescription)")
        }
    }
}
