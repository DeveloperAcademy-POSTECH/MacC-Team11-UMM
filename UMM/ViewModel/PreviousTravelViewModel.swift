//
//  PreviousTravelViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import Foundation
import CoreData

class PreviousTravelViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var previousTravel: [Travel] = []
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            previousTravel = try viewContext.fetch(request)
            print(" PreviousTravelViewModel : fetchTravel")
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
        }
    }
    
    func filterPreviouTravel(todayDate: Date) -> [Travel] {
        return previousTravel.filter { travel in
            if let endDate = travel.endDate {
                print("filterPreviousTravel | travel.id \(String(describing: travel.id))")
                return endDate < todayDate
            } else {
                print("filterPreviousTravel | travel.id: nil")
                return false
            }
        }
    }
}
