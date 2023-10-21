//
//  TodayExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
import CoreData

struct TodayExpenseDetailView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    var pickerId: String { "picker" }
    
    var selectedTravel: Travel?
    var selectedDate: Date
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64 = -1
    @State private var currencySums: [CurrencySum] = []
    
    init(selectedTab: Binding<Int>, namespace: Namespace.ID) {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
        self._selectedTab = selectedTab
        self.namespace = namespace
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                travelPicker
                Spacer()
                settingView
            }
            allExpenseTitle
            tabViewButton
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    paymentMethodPicker
                    allExpenseSummary
                    allExpenseBarGraph
                    Divider()
                    drawExpensesDetail
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            
            let filteredResult = getFilteredExpenses()
            expenseViewModel.filteredExpenses = filteredResult
            currencySums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
        }
    }
    
    private var travelPicker: some View {
        Text("travelPicker")
    }
    
    private var settingView: some View {
        Button(action: {}, label: {
            Image(systemName: "wifi")
                .font(.system(size: 16))
                .foregroundStyle(.gray300)
        })
    }
    
    private var allExpenseTitle: some View {
        HStack(spacing: 0) {
            Text("지출 관리")
                .font(.display2)
                .padding(.top, 12)
            Spacer()
        }
    }
    
    private var tabViewButton: some View {
        HStack(spacing: 0) {
            ForEach((TabbedItems.allCases), id: \.self) { item in
                ExpenseTabBarItem(selectedTab: $selectedTab, namespace: namespace, title: item.title, tab: item.rawValue)
                    .padding(.top, 8)
            }
        }
        .padding(.top, 32)
    }
    
    private var paymentMethodPicker: some View {
        Picker("현재 결제 수단", selection: $selectedPaymentMethod) {
            ForEach(-1...1, id: \.self) { index in
                Text("\(index)").tag(Int64(index))
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: selectedPaymentMethod) {
            expenseViewModel.filteredExpenses = getFilteredExpenses()
            currencySums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
        }
    }
    
    private var allExpenseSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 나라 이름
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "wifi")
                    .font(.system(size: 24))
                Text("\(Country.titleFor(rawValue: Int(selectedCountry)))")
                    .font(.display1)
                    .padding(.leading, 8)
            }
            
            // 총 합계
            Text("\(expenseViewModel.formatSum(currencyAndSums.reduce(0) { $0 + $1.sum }, 0))원")
                .font(.display4)
                .padding(.top, 6)
            
            // 화폐별 합계
            HStack(spacing: 0) {
                ForEach(currencyAndSums.indices, id: \.self) { idx in
                    let currencySum = currencyAndSums[idx]
                    Text("\(currencySum.currency): \(expenseViewModel.formatSum(currencySum.sum, 2))")
                        .font(.caption2)
                        .foregroundStyle(.gray300)
                    if idx != currencyAndSums.count - 1 {
                        Circle()
                            .frame(width: 3, height: 3)
                            .foregroundStyle(.gray300)
                            .padding(.horizontal, 3)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }
    
    
    
    // 국가별로 비용 항목을 분류하여 표시하는 함수입니다.
    private var drawExpensesDetail: some View {
        VStack {
            ForEach(currencySums, id: \.currency) { currencySum in
                Text("\(currencySum.currency): \(currencySum.sum)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
            }
            ForEach(expenseViewModel.filteredExpenses, id: \.id) { expense in
                VStack {
                    Text(expense.description)
                }.padding()
            }
        }
    }
    
    // 최종 배열
    private func getFilteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel?.id ?? UUID())
        print("Filtered by travel: \(filteredByTravel.count)")
        
        let filteredByDate = expenseViewModel.filterExpensesByDate(expenses: filteredByTravel, selectedDate: selectedDate)
        print("Filtered by date: \(filteredByDate.count)")
        
        let filteredByCountry = expenseViewModel.filterExpensesByCountry(expenses: filteredByDate, country: selectedCountry)
        print("Filtered by Country: \(filteredByCountry.count)")
        
        if selectedPaymentMethod == -2 {
            return filteredByCountry
        } else {
            let filterByPaymentMethod = expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredByCountry, paymentMethod: selectedPaymentMethod)
            return filterByPaymentMethod
        }
    }
}
//  #Preview {
//      TodayExpenseDetailView()
//  }
