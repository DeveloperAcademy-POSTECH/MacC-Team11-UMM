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
    let handler = ExchangeRateHandler.shared
    
    init(expenseViewModel: ExpenseViewModel, selectedTab: Binding<Int>, namespace: Namespace.ID) {
        self.expenseViewModel = expenseViewModel
        self._selectedTab = selectedTab
        self.namespace = namespace
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if expenseViewModel.filteredTodayExpenses.count == 0 {
                noDataVIew
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        datePicker
                        drawExpensesByCountry // 결제 데이터 그리기: 국가 > 결제수단 순서로 분류
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            expenseViewModel.fetchExpense()
            expenseViewModel.fetchTravel()
            
            expenseViewModel.filteredTodayExpenses = expenseViewModel.getFilteredTodayExpenses()
            expenseViewModel.groupedTodayExpenses = Dictionary(grouping: expenseViewModel.filteredTodayExpenses, by: { $0.country })
        }
    }
    
    private var datePicker: some View {
        CustomDatePicker(expenseViewModel: expenseViewModel, selectedDate: $expenseViewModel.selectedDate, pickerId: pickerId, startDateOfTravel: expenseViewModel.selectedTravel?.startDate ?? Date().addingTimeInterval(-24*60*60))
            .padding(.top, 12)
            .padding(.bottom, 12)
    }
    
    // 국가별 + 결제수단별 지출액 표시
    private var drawExpensesByCountry: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedTodayExpenses.keys)).sorted { $0 < $1 }
        
        return ForEach(countryArray, id: \.self) { country in
                let paymentMethodArray = Array(Set((expenseViewModel.groupedTodayExpenses[country] ?? []).map { $0.paymentMethod })).sorted { $0 < $1 }
                let expenseArray = expenseViewModel.groupedTodayExpenses[country] ?? []
                let currencies = Array(Set(expenseArray.map { $0.currency })).sorted { $0 < $1 }
                let totalSum = currencies.reduce(0) { total, currency in
                    let sum = expenseArray.filter({ $0.currency == currency }).reduce(0) { $0 + ($1.payAmount == -1 ? 0 : $1.payAmount) }
                    let rate = handler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int(currency)))
                    return total + sum * (rate ?? -100)
                }
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
                            Text("\(expenseViewModel.formatSum(from: totalSum, to: 0))원")
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
                            let sumPaymentMethod = filteredExpenseArray.reduce(0) { $0 + ($1.payAmount == -1 ? 0 : $1.payAmount) }
                            
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
                                                let sum = filteredExpenseArray.filter({ $0.currency == currency }).reduce(0) { $0 + ($1.payAmount == -1 ? 0 : $1.payAmount) }
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
    
    private var noDataVIew: some View {
        VStack(spacing: 0) {
            Text("아직 지출 기록이 없어요")
                .font(.subhead3_2)
                .foregroundStyle(.gray300)
                .padding(.top, 130)
            Spacer()
        }
    }
}

struct CurrencyAndSum {
    let currency: Int64
    let sum: Double
}
