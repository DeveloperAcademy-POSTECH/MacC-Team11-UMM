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
            allExpenseTitle
            tabViewButton
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    countryPicker
                    allExpenseSummary
                    allExpenseBarGraph
                    Divider()
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
            
            expenseViewModel.filteredExpenses = getFilteredExpenses()
            expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
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
                expenseViewModel.filteredExpenses = getFilteredExpenses()
                expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
                print("travelPicker | expenseViewModel.selectedCountry: \(expenseViewModel.selectedCountry)")
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
    
    private var countryPicker: some View {
        let allExpensesInSelectedTravel = expenseViewModel.filteredExpenses
        let countries = [-2] + Array(Set(allExpensesInSelectedTravel.compactMap { $0.country })).sorted { $0 < $1 } // 중복 제거
        
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(countries, id: \.self) { country in
                    Button(action: {
                        DispatchQueue.main.async {
                            expenseViewModel.selectedCountry = Int64(country)
                            expenseViewModel.filteredExpenses = getFilteredExpenses()
                            expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.category })
                            print("countryPicker | expenseViewModel.groupedExpenses: \(expenseViewModel.groupedExpenses.count)")
                        }
                    }) {
                        Text("Country: \(country)")
                            .padding()
                            .background(expenseViewModel.selectedCountry == country ? Color.blue : Color.clear)
                            .foregroundColor(expenseViewModel.selectedCountry == country ? Color.white : Color.black)
                    }
                }
            }
        }
    }
    
    private var allExpenseSummary: some View {
        Text("allExpenseSummary")
    }
    
    private var allExpenseBarGraph: some View {
        Text("allExpenseBarGraph")
    }
    
    private func getExpenseArray(for country: Int64) -> [Expense] {
        if country == expenseViewModel.selectedCountry {
            return expenseViewModel.filteredExpenses.filter { $0.country == country }
        } else {
            return expenseViewModel.filteredExpenses
        }
    }
    
    private var drawExpensesByCategory: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedExpenses.keys)).sorted { $0 < $1 }

        // selectedCountry가 -2인 경우 전체 지출을 한 번만 그림
        if expenseViewModel.selectedCountry == -2 {
            let expenseArray = expenseViewModel.filteredExpenses
            return AnyView(drawExpenseContent(for: -2, with: expenseArray))
        } else {
            // selectedCountry가 특정 국가인 경우 해당 국가의 지출을 그림
            return AnyView(ForEach(countryArray, id: \.self) { country in
                VStack {
                    let expenseArray = getExpenseArray(for: country)
                    if country == expenseViewModel.selectedCountry {
                        drawExpenseContent(for: country, with: expenseArray)
                    }
                }
            })
        }
    }
    
    // 1. 나라별
    // 1-1. 항목별
    private func drawExpenseContent(for country: Int64, with expenses: [Expense]) -> some View {
        let categoryArray = [Int64]([-1, 0, 1, 2, 7, 4, 5])
        let totalSum = expenses.reduce(0) { $0 + $1.payAmount } // 모든 결제 수단 합계
        let indexedSumArrayInPayAmountOrder = getPayAmountOrderedIndicesOfCategory(categoryArray: categoryArray,
                                                                                   expenseArray: expenses)
        let currencies = Array(Set(expenses.map { $0.currency })).sorted { $0 < $1 }
        
        return VStack {
            Text("나라 이름 : \(country)")
            Text("전체 금액 합 : \(totalSum)")
            
            ForEach(currencies, id:\.self) { currency in
                let sum = expenses.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount } // 결제 수단 별로 합계
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
    
    // 최종 배열
    private func getFilteredExpenses() -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: expenseViewModel.selectedTravel?.id ?? UUID())
        
        return filteredByTravel
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

//  #Preview {
//      AllExpenseView(selectedTab: .constant(1), namespace: Namespace.ID)
//  }
