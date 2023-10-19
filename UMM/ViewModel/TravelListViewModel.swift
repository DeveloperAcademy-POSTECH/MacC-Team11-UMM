//
//  TravelListViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import Foundation
import CoreData
import SwiftUI

class TravelListViewModel: ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    // 현재 진행 중인 여행들을 [Travel]에 다 저장
    @Published var nowTravel: [Travel] = []
    let now = Date()
    let calendar = Calendar.current
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            nowTravel = try viewContext.fetch(request)
            print("TravelListViewModel : fetchTravel")
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
        }
    }
    
    func filterTravelByDate(todayDate: Date) -> [Travel] {
        return nowTravel.filter { travel in
            if let startDate = travel.startDate, let endDate = travel.endDate {
                print("filterTravelByDate | travel.id: \(String(describing: travel.id))")
                return todayDate >= startDate && todayDate < endDate
            } else {
                print("filterTravelByDate | travel.id: nil")
                return false
            }
        }
    }
    
    func arrayToString(partArray: [String]) -> String {
        var res = ""
        for index in 0..<partArray.count {
            res += partArray[index]
            if index < partArray.count - 2 {
                res += ","
            }
        }
        return res
    }

}
