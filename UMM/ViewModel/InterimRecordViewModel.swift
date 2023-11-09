//
//  InterimRecordViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/04.
//

import Foundation
import CoreData
import SwiftUI

class InterimRecordViewModel: ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var defaultTravel: [Travel] = []
    @Published var defaultExpense: [Expense] = []
    @Published var previousTravel: [Travel] = []
    @Published var nowTravel: [Travel] = []
    @Published var upcomingTravel: [Travel] = []
    @Published var savedExpensesByTravel: [Expense] = []
    
    // 확인시 저장될 것들
    @Published var chosenTravel: Travel?
    @Published var chosenExpense: Expense?
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            defaultTravel = try viewContext.fetch(request)
            print("TravelListViewModel : fetchDefaulTravel")
        } catch let error {
            print("Error while fetchDefaultTravel : \(error.localizedDescription)")
        }
    }
    
    func fetchNowTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            nowTravel = try viewContext.fetch(request)
            print("TravelListViewModel : fetchDefaulTravel")
        } catch let error {
            print("Error while fetchDefaultTravel : \(error.localizedDescription)")
        }
    }
    
    func fetchPreviousTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            previousTravel = try viewContext.fetch(request)
            print("TravelListViewModel : fetchDefaulTravel")
        } catch let error {
            print("Error while fetchDefaultTravel : \(error.localizedDescription)")
        }
    }
    
    func fetchUpcomingTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            upcomingTravel = try viewContext.fetch(request)
            print("TravelListViewModel : fetchDefaulTravel")
        } catch let error {
            print("Error while fetchDefaultTravel : \(error.localizedDescription)")
        }
    }
    
    func findTravelNameDefault() -> [Travel] {
        return defaultTravel.filter { travel in
            if let name = travel.name {
                return name == "Default"
            } else {
                return false
            }
        }
    }
    
    func fetchExpense() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        do {
            defaultExpense = try viewContext.fetch(request)
        } catch let error {
            print("Error while fetchExpense: \(error.localizedDescription)")
        }
    }
    
    func fetchSavedExpense() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        do {
        savedExpensesByTravel = try viewContext.fetch(request)
        } catch let error {
            print("Error while fetchExpense: \(error.localizedDescription)")
        }
    }
    
    func filterDefaultExpense(selectedTravelName: String) -> [Expense] {
        return defaultExpense.filter { expense in
            if let travelNM = expense.travel?.name {
                return travelNM == selectedTravelName
            } else {
                return false
            }
        }
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
    
    // MARK: 각각의 여행들이 몇갠지 찾기위한 함수들
    func filterPreviousTravel(todayDate: Date) -> [Travel] {
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
    
    func filterTravelByDate(todayDate: Date) -> [Travel] {
        return nowTravel.filter { travel in
            if let startDate = travel.startDate {
                let endDate = travel.endDate ?? Date.distantFuture
                print("filterTravelByDate | travel.id: \(String(describing: travel.id))")
                return todayDate >= startDate && todayDate < endDate
            } else {
                print("filterTravelByDate | travel.id: nil")
                return false
            }
        }
    }
    
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
    
    func update() {
        
        if chosenExpense == nil, let firstExpense = defaultExpense.first {
            chosenExpense = firstExpense
        }
        
        if let chosenExpenseID = chosenExpense?.travel?.id,
            let chosenTravelID = chosenTravel?.id {
            if chosenExpenseID != chosenTravelID {
                chosenExpense?.travel? = chosenTravel!
            }
        }
        
        if let context = chosenExpense?.managedObjectContext {
            do {
                try context.save()
                print("Data saved successfully.")
            } catch {
                print("Error saving data: \(error)")
            }
        }
    }
    
    // defaultExpense를 최신순으로 정렬합니다.
    func sortDefaultExpense(expenseArr: [Expense]?) -> [Expense] {
        
        guard var expenses = expenseArr else {
            return []
        }
        
        expenses.sort { (expense1, expense2) -> Bool in
            return expense1.payDate! >= expense2.payDate!
        }
        
        return expenses
    }
}
