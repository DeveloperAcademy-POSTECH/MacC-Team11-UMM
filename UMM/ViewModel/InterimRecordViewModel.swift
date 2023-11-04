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
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            defaultTravel = try viewContext.fetch(request)
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
    
    func filterDefaultExpense(selectedTravelName: String) -> [Expense] {
        return defaultExpense.filter { expense in
            if let travelNM = expense.travel?.name {
                return travelNM == selectedTravelName
            } else {
                return false
            }
        }
    }
}
