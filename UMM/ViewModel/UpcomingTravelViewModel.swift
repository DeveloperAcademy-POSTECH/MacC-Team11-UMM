//
//  UpcomingTravelViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import Foundation
import CoreData

class UpcomingTravelViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var upcomingTravel: [Travel] = []
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            upcomingTravel = try viewContext.fetch(request)
            print("UpcomingTravelViewModel : fetchTravel")
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
        }
    }
    
    func filterUpcomingTravel(todayDate: Date) -> [Travel] {
        return upcomingTravel.filter { travel in
            if let startDate = travel.startDate {
                print("filterUpcomingTravel travel.id \(String(describing: travel.id))")
                return startDate > todayDate
            } else {
                print("filterUpcomingTravel travel.id: nil")
                return false
            }
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY.MM.dd"
        
        return formatter
    }()

}
