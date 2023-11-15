//
//  AddMemberViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/18.
//

import Foundation
import CoreData

class AddMemberViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var savedParticipant: [Travel] = []
    @Published var participantArr: [String]? = []
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var travelName: String?
    @Published var travelID = UUID()
    
    func addTravel() {
        let travel = Travel(context: viewContext)
        travel.participantArray = participantArr
        travel.startDate = startDate
        travel.endDate = endDate
        travel.name = travelName
        travel.id = travelID
        saveTravel()
    }
    
    func saveTravel() {
        do {
            try viewContext.save()
            print("save travel")
        } catch let error {
            print("Error while SaveTravel: \(error.localizedDescription)")
        }
    }
    
    func updateSelectedTravels() {
        var newTravel: Travel?
        do {
            newTravel = try viewContext.fetch(Travel.fetchRequest()).filter { travel in
                if let id = travel.id {
                    return id == travelID
                } else {
                    return false
                }
            }.first
        } catch {
            print("error fetching travel: \(error.localizedDescription)")
        }
        
        MainViewModel.shared.selectedTravel = newTravel
    }
}
