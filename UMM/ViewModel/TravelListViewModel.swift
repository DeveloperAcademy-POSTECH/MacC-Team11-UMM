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
    
    @Published var nowTravel: [Travel] = []
    @Published var defaultTravel: [Travel] = []
    @Published var savedExpensesByTravel: [Expense] = []
    
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
    
    func updateTravel() {
        let travel = Travel(context: viewContext)
        travel.name = nowTravel.first?.name
    }
    
    func saveTravel() {
        do {
            try viewContext.save()
            print("save travel")
        } catch let error {
            print("Error while SaveTravel: \(error.localizedDescription)")
        }
    }
    
    func fetchDefaultTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            defaultTravel = try viewContext.fetch(request)
            print("TravelListViewModel : fetchDefaulTravel")
        } catch let error {
            print("Error while fetchDefaultTravel : \(error.localizedDescription)")
        }
    }
    
    func fetchExpense() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        do {
        savedExpensesByTravel = try viewContext.fetch(request)
        } catch let error {
            print("Error while fetchExpense: \(error.localizedDescription)")
        }
    }
    
    // 현재 여행의 id와 Expense의 Travel의 id를 비교해서 저장된 지출 정보 가져오기
    func filterExpensesByTravel(selectedTravelID: UUID) -> [Expense] {
        return savedExpensesByTravel.filter { expense in
            if let travelID = expense.travel?.id {
                return travelID == selectedTravelID
            } else {
                return false
            }
        }
    }
    
    func getCountryForExpense(_ expense: Expense) -> Int64 {
        if let country = expense.country as? Int64 {
            return country
        }
        return -1
    }
    
    func filterTravelByDate(todayDate: Date) -> [Travel] {
        return nowTravel.filter { travel in
            if let startDate = travel.startDate?.convertBeforeShowing() {
                let endDate = travel.endDate?.convertBeforeShowing() ?? Date.distantFuture
                return todayDate >= startDate && todayDate <= endDate
            } else {
                print("filterTravelByDate | travel.startDate: nil")
                return false
            }
        }
    }
    
    func arrayToString(partArray: [String]) -> String {
        
        var res = ""
        for index in 0..<partArray.count {
            if index == 0 {
                res += ", "
            }
            res += partArray[index]
            if index < partArray.count - 1 {
                res += ", "
            }
        }
        return res
    }
    
    // 여행 이름이 Default인 여행
    func findTravelNameDefault() -> [Travel] {
        return defaultTravel.filter { travel in
            if let name = travel.name {
                return name == tempTravelName
            } else {
                return false
            }
        }
    }
    
    func filterDefaultExpense(selectedTravelName: String) -> [Expense] {
        return savedExpensesByTravel.filter { expense in
            if let travelNM = expense.travel?.name {
                return travelNM == selectedTravelName
            } else {
                return false
            }
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY.MM.dd"
        
        return formatter
    }()
    
    // 선택된 Travel의 startDate와 오늘 날짜의 차이를 구하는 함수
    // 날짜 두개 input -> 차이값 아웃풋
    func differenceBetweenToday(today: Date, startDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: today)
        return components.day ?? 0
    }
    
    func formatAmount(amount: Double?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = .decimal
        if let formattedAmount = numberFormatter.string(from: NSNumber(value: amount ?? Double(0))) {
            return formattedAmount
        } else {
            return "amount"
        }
    }
}
