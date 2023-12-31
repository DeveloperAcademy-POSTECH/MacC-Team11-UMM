//
//  ExpenseViewModel.swift
//  UMM
//
//  Created by 김태현 on 10/17/23.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class ExpenseViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    private let exchangeRateHandler = ExchangeRateHandler.shared
    let currencyInfoModel = CurrencyInfoModel.shared.currencyResult

    var savedTravels: [Travel] = []
    var savedExpenses: [Expense] = []
    var filteredTodayExpenses: [Expense] = []
    @Published var filteredTodayExpensesForDetail: [Expense] = []
    var filteredAllExpenses: [Expense] = []
    @Published var filteredAllExpensesForDetail: [Expense] = []
    @Published var filteredAllExpensesByCountry: [Expense] = []
    @Published var groupedTodayExpenses: [Int64: [Expense]] = [:]
    @Published var groupedAllExpenses: [Int64: [Expense]] = [:]
//    @Published var selectedTravel: Travel? // MainViewModel로 이동
    @Published var selectedDate = Date()
    @Published var selectedLocation: String = ""
    @Published var selectedPaymentMethod: Int64 = 0
    @Published var selectedCountry: Int64 = -2
    @Published var selectedCategory: Int64 = 0
    @Published var travelChoiceHalfModalIsShown = false
    @Published var indexedSumArrayInPayAmountOrder = [(Int64, Double)]()
    let categoryArray = [Int64]([-1, 0, 1, 2, 3, 4, 5, 6])
    
    private var travelPublisher: AnyPublisher<Travel?, Never> {
        MainViewModel.shared.$selectedTravelInExpense
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private var travelStream: AnyCancellable?
    private var prevSelectedDate: Date?
    private var prevSelectedCountry: Int64?
    
    init() {
        setupSelectedTravel()
    }
    
    func fetchTravel() {
        let request = NSFetchRequest<Travel>(entityName: "Travel")
        do {
            savedTravels = try viewContext.fetch(request)
        } catch let error {
            print("Error during fetchTravel: \(error.localizedDescription)")
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
        if country == Int64(-2) {
            return expenses
        } else {
            return expenses.filter { $0.country == country }
        }
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
    
    func calculateCurrencySums(from expenses: [Expense]) -> [CurrencyAndSum] {
        var currencyAndSums = [CurrencyAndSum]()
        let currencies = Array(Set(expenses.map { $0.currency })).sorted { $0 < $1 }

        for currency in currencies {
            let sum = expenses.filter({ $0.currency == currency }).reduce(0) { $0 + ($1.payAmount == -1 ? 0 : $1.payAmount) }
            currencyAndSums.append(CurrencyAndSum(currency: currency, sum: sum))
        }
        
        return currencyAndSums
    }
    
    // parameter: 변환할 Double, 표시할 소수점 아래 자리 수
    func formatSum(from sum: Double, to num: Int) -> String {
        if sum.isNaN {
            return "-"
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0 // 최소한 필요한 소수점 자릿수
            formatter.maximumFractionDigits = num // 최대 허용되는 소수점 자릿수
            return formatter.string(from: NSNumber(value: sum)) ?? ""
        }
    }
    
    func daysBetweenTravelDates(selectedTravel: Travel, selectedDate: Date) -> Int {
        guard let startDate = MainViewModel.shared.selectedTravelInExpense?.startDate else { return 0 }
        let calendar = Calendar.current
        let startOfDayStartDate = calendar.startOfDay(for: startDate)
        let startOfDayEndDate = calendar.startOfDay(for: selectedDate)
        let components = calendar.dateComponents([.day], from: startOfDayStartDate, to: startOfDayEndDate)
        guard let calculatedDay = components.day else {return 0 }

        return calculatedDay
    }

    // MARK: - 커스텀 Date Picker를 위한 함수
    func triggerDatePickerPopover(pickerId: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            print("Cannot find scene")
            return
        }
        print("Scene found: \(scene)")
        
        guard let window = scene.windows.first else {
            print("Cannot find window")
            return
        }
        print("Window found: \(window)")
        
        guard let picker = window.accessibilityDescendant(identifiedAs: pickerId) as? NSObject else {
            print("Cannot find pickerId: \(pickerId)")
            return
        }
        print("Picker found: \(picker)")
        
        guard let button = picker.buttonAccessibilityDescendant() as? NSObject else {
            print("Cannot find button")
            return
        }
        print("Button found: \(button)")
        
        button.accessibilityActivate()
    }
    
    func getPayAmountOrderedIndicesOfCategory(categoryArray: [Int64], expenseArray: [Expense]) -> [(Int64, Double)] {
        let filteredExpenseArrayArray = categoryArray.map { category in
            expenseArray.filter {
                $0.category == category
            }
        }
        
        let sumArray = filteredExpenseArrayArray.map { expenseArray in
            let sum = expenseArray.reduce(0) { (result, expense) in
                let payAmount = expense.payAmount == -1 ? 0 : expense.payAmount
                let currencyCode = currencyInfoModel[Int(expense.currency)]?.isoCodeNm ?? "-"
                let exchangeRate = exchangeRateHandler.getExchangeRateFromKRW(currencyCode: currencyCode)
                return result + (payAmount * (exchangeRate ?? -100))
            }
            return sum
        }
        
        let indexedSumArray: [(Int64, Double)] = [
            (categoryArray[0], sumArray[0]),
            (categoryArray[1], sumArray[1]),
            (categoryArray[2], sumArray[2]),
            (categoryArray[3], sumArray[3]),
            (categoryArray[4], sumArray[4]),
            (categoryArray[5], sumArray[5]),
            (categoryArray[6], sumArray[6]),
            (categoryArray[7], sumArray[7]),
        ].sorted {
            $0.1 >= $1.1
        }
        return indexedSumArray
    }
    
    func fetchCountryForAllExpense(country: Int64) {
        filteredAllExpenses = getFilteredAllExpenses()
        filteredAllExpensesByCountry = filterExpensesByCountry(expenses: filteredAllExpenses, country: country)
        groupedAllExpenses = Dictionary(grouping: filteredAllExpensesByCountry, by: { $0.category })
        indexedSumArrayInPayAmountOrder = getPayAmountOrderedIndicesOfCategory(categoryArray: categoryArray, expenseArray: filteredAllExpenses)
    }
    
    func setupSelectedTravel() {
        travelStream = travelPublisher
            .sink { [weak self] travel in
                guard let self = self else { return }
                self.fetchExpense()
                self.filteredTodayExpenses = self.getFilteredTodayExpenses()
                self.groupedTodayExpenses = Dictionary(grouping: self.filteredTodayExpenses, by: { $0.country })
                self.filteredAllExpenses = self.getFilteredAllExpenses()
                self.filteredAllExpensesByCountry = self.filterExpensesByCountry(expenses: self.filteredAllExpenses, country: Int64(-2))
                self.groupedAllExpenses = Dictionary(grouping: self.filteredAllExpensesByCountry, by: { $0.category })
                self.indexedSumArrayInPayAmountOrder = getPayAmountOrderedIndicesOfCategory(categoryArray: categoryArray, expenseArray: filteredAllExpenses)
            }
    }
    
    func getFilteredTodayExpenses() -> [Expense] {
        let filteredByTravel = filterExpensesByTravel(expenses: self.savedExpenses, selectedTravelID: MainViewModel.shared.selectedTravelInExpense?.id ?? UUID())
        let filteredByDate = filterExpensesByDate(expenses: filteredByTravel, selectedDate: selectedDate)
        return filteredByDate
    }
    
    func getFilteredAllExpenses() -> [Expense] {
        let filteredByTravel = filterExpensesByTravel(expenses: self.savedExpenses, selectedTravelID: MainViewModel.shared.selectedTravelInExpense?.id ?? UUID())
        return filteredByTravel
    }
    
    func datePickerRange() -> ClosedRange<Date> {
        let now = Date()
        let now235959 = DateGapHandler.shared.getLocal235959(of: Date())
        let startDateOfTravel = MainViewModel.shared.selectedTravelInExpense?.startDate ?? Date.distantPast
        let endDateOfTravel = MainViewModel.shared.selectedTravelInExpense?.endDate ?? Date.distantFuture

        if startDateOfTravel > now235959 {
            // 여행의 시작 날짜가 오늘보다 미래에 있을 때
            return DateGapHandler.shared.convertBeforeShowing(date: startDateOfTravel)...DateGapHandler.shared.convertBeforeShowing(date: endDateOfTravel)
        } else {
            // 여행의 시작 날짜가 오늘과 같거나 과거에 있을 때
            if endDateOfTravel < now {
                // 여행의 끝 날짜가 현재보다 과거에 있을 때
                return DateGapHandler.shared.convertBeforeShowing(date: startDateOfTravel)...DateGapHandler.shared.convertBeforeShowing(date: endDateOfTravel)
            } else {
                // 그 외의 경우 (여행의 끝 날짜가 현재보다 미래에 있을 때)
                return DateGapHandler.shared.convertBeforeShowing(date: startDateOfTravel)...DateGapHandler.shared.convertBeforeShowing(date: now)
            }
        }
    }
}
