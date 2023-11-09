//
//  CompleteAddTravelViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/18.
//

import Foundation
import CoreData

class CompleteAddTravelViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var savedTravel: [Travel] = []
    @Published var travelID = UUID()
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var travelName: String?
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            savedTravel = try viewContext.fetch(request)
//            print("fetchTravel | savedTravel.count: \(savedTravel.count)")
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
        }
    }
    
    func filterTravelByID(selectedTravelID: UUID) -> [Travel] {
        return savedTravel.filter { travel in
            if let id = travel.id {
                print("filterTravelByID | travel.id: \(id)")
                print("result: \(id == selectedTravelID)")
                return id == selectedTravelID
            } else {
                print("filterTravelByID | travel.id: nil")
                return false
            }
        }
    }
    
    func saveTravel() {
        do {
            try viewContext.save()
            print("save travel")
        } catch let error {
            print("Error while SaveTravel: \(error.localizedDescription)")
        }
    }
    
    func dateToString(in date: Date?) -> String {
        if date == nil {
            return ""
        } else {
            return AddTravelViewModel.startDateFormatter.string(from: date!)
        }
    }
}
