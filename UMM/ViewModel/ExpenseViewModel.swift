//
//  ExpenseViewModel.swift
//  UMM
//
//  Created by 김태현 on 10/12/23.
//

import Foundation
import CoreData

class ExpenseViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    let dummyRecordViewModel = DummyRecordViewModel()
    
    @Published var savedExpenses: [Expense] = []
    
    func fetchExpense() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        do {
            savedExpenses = try viewContext.fetch(request)
        } catch let error {
            print("Error while fetchExpense: \(error.localizedDescription)")
        }
    }
    
    func addExpense(travel: Travel) {
        let infos = ["여행", "쇼핑", "관광"]
        let participants = [["John", "Alice"], ["Bob"], ["Charlie"]]
        let payAmounts = [50.0, 100.25, 80.0]
        let paymentMethods = [1, 2, 1]
        let voiceRecordFiles = ["voice1.mp3", "voice2.mp3", "voice3.mp3"]
        let locations = ["서울", "도쿄", "파리", "상파울루", "바그다드", "짐바브웨"]
        let currencies = [0, 1, 2]
        let exchangeRates = [1.0, 0.009, 1.1]

        let tempExpense = Expense(context: viewContext)
        tempExpense.currency = Int64(currencies.randomElement() ?? 0)
        tempExpense.exchangeRate = exchangeRates.randomElement() ?? 0.5
        tempExpense.info = infos.randomElement()
        tempExpense.location = locations.randomElement()
        tempExpense.participant = participants.randomElement()
        tempExpense.paymentMethod = Int64(paymentMethods.randomElement() ?? 0)
        tempExpense.payAmount = Double(payAmounts.randomElement() ?? 300.0)
        tempExpense.payDate = Date()
        
        // 현재 선택된 여행에 추가할 수 있도록
        dummyRecordViewModel.fetchDummyTravel()
        if let targetTravel = dummyRecordViewModel.savedTravels.first(where: { $0.id == travel.id}) {
            targetTravel.addToExpenseArray(tempExpense)
            saveExpense()
        } else {
            print("Error while addExpense")
        }
    }
    
    func saveExpense() {
        do {
            try viewContext.save()
            fetchExpense()
        } catch let error {
            print("Error while saveExpense: \(error.localizedDescription)")
        }
    }
}
