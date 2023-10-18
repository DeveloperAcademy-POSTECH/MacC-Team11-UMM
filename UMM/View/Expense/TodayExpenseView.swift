//
//  TodayExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct TodayExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
    
    init() {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("일별 지출")
                
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
                        expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
                        print("TodayExpenseView | onReceive | done")
                    }
                }
                
                // Picker: 날짜별
                DatePicker("날짜", selection: $expenseViewModel.selectedDate, displayedComponents: [.date])
                    .onReceive(expenseViewModel.$selectedDate) { _ in
                        DispatchQueue.main.async {
                            expenseViewModel.filteredExpenses = getFilteredExpenses()
                            expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
                        }
                    }
                
                Button {
                    expenseViewModel.addExpense(travel: expenseViewModel.selectedTravel ?? Travel(context: dummyRecordViewModel.viewContext))
                    DispatchQueue.main.async {
                        expenseViewModel.filteredExpenses = getFilteredExpenses()
                        expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
                    }
                } label: {
                    Text("지출 추가")
                }
                
                Spacer()
                
                drawExpensesByCountry
            }
        }
        .onAppear {
            print("TodayExpenseView Appeared")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            
            expenseViewModel.filteredExpenses = getFilteredExpenses()
            expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
        }
    }
    
    // 국가별 + 결제수단별 지출액 표시
    private var drawExpensesByCountry: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedExpenses.keys)).sorted { $0 < $1 }
        
        return ForEach(countryArray, id: \.self) { country in
            let expenseArray = expenseViewModel.groupedExpenses[country] ?? []
            let paymentMethodArray = Array(Set((expenseViewModel.groupedExpenses[country] ?? []).map { $0.paymentMethod })).sorted { $0 < $1 }
            let totalSum = expenseArray.reduce(0) { $0 + $1.payAmount }
            VStack {
                Text("나라: \(country)").font(.title3)
                NavigationLink {
                    TodayExpenseDetailView (
                        selectedTravel: expenseViewModel.selectedTravel,
                        selectedDate: expenseViewModel.selectedDate,
                        selectedCountry: country,
                        selectedPaymentMethod: -2 // paymentMethod와 상관 없이 모든 expense를 보여주기 위해 임의 값을 설정
                    )
                } label: {
                    VStack {
                        Text("결제 수단: all")
                        Text("금액 합: \(totalSum)")
                    }
                }
            }
            
            ForEach(paymentMethodArray, id: \.self) { paymentMethod in
                let filteredExpenseArray = expenseArray.filter { $0.paymentMethod == paymentMethod }
                let sum = filteredExpenseArray.reduce(0) { $0 + $1.payAmount }
                NavigationLink {
                    TodayExpenseDetailView(
                        selectedTravel: expenseViewModel.selectedTravel,
                        selectedDate: expenseViewModel.selectedDate,
                        selectedCountry: country,
                        selectedPaymentMethod: paymentMethod
                    )
                } label: {
                    VStack {
                        Text("결제 수단: \(paymentMethod)")
                        Text("금액 합: \(sum)")
                    }
                }
                Spacer()
            }
        }
    }
    
    private func getFilteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: expenseViewModel.selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
                
        let filteredByDate = expenseViewModel.filterExpensesByDate(expenses: filteredByTravel, selectedDate: expenseViewModel.selectedDate)
        print("Filtered by date: \(filteredByDate.count)")
        
        return filteredByDate
    }
    
}

#Preview {
    TodayExpenseView()
}
