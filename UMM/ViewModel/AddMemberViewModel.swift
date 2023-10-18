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
    @Published var participantArr: [String]?
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            savedParticipant = try viewContext.fetch(request)
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
        }
    }
    
    func addTravel() {
        let travel = Travel(context: viewContext)
        travel.participantArray = participantArr
        travel.startDate = startDate
        travel.endDate = endDate
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
}
