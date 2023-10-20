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
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    
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
            todayExpenseHeader
            tabViewButton
            datePicker
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    drawExpensesByCategory
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = findCurrentTravel()
            
            expenseViewModel.filteredExpenses = expenseViewModel.getFilteredExpenses()
        }
    }
    
    // MARK: - 뷰
    private var travelChoiceView: some View {
        Button {
            expenseViewModel.travelChoiceHalfModalIsShown = true
            print("expenseViewModel.travelChoiceHalfModalIsShown = true")
        } label: {
            ZStack {
                Capsule()
                    .foregroundStyle(.white)
                    .layoutPriority(-1)
                
                Capsule()
                    .strokeBorder(.mainPink, lineWidth: 1.0)
                    .layoutPriority(-1)
                
                HStack(spacing: 12) {
                    Text(expenseViewModel.selectedTravel?.name != "Default" ? expenseViewModel.selectedTravel?.name ?? "-" : "-")
                        .font(.subhead2_2)
                        .foregroundStyle(.black)
                    Image("recordTravelChoiceDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .padding(.vertical, 6)
                .padding(.leading, 16)
                .padding(.trailing, 12)
            }
        }
        .padding(.top, 80)
    }
    
    private var travelPicker: some View {
        Picker("현재 여행", selection: $expenseViewModel.selectedTravel) {
            ForEach(dummyRecordViewModel.savedTravels, id: \.self) { travel in
                Text(travel.name ?? "no name").tag(travel as Travel?) // travel의 id가 선택지로
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onReceive(expenseViewModel.$selectedTravel) { _ in
            DispatchQueue.main.async {
                expenseViewModel.filteredExpenses = expenseViewModel.getFilteredExpenses()
                expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
            }
        }
    }
    
    private var countryPicker: some View {
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
    }
    
    private var settingView: some View {
        Button(action: {}, label: {
            Image(systemName: "wifi")
                .font(.system(size: 16))
                .foregroundStyle(.gray300)
        })
    }
    
    private var todayExpenseHeader: some View {
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
    
    private var datePicker: some View {
        DatePicker("날짜", selection: $expenseViewModel.selectedDate, displayedComponents: [.date])
            .onReceive(expenseViewModel.$selectedDate) { _ in
                DispatchQueue.main.async {
                    expenseViewModel.filteredExpenses = expenseViewModel.getFilteredExpenses()
                    expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 20)
    }
    
    // 1. 나라별
    // 1-1. 항목별
    private var drawExpensesByCategory: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedExpenses.keys)).sorted { $0 < $1 }
        return ForEach(countryArray, id: \.self) { country in
            VStack {
                if country == expenseViewModel.selectedCountry {
                    let categoryArray = [Int64]([-1, 0, 1, 2, 3, 4, 5])
                    let expenseArray = expenseViewModel.filteredExpenses.filter { $0.country == country }
                    let totalSum = expenseArray.reduce(0) { $0 + $1.payAmount } // 모든 결제 수단 합계
                    let indexedSumArrayInPayAmountOrder = getPayAmountOrderedIndicesOfCategory(categoryArray: categoryArray, expenseArray: expenseArray)
                    let currencies = Array(Set(expenseArray.map { $0.currency })).sorted { $0 < $1 }
                    
                    VStack {
                        Text("나라 이름: \(country)")
                        Text("전체 금액 합: \(totalSum)")
                        Text("categoryArray.count: \(categoryArray.count)")
                        Text("countryArray.count: \(countryArray.count)")
                    }
                    // 전체 기록 화폐 단위
                    ForEach(currencies, id: \.self) { currency in
                        let sum = expenseArray.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount } // 결제 수단 별로 합계
                        Text("\(currency): \(sum)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                    }
                    
                    ForEach(0..<categoryArray.count, id: \.self) { index in
                        NavigationLink {
                            AllExpenseDetailView(
                                selectedTravel: expenseViewModel.selectedTravel,
                                selectedCategory: indexedSumArrayInPayAmountOrder[index].0,
                                selectedCountry: country,
                                selectedPaymentMethod: -2
                            )
                        } label: {
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
    }
    
    private func getPayAmountOrderedIndicesOfCategory(categoryArray: [Int64], expenseArray: [Expense]) -> [(Int64, Double)] {
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
        
        return filteredByTravel
    }
    
}

//  #Preview {
//      AllExpenseView(selectedTab: .constant(1), namespace: Namespace.ID)
//  }
