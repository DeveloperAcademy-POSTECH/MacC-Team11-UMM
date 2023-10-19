//
//  ExpenseViewModel.swift
//  UMM
//
//  Created by 김태현 on 10/17/23.
//

import Foundation
import CoreData

class ExpenseViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    let dummyRecordViewModel = DummyRecordViewModel()
    
    @Published var savedExpenses: [Expense] = []
    @Published var filteredExpenses: [Expense] = []
    @Published var groupedExpenses: [Int64: [Expense]] = [:]
    @Published var selectedTravel: Travel?
    @Published var selectedDate = Date()
    @Published var selectedLocation: String = ""
    @Published var selectedPaymentMethod: Int64 = 0
    @Published var selectedCountry: Int64 = 0
    @Published var selectedCategory: Int64 = 0
    
    func fetchExpense() {
        let request = NSFetchRequest<Expense>(entityName: "Expense")
        do {
            savedExpenses = try viewContext.fetch(request)
        } catch let error {
            print("Error while fetchExpense: \(error.localizedDescription)")
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
    
    func addExpense(travel: Travel) {
        let infos = ["여행", "쇼핑", "관광"]
        let participantArray = [["John", "Alice"], ["Bob"], ["Charlie"]]
        let payAmounts = [50.0, 1000.25, 80.0]
        let locations = ["서울", "도쿄", "파리", "상파울루", "바그다드", "짐바브웨"]
        let exchangeRates = [1.0, 0.009, 1.1]

        let tempExpense = Expense(context: viewContext)
        tempExpense.currency = Int64(Int.random(in: -1...6))
        tempExpense.exchangeRate = exchangeRates.randomElement() ?? 0.5
        tempExpense.info = infos.randomElement()
        tempExpense.location = locations.randomElement()
        tempExpense.participantArray = participantArray.randomElement()
        tempExpense.paymentMethod = Int64(Int.random(in: -1...1))
        tempExpense.payAmount = Double(payAmounts.randomElement() ?? 300.0)
        tempExpense.payDate = Date()
        tempExpense.category = Int64(Int.random(in: -1...5))
        tempExpense.country = Int64(Int.random(in: -1...5))
        
        // 현재 선택된 여행에 추가할 수 있도록
        dummyRecordViewModel.fetchDummyTravel()
        if let targetTravel = dummyRecordViewModel.savedTravels.first(where: { $0.id == travel.id}) {
            targetTravel.addToExpenseArray(tempExpense)
            targetTravel.lastUpdate = Date()
            print("targetTravel.lastUpdate: \(String(describing: targetTravel.lastUpdate))")
            saveExpense()
        } else {
            print("Error while addExpense")
        }
    }
    
    func filterExpensesByTravel(expenses: [Expense], selectedTravelID: UUID) -> [Expense] {
        return expenses.filter { $0.travel?.id == selectedTravelID }
    }
    
    func filterExpensesByLocation(expenses: [Expense], location: String) -> [Expense] {
        return expenses.filter { $0.location == location }
    }
    
    func filterExpensesByCategory(expenses: [Expense], category: Int64) -> [Expense] {
        return expenses.filter { $0.category == category }
    }
    
    func filterExpensesByPaymentMethod(expenses: [Expense], paymentMethod: Int64) -> [Expense] {
        return expenses.filter { $0.paymentMethod == paymentMethod }
    }
    
    func filterExpensesByCountry(expenses: [Expense], country: Int64) -> [Expense] {
        return expenses.filter { $0.country == country }
    }
    
    func filterExpensesByDate(expenses: [Expense], selectedDate: Date) -> [Expense] {
        return expenses.filter { expense in
            if let payDate = expense.payDate {
                return Calendar.current.isDate(payDate, inSameDayAs: selectedDate)
            } else {
                return false
            }
        }
    }
    
    func calculateCurrencySums(from expenses: [Expense]) -> [CurrencySum] {
        var currencySums = [CurrencySum]()
        let currencies = Array(Set(expenses.map { $0.currency })).sorted { $0 < $1 }

        for currency in currencies {
            let sum = expenses.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount }
            currencySums.append(CurrencySum(currency: currency, sum: sum))
        }
        
        return currencySums
    }
    
    // MARK: - 아직 안 씀
    func groupExpensesByLocation(expenses: [Expense], location: String) -> [String?: [Expense]] {
        return Dictionary(grouping: expenses, by: { $0.location })
    }
    
    func groupExpensesByCategory(expenses: [Expense], category: Int64) -> [Int64?: [Expense]] {
        return Dictionary(grouping: expenses, by: { $0.category })
    }
}
