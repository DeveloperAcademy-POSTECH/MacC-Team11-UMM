//
//  TodayExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct TodayExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    var pickerId: String { "picker" }
    
    init(expenseViewModel: ExpenseViewModel, selectedTab: Binding<Int>, namespace: Namespace.ID) {
        self.expenseViewModel = expenseViewModel
        self._selectedTab = selectedTab
        self.namespace = namespace
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            tabViewButton
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    datePicker
                    drawExpensesByCountry // 결제 데이터 그리기: 국가 > 결제수단 순서로 분류
                    // dummyExpenseAddButton
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            expenseViewModel.fetchExpense()
            expenseViewModel.fetchTravel()
//            expenseViewModel.selectedTravel = findCurrentTravel()
            print("TodayExpenseView | expenseViewModel.selectedTravel: \(String(describing: expenseViewModel.selectedTravel))")
            
            expenseViewModel.filteredTodayExpenses = expenseViewModel.getFilteredTodayExpenses()
            expenseViewModel.groupedTodayExpenses = Dictionary(grouping: expenseViewModel.filteredTodayExpenses, by: { $0.country })
        }
        .sheet(isPresented: $expenseViewModel.travelChoiceHalfModalIsShown) {
            TravelChoiceModalBinding(selectedTravel: $expenseViewModel.selectedTravel)
                .presentationDetents([.height(289 - 34)])
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
        CustomDatePicker(expenseViewModel: expenseViewModel, selectedDate: $expenseViewModel.selectedDate, pickerId: pickerId)
            .padding(.top, 12)
            .padding(.bottom, 12)
    }
    
    // 국가별 + 결제수단별 지출액 표시
    private var drawExpensesByCountry: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedTodayExpenses.keys)).sorted { $0 < $1 }
        return ForEach(countryArray, id: \.self) { country in
            let paymentMethodArray = Array(Set((expenseViewModel.groupedTodayExpenses[country] ?? []).map { $0.paymentMethod })).sorted { $0 < $1 }
            let expenseArray = expenseViewModel.groupedTodayExpenses[country] ?? []
            let totalSum = expenseArray.reduce(0) { $0 + $1.payAmount }
            let currencies = Array(Set(expenseArray.map { $0.currency })).sorted { $0 < $1 }
            
            VStack(alignment: .leading, spacing: 0) {
                // 국기 + 국가명
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Spacer()
                            .frame(width: 4) // 디자이너 몰래 살짝 움직였다
                        Image(Country(rawValue: Int(country))?.flagImageString ?? "")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .shadow(color: .gray, radius: 3)
                        Text(Country(rawValue: Int(country))?.title ?? "-")
                            .foregroundStyle(.black)
                            .font(.subhead3_1)
                    }
                    
                    // 결제 수단: 전체: 합계
                    NavigationLink {
                        TodayExpenseDetailView(
                            selectedTravel: expenseViewModel.selectedTravel,
                            selectedDate: expenseViewModel.selectedDate,
                            selectedCountry: country,
                            selectedPaymentMethod: -2,
                            sumPaymentMethod: totalSum
                        )
                    } label: {
                        Text("\(expenseViewModel.formatSum(from: totalSum, to: 2))원")
                            .font(.display3)
                            .foregroundStyle(.black)
                            .padding(.top, 8)
                    }
                }
                .padding(.bottom, 16)
                
                // 결제 수단: 개별: 합계
                ForEach(paymentMethodArray, id: \.self) { paymentMethod in
                    VStack(alignment: .leading, spacing: 0) {
                        let filteredExpenseArray = expenseArray.filter { $0.paymentMethod == paymentMethod }
                         let sumPaymentMethod = filteredExpenseArray.reduce(0) { $0 + $1.payAmount }
                        
                        NavigationLink {
                            TodayExpenseDetailView(
                                selectedTravel: expenseViewModel.selectedTravel,
                                selectedDate: expenseViewModel.selectedDate,
                                selectedCountry: country,
                                selectedPaymentMethod: paymentMethod,
                                sumPaymentMethod: sumPaymentMethod
                            )
                        } label: {
                            HStack(alignment: .center, spacing: 0) {
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 0) {
                                        Text(PaymentMethod(rawValue: Int(paymentMethod))?.title ?? "-")
                                            .font(.subhead2_1)
                                            .foregroundStyle(.gray300)
                                    }
                                    // 결제 수단: 개별, 화폐: 개별: 합계
                                    HStack(spacing: 0) {
                                        ForEach(currencies.indices, id: \.self) { index in
                                            let currency = currencies[index]
                                            let sum = filteredExpenseArray.filter({ $0.currency == currency }).reduce(0) { $0 + $1.payAmount }
                                            
                                            Text((Currency(rawValue: Int(currency))?.officialSymbol ?? "?") + "\(expenseViewModel.formatSum(from: sum, to: 2))")
                                                .font(.subhead3_1)
                                                .foregroundStyle(.black)
                                            
                                            if index != currencies.count - 1 {
                                                Divider()
                                                    .font(.subhead2_1)
                                                    .foregroundStyle(.gray200)
                                                    .padding(.horizontal, 5)
                                            }
                                        }
                                    }
                                    .padding(.top, 12)
                                }
                                Spacer()
                                
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray100)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
        }
    } // draw
}

struct CurrencyAndSum {
    let currency: Int64
    let sum: Double
}
