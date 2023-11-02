//
//  AllExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @State private var selectedPaymentMethod: Int = -2
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    let handler = ExchangeRateHandler.shared
    
    init(expenseViewModel: ExpenseViewModel, selectedTab: Binding<Int>, namespace: Namespace.ID) {
        self.expenseViewModel = expenseViewModel
        self._selectedTab = selectedTab
        self.namespace = namespace
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            tabViewButton
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    countryPicker
                    drawExpensesByCategory
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            expenseViewModel.fetchExpense()
            expenseViewModel.fetchTravel()
            print("AllExpenseView | expenseViewModel.selectedTravel: \(String(describing: expenseViewModel.selectedTravel))")
            
            expenseViewModel.filteredAllExpenses = expenseViewModel.getFilteredAllExpenses()
            expenseViewModel.groupedAllExpenses = Dictionary(grouping: expenseViewModel.filteredAllExpenses, by: { $0.category })
        }
        .sheet(isPresented: $expenseViewModel.travelChoiceHalfModalIsShown) {
            TravelChoiceModalBinding(selectedTravel: $expenseViewModel.selectedTravel)
                .presentationDetents([.height(289 - 34)])
        }
    }
    
    // MARK: - 뷰
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
        let allExpensesInSelectedTravel = expenseViewModel.filteredAllExpenses
        let countries = [-2] + Array(Set(allExpensesInSelectedTravel.compactMap { $0.country })).sorted { $0 < $1 } // 중복 제거
        
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(countries, id: \.self) { country in
                    Button(action: {
                        DispatchQueue.main.async {
                            expenseViewModel.selectedCountry = Int64(country)
                            expenseViewModel.filteredAllExpenses = expenseViewModel.getFilteredAllExpenses()
                            expenseViewModel.groupedAllExpenses = Dictionary(grouping: expenseViewModel.filteredAllExpenses, by: { $0.category })
                        }
                    }, label: {
                        Text("\(Country.titleFor(rawValue: Int(country)))")
                            .padding(.leading, 4)
                            .font(.caption2)
                            .frame(width: 61) // 폰트 개수가 다르고, 크기는 고정되어 있어서 상수 값을 주었습니다.
                            .padding(.vertical, 7)
                            .background(expenseViewModel.selectedCountry == country ? Color.black: Color.white)
                            .foregroundColor(expenseViewModel.selectedCountry == country ? Color.white: Color.gray300)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray200, lineWidth: 2)
                            )
                    })
                }
            }
            .padding(.top, 16)
        }
    }
    
    private func getExpenseArray(for country: Int64) -> [Expense] {
        if country == expenseViewModel.selectedCountry {
            return expenseViewModel.filteredAllExpenses.filter { $0.country == country }
        } else {
            return expenseViewModel.filteredAllExpenses
        }
    }
    
    private var drawExpensesByCategory: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedAllExpenses.keys)).sorted { $0 < $1 }
        
        // selectedCountry가 -2인 경우 전체 지출을 한 번만 그림
        if expenseViewModel.selectedCountry == -2 {
            let expenseArray = expenseViewModel.filteredAllExpenses
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
        let categoryArray = [Int64]([-1, 0, 1, 2, 3, 4, 5])
        let indexedSumArrayInPayAmountOrder = getPayAmountOrderedIndicesOfCategory(categoryArray: categoryArray, expenseArray: expenses)
        let currencies = Array(Set(expenses.map { $0.currency })).sorted { $0 < $1 }
        let totalSum = currencies.reduce(0) { total, currency in
            let sum = expenses.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount }
            let rate = handler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int(currency)))
            return total + sum * (rate ?? -1)
        }
        
        // allExpenseSummary: 총합
        return VStack(alignment: .leading, spacing: 0) {
            NavigationLink {
                AllExpenseDetailView(
                    selectedTravel: expenseViewModel.selectedTravel,
                    selectedCategory: -2,
                    selectedCountry: expenseViewModel.selectedCountry,
                    selectedPaymentMethod: -2
                )
            } label: {
                HStack(spacing: 0) {
                    Text("\(expenseViewModel.formatSum(from: totalSum, to: 0))원")
                        .font(.display4)
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 24))
                        .foregroundStyle(.gray200)
                        .padding(.leading, 16)
                }
                .padding(.top, 32)
            }
            
            // allExpenseSummary: 화폐별
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(currencies.indices, id: \.self) { idx in
                        let currency = currencies[idx]
                        let sum = expenses.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount } // 결제 수단 별로 합계
                        
                        Text("\(Currency.getSymbol(of: Int(currency)))\(expenseViewModel.formatSum(from: sum, to: 2))")
                            .font(.caption2)
                            .foregroundStyle(.gray300)
                        if idx != currencies.count - 1 {
                            Circle()
                                .frame(width: 3, height: 3)
                                .foregroundStyle(.gray300)
                                .padding(.horizontal, 3)
                        }
                    }
                }
                .padding(.top, 10)
            }
            
            // allExpenseBarGraph
            BarGraph(data: indexedSumArrayInPayAmountOrder)
                .padding(.top, 22)
            
            Divider()
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<categoryArray.count, id: \.self) { index in
                    let categoryName = indexedSumArrayInPayAmountOrder[index].0
                    let categorySum = indexedSumArrayInPayAmountOrder[index].1
                    let totalSum = indexedSumArrayInPayAmountOrder.map { $0.1 }.reduce(0, +)
                    
                    NavigationLink {
                        AllExpenseDetailView(
                            selectedTravel: expenseViewModel.selectedTravel,
                            selectedCategory: indexedSumArrayInPayAmountOrder[index].0,
                            selectedCountry: expenseViewModel.selectedCountry,
                            selectedPaymentMethod: -2
                        )
                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            Image(ExpenseInfoCategory(rawValue: Int(categoryName))?.modalImageString ?? "nil")
                                .font(.system(size: 36))
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(ExpenseInfoCategory.descriptionFor(rawValue: Int(categoryName)))")
                                    .font(.subhead2_1)
                                    .foregroundStyle(.black)
                                HStack(alignment: .center, spacing: 0) {
                                    Text("\(expenseViewModel.formatSum(from: categorySum / totalSum * 100, to: 1))%")
                                        .font(.caption2)
                                        .foregroundStyle(.gray300)
                                }
                                .padding(.top, 4)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 0) {
                                Text("\(expenseViewModel.formatSum(from: categorySum, to: 0))원")
                                    .font(.subhead3_1)
                                    .foregroundStyle(.black)
                                    .padding(.leading, 3)
                                    .padding(.trailing, 12)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.gray300)
                                
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.bottom, 24)
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
                $0 + ( $1.payAmount * (handler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int($1.currency))) ?? -1))
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
            $0.1 >= $1.1
        }
        return indexedSumArray
    }
}

