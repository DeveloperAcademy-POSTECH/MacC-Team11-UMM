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
    @Published var savedExpensesByTravel: [Expense] = []
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            previousTravel = try viewContext.fetch(request)
            print(" PreviousTravelViewModel : fetchTravel")
        } catch let error {
            print("Error while fetchTravel : \(error.localizedDescription)")
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
    
    func filterPreviousTravel(todayDate: Date) -> [Travel] {
        return previousTravel.filter { travel in
            if let endDate = travel.endDate?.convertBeforeShowing() {
                print("filterPreviousTravel | travel.id \(String(describing: travel.id))")
                return endDate < todayDate
            } else {
                print("filterPreviousTravel | travel.id: nil")
                return false
            }
        }
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY.MM.dd"
        
        return formatter
    }()
    
    func differenceBetweenToday(today: Date, startDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: today)
        return components.day ?? 0
    }
}
