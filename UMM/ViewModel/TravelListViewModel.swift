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
    // 현재 진행 중인 여행의 개수
    @Published var travelCount: Int = 3
    // 현재 진행 중인 여행들을 [Travel]에 다 저장
    @Published var nowTravel: [Travel] = []
    let now = Date()
    let calendar = Calendar.current
    
    // 1. Travel Entity에서 Date()가 startDate와 endDate 사이에 있는 여행들의 UUID 불러오기
//    func filterTravelByDate(startDate: Date, endDate: Date?) -> [Travel] {
//        return nowTravel.filter { travel in
//            if let todayDate = Date() {
//                return todayDate >= startDate && todayDate < endDate!
//
//            } else {
//                return false
//            }
//        }
//    }
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            nowTravel = try viewContext.fetch(request)
            print("TravelListViewModel : fetchTravel")
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
        }
    }
    
//    func filterTravelByDate(startDate: Date, endDate: Date?) -> [Travel] {
//        return nowTravel.filter { travel in
//            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
//            if let todayDate = Calendar.current.date(from: dateComponents), let endDate = endDate {
//                print("filterTravelByDate | travel.id: \(String(describing: travel.id))")
//                return todayDate >= startDate && todayDate < endDate
//            } else {
//                return false
//            }
//        }
//    }
    
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

}
