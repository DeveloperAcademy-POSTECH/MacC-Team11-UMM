//
//  AllExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
    @State private var selectedPaymentMethod: Int64 = -2
    
    init() {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("전체 지출")
                
                // Picker: 여행별
                Picker("현재 여행", selection: $expenseViewModel.selectedTravel) {
                    ForEach(dummyRecordViewModel.savedTravels, id: \.self) { travel in
                        Text(travel.name ?? "no name").tag(travel as Travel?) // travel의 id가 선택지로
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onReceive(expenseViewModel.$selectedTravel) { _ in
                    DispatchQueue.main.async {
                        expenseViewModel.filteredExpenses = getFilteredExpenses()
                        expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
                        print("TodayExpenseView | onReceive | done")
                    }
                }
                
                //  Picker : 국가별
                Picker("나라 별로", selection: $expenseViewModel.selectedCountry) {
                    let allExpensesInSelectedTravel = expenseViewModel.savedExpenses
                    let countries = Array(Set(allExpensesInSelectedTravel.compactMap { $0.country })).sorted { $0 < $1 } // 중복 제거
                    
                    ForEach(countries, id: \.self) { country in
                        Text("Country: \(country)").tag(Int64(country))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onReceive(expenseViewModel.$selectedCountry) { _ in
                    DispatchQueue.main.async {
                        expenseViewModel.filteredExpenses = getFilteredExpenses()
                        expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
                    }
                }

                Spacer()
                
                drawExpensesByCategory
            }
        }
        .onAppear {
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            
            expenseViewModel.filteredExpenses = getFilteredExpenses()
        }
    }
    
    // 1. 나라별
    // 1-1. 항목별
    private var drawExpensesByCategory: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedExpenses.keys)).sorted { $0 < $1 }
        return ForEach(countryArray, id: \.self) { country in
            if country == expenseViewModel.selectedCountry {
                let categoryArray = [Int64]([-1, 0, 1, 2, 3, 4, 5])
                let expenseArray = expenseViewModel.filteredExpenses.filter { $0.country == country }
                let totalSum = expenseArray.reduce(0) { $0 + $1.payAmount }
                let indexedSumArrayInPayAmountOrder = getPayAmountOrderedIndicesOfCategory(categoryArray: categoryArray, expenseArray: expenseArray)
                
                VStack {
                    Text("나라 이름: \(country)")
                    Text("전첵 금액 합: \(totalSum)")
                    Text("categoryArray.count: \(categoryArray.count)")
                    Text("countryArray.count: \(countryArray.count)")
                }
                
                ForEach(0..<categoryArray.count, id: \.self) { index in
                    NavigationLink {
                        AllExpenseDetailView(
                            selectedTravel: expenseViewModel.selectedTravel,
                            selectedCategory: indexedSumArrayInPayAmountOrder[index].0,
                            selectedCountry: country,
                            selectedPaymentMethod: -2
                        )
                    } label:{
                        VStack {
                            Text("카테고리 이름 : \(indexedSumArrayInPayAmountOrder[index].0)")
                            Text("카테고리별 금액 합 : \(indexedSumArrayInPayAmountOrder[index].1)")
                        }
                    }
                    Spacer()
                }
            }
        }
    }

    
    func getPayAmountOrderedIndicesOfCategory(categoryArray: [Int64], expenseArray: [Expense]) -> [(Int64, Double)] {
        let filteredExpenseArrayArray = categoryArray.map { category in
            expenseArray.filter {
                $0.category == category
            }
        }
        
        let sumArray = filteredExpenseArrayArray.map { expenseArray in
            expenseArray.reduce(0) {
                $0 + $1.payAmount
            }
        }
        let indexedSumArray: [(Int64, Double)] = [
            (categoryArray[0], sumArray[0]),
            (categoryArray[1], sumArray[1]),
            (categoryArray[2], sumArray[2]),
            (categoryArray[3], sumArray[3]),
            (categoryArray[4], sumArray[4]),
            (categoryArray[5], sumArray[5]),
            (categoryArray[6], sumArray[6])
        ].sorted {
                $0.1 <= $1.1
            }
        return indexedSumArray
    }
    
    // 최종 배열
    private func getFilteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: expenseViewModel.selectedTravel?.id ?? UUID())
        
//        let filteredByCategory = expenseViewModel.filterExpensesByCategory(expenses: filteredByTravel, category: expenseViewModel.selectedCategory)
//        print("Filtered by category: \(filteredByCategory.count)")

        return filteredByTravel
    }
    
}

#Preview {
    AllExpenseView()
}
