//
//  TravelDetailViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/27.
//

import Foundation
import CoreData

class TravelDetailViewModel: ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var savedTravel: [Travel] = []
    @Published var selectedTravel: [Travel]?
    @Published var travelID = UUID()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YY.MM.dd (E)"
        
        return formatter
    }()
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            savedTravel = try viewContext.fetch(request)
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
        }
    }
    
    func filterByID(selectedTravelID: UUID) -> [Travel] {
        return savedTravel.filter { travel in
            if let id = travel.id {
                return id == selectedTravelID
            } else {
                return false
            }
        }
    }
}
