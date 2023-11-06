//
//  TempSave.swift
//  UMM
//
//  Created by 김태현 on 10/17/23.
//

import CoreData
import SwiftUI

class TempSave {
    static let shared = TempSave()
    let viewContext = PersistenceController.shared.container.viewContext
    var travelArray: [Travel] = [Travel]()
    static let nowDate = Date()
    
    // dummyTravelData를 위한 프로퍼티
    let dummyTravelName = ["DummyTravel0", "DummyTravel1", "DummyTravel2", "DummyTravel3"]
    let dummyTravelStartDate = [
        DateGapHandler.shared.getLocal000(of: Calendar.current.date(byAdding: .day, value: -4, to: nowDate)!),
        DateGapHandler.shared.getLocal000(of: Calendar.current.date(byAdding: .day, value: -2, to: nowDate)!),
        DateGapHandler.shared.getLocal000(of: Calendar.current.date(byAdding: .day, value: -2, to: nowDate)!),
        DateGapHandler.shared.getLocal000(of: Calendar.current.date(byAdding: .day, value: +3, to: nowDate)!)
    ]
    let dummyTravelEndDate = [
        DateGapHandler.shared.getLocal235959(of: Calendar.current.date(byAdding: .day, value: -2, to: nowDate)!),
        DateGapHandler.shared.getLocal235959(of: Calendar.current.date(byAdding: .day, value: +2, to: nowDate)!),
        DateGapHandler.shared.getLocal235959(of: Calendar.current.date(byAdding: .day, value: +3, to: nowDate)!),
        DateGapHandler.shared.getLocal235959(of: Calendar.current.date(byAdding: .day, value: +10, to: nowDate)!)
    ]
    let dummyTravelLastUpdate = [
        Calendar.current.date(byAdding: .day, value: -1, to: nowDate)!,
        Calendar.current.date(byAdding: .day, value: -2, to: nowDate)!,
        Calendar.current.date(byAdding: .day, value: -3, to: nowDate)!,
        Calendar.current.date(byAdding: .day, value: -4, to: nowDate)!
    ]
    // dummyExpenseData를 위한 프로퍼티
    let dummyExpenseName = ["DummyExpense0", "DummyExpense1", "DummyExpense2", "DummyExpense3"]
    let dummyExpensePayDate = Calendar.current.date(byAdding: .day, value: -1, to: nowDate)!
    let dummyExpenseCurrency = Int.random(in: 1...5)
    let dummyExpenseExchangeRate = Double(Int.random(in: 1...5))
    let dummyExpenseInfo = ["DummyExpenseInfo0", "DummyExpenseInfo1", "DummyExpenseInfo2", "DummyExpenseInfo3"]
    let dummyExpenseCountry = Int.random(in: 1...5)
    let dummyExpenseLocation = ["DummyExpenseLocation0", "DummyExpenseLocation1", "DummyExpenseLocation2", "DummyExpenseLocation3"]
    let dummyExpenseParticipantArray = [["도리스, 올리버"], ["올리버", "페페"], ["니코", "해나", "도리스"]]
    let dummyExpensePaymentMethod = Int.random(in: 0...1)
    let dummyExpensePayAmount = Double(Int.random(in: 1000...30000))
    let dummyExpenseCategory = Int.random(in: -1...5)
    
    init() {
        if let isFirst = UserDefaults.standard.object(forKey: "TempSave.isFirst") as? Bool {
            if isFirst {
                // ADD Dummy Travel
                addDefaultTravel()
                addDummyTravel(seed: 0)
                addDummyTravel(seed: 1)
                addDummyTravel(seed: 2)
                addDummyTravel(seed: 3)
                // Fetch travelArray and ADD Dummy Expense
                do {
                    travelArray = try viewContext.fetch(Travel.fetchRequest())
                } catch let error {
                    print("error while TempSave: \(error.localizedDescription)")
                }
                for travel in travelArray {
                    for _ in 1...3 {
                        addExpense(travel: travel)
                    }
                }
                save()
            }
        } else {
            // ADD Dummy Travel
            addDefaultTravel()
            addDummyTravel(seed: 0)
            addDummyTravel(seed: 1)
            addDummyTravel(seed: 2)
            addDummyTravel(seed: 3)
            // Fetch travelArray and ADD Dummy Expense
            do {
                travelArray = try viewContext.fetch(Travel.fetchRequest())
            } catch let error {
                print("error while TempSave: \(error.localizedDescription)")
            }
            for travel in travelArray {
                for _ in 1...3 {
                    addExpense(travel: travel)
                }
            }
            save()
        }
        UserDefaults.standard.set(false, forKey: "TempSave.isFirst")
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch let error {
            print("Error while saveDummyTravel: \(error.localizedDescription)")
        }
    }
    
    // default Travel을 추가하는 함수
    func addDefaultTravel() {
        let tempTravel = Travel(context: viewContext)
        tempTravel.id = UUID()
        tempTravel.name = "Default"
        tempTravel.startDate = TempSave.nowDate
        tempTravel.endDate = TempSave.nowDate
        tempTravel.lastUpdate = TempSave.nowDate
    }
    
    // dummy Travel을 추가하는 함수
    func addDummyTravel(seed: Int) {
        let tempTravel = Travel(context: viewContext)
        tempTravel.id = UUID()
        tempTravel.name = dummyTravelName[seed]
        tempTravel.startDate = dummyTravelStartDate[seed]
        tempTravel.endDate = dummyTravelEndDate[seed]
        tempTravel.lastUpdate = dummyTravelLastUpdate[seed]
    }
    
    func addExpense(travel: Travel) {
        var targetTravel: Travel?
        do {
            targetTravel = try viewContext.fetch(Travel.fetchRequest()).first(where: { $0.id == travel.id })
            print("targetTravel: \(String(describing: targetTravel))")
        } catch {
            print("Error while targetting: \(error.localizedDescription)")
        }
        let tempExpense = Expense(context: viewContext)
        tempExpense.currency = Int64(dummyExpenseCurrency)
        tempExpense.exchangeRate = Double(dummyExpenseExchangeRate)
        tempExpense.info = dummyExpenseInfo.randomElement()
        tempExpense.country = Int64(dummyExpenseCountry)
        tempExpense.location = dummyExpenseLocation.randomElement()
        tempExpense.participantArray = dummyExpenseParticipantArray.randomElement()
        tempExpense.paymentMethod = Int64(dummyExpensePaymentMethod)
        tempExpense.payAmount = Double(dummyExpensePayAmount)
        tempExpense.payDate = dummyExpensePayDate
        tempExpense.category = Int64(dummyExpenseCategory)
        
        if let targetTravel {
            targetTravel.addToExpenseArray(tempExpense)
        }
    }
}
