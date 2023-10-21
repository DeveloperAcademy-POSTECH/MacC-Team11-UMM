//
//  ExpenseViewModel.swift
//  UMM
//
//  Created by 김태현 on 10/17/23.
//

import Foundation
import CoreData
import SwiftUI

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
    
    @Published var travelChoiceHalfModalIsShown = false {
        willSet {
            if newValue {
                filteredExpenses = getFilteredExpenses()
                groupedExpenses = Dictionary(grouping: filteredExpenses, by: { $0.country })
            }
        }
    }
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
    
    func calculateCurrencyAndSums(from expenses: [Expense]) -> [CurrencyAndSum] {
        var currencyAndSums = [CurrencyAndSum]()
        let currencies = Array(Set(expenses.map { $0.currency })).sorted { $0 < $1 }

        for currency in currencies {
            let sum = expenses.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount }
            currencyAndSums.append(CurrencyAndSum(currency: currency, sum: sum))
        }
        
        return currencyAndSums
    }
    
    // 소수점 두 자리로 반올림, 소수점 아래 값이 없으면 정수형처럼 반환
    func formatSum(_ sum: Double, _ to: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0 // 최소한 필요한 소수점 자릿수
        formatter.maximumFractionDigits = to // 최대 허용되는 소수점 자릿수
        
        return formatter.string(from: NSNumber(value: sum)) ?? ""
    }
    
    func getFilteredExpenses() -> [Expense] {
        let filteredByTravel = filterExpensesByTravel(expenses: savedExpenses, selectedTravelID: selectedTravel?.id ?? UUID())
        let filteredByDate = filterExpensesByDate(expenses: filteredByTravel, selectedDate: selectedDate)
        return filteredByDate
    }
    
    func daysBetweenTravelDates(selectedTravel: Travel, selectedDate: Date) -> Int {
        guard let startDate = selectedTravel.startDate else { return 0 }
        let calendar = Calendar.current
        let startOfDayStartDate = calendar.startOfDay(for: startDate)
        let startOfDayEndDate = calendar.startOfDay(for: selectedDate)
        let components = calendar.dateComponents([.day], from: startOfDayStartDate, to: startOfDayEndDate)
        guard let calculatedDay = components.day else {return 0 }

        return calculatedDay
    }
    
    // MARK: - 커스텀 Date Picker를 위한 함수
    func triggerDatePickerPopover(pickerId: String) {
        if
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first,
            let picker = window.accessibilityDescendant(identifiedAs: pickerId) as? NSObject,
            let button = picker.buttonAccessibilityDescendant() as? NSObject
        {
            button.accessibilityActivate()
        }
    }
}