struct CurrencyForChart: Identifiable, Hashable {
    let id = UUID()
    let currency: Int64
    let sum: Double
    
    init(currency: Int64, sum: Double) {
        self.currency = currency
        self.sum = sum
    }
}

struct ExpenseForChart: Identifiable, Hashable {
    let id = UUID()
    let name: Int64
    let value: Double
    
    init(_ tuple: (Int64, Double)) {
        self.name = tuple.0
        self.value = tuple.1
    }
}

struct BarGraph: View {
    var data: [(Int64, Double)]
    
    private var totalSum: Double {
        return data.map { $0.1 }.reduce(0, +)
    }
    
    private var validDataCount: Int {
        return data.filter { $0.1 != 0 }.count
    }
    
    var body: some View {
        let totalWidth = UIScreen.main.bounds.size.width - 40
        let dataSize = data.count
        
        HStack(spacing: 0) {
            ForEach(0..<dataSize, id: \.self) { index in
                let item = data[index]
                BarElement(
                    color: ExpenseInfoCategory(rawValue: Int(item.0))?.color ?? Color.gray,
                    width: (CGFloat(item.1 / totalSum) * totalWidth),
                    isFirstElement: index == 0,
                    isLastElement: index == validDataCount - 1
                )
            }
        }
    }
}

struct BarElement: View {
    
    let color: Color
    let width: CGFloat
    let isFirstElement: Bool
    let isLastElement: Bool
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: max(0, width), height: 24)
            .modifier(RoundedModifier(isFirstElement: isFirstElement, isLastElement: isLastElement))
            .padding(.trailing, 2)
    }
}

struct RoundedModifier: ViewModifier {
    let isFirstElement: Bool
    let isLastElement: Bool
    
    func body(content: Content) -> some View {
        if isFirstElement && isLastElement {
            return AnyView(content.cornerRadius(6))
        } else if isFirstElement {
            return AnyView(content.cornerRadius(6, corners: [.topLeft, .bottomLeft]))
        } else if isLastElement {
            return AnyView(content.cornerRadius(6, corners: [.topRight, .bottomRight]))
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//  #Preview {
//      AllExpenseView(selectedTab: .constant(1), namespace: Namespace.ID)
//  }
