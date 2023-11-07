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
    @EnvironmentObject var mainVM: MainViewModel
    let exchangeRateHandler = ExchangeRateHandler.shared
    let currencyInfoModel = CurrencyInfoModel.shared.currencyResult
    let countryInfoModel = CountryInfoModel.shared.countryResult
    let dateGapHandler = DateGapHandler.shared
    
    init(expenseViewModel: ExpenseViewModel, selectedTab: Binding<Int>, namespace: Namespace.ID) {
        self.expenseViewModel = expenseViewModel
        self._selectedTab = selectedTab
        self.namespace = namespace
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if expenseViewModel.filteredTodayExpenses.count == 0 {
                HStack {
                    datePicker
                    Spacer()
                }
                noDataView
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
        VStack {
            // DatePicker에서 여행의 startDate를 보여줄 때는 저장된 데이터를 covertBeforeShowing한다.
            // selectedTravel이 nil이면 현지 시간인 Date()를 변환해서 보여주면 안 된다. 따라서 Date()를 한국 시간으로 변환한 뒤에, 다시 현지 시간으로 변환되게 해야 한다.
            CustomDatePicker(
                expenseViewModel: expenseViewModel, 
                selectedDate: $expenseViewModel.selectedDate,
                pickerId: pickerId,
                startDateOfTravel: dateGapHandler.convertBeforeShowing(date: mainVM.selectedTravel?.startDate ?? dateGapHandler.convertBeforeSaving(date: Date().addingTimeInterval(-24*60*60))))
        }
//        .padding(.top, 4) // ^^^
        .padding(.bottom, 12)
    }
    
    // 국가별 + 결제수단별 지출액 표시
    var drawExpensesByCountry: some View {
        let countryArray = [Int64](Set<Int64>(expenseViewModel.groupedTodayExpenses.keys)).sorted { $0 < $1 }

        return ForEach(countryArray, id: \.self) { country in
            let paymentMethodArray = Array(Set((expenseViewModel.groupedTodayExpenses[country] ?? []).map { $0.paymentMethod })).sorted { $0 < $1 }
            let expenseArray = expenseViewModel.groupedTodayExpenses[country] ?? []
            let currencies = Array(Set(expenseArray.map { $0.currency })).sorted { $0 < $1 }
            let totalSum = currencies.reduce(0) { total, currency in
                let sum = expenseArray.filter({ $0.currency == currency }).reduce(0) { $0 + ($1.payAmount == -1 ? 0 : $1.payAmount) }
                let isoCodeName = currencyInfoModel[Int(currency)]?.isoCodeNm ?? "Unknown"
                let rate = exchangeRateHandler.getExchangeRateFromKRW(currencyCode: isoCodeName)
                return total + sum * (rate ?? -100)
            }

            VStack(alignment: .leading, spacing: 0) {
                // 국기 + 국가명
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Image(countryInfoModel[Int(country)]?.flagString ?? "")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .shadow(color: Color.gray200, radius: 2)
                            .padding(.leading, 2)
                        Text(countryInfoModel[Int(country)]?.koreanNm ?? "")
                            .foregroundStyle(.black)
                            .font(.subhead3_1)
                    }

                    // 결제 수단: 전체: 합계
                    NavigationLink {
                        TodayExpenseDetailView(
                            selectedTravel: mainVM.selectedTravel,
                            selectedDate: expenseViewModel.selectedDate,
                            selectedCountry: country,
                            selectedPaymentMethod: -2,
                            sumPaymentMethod: totalSum
                        )
                        .environmentObject(mainVM)
                    } label: {
                        HStack(spacing: 0) {
                            Text("\(expenseViewModel.formatSum(from: totalSum, to: 0))원")
                                .font(.display3)
                                .foregroundStyle(.black)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 24))
                                .foregroundStyle(.gray200)
                                .padding(.leading, 16)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 16)

                // 결제 수단: 개별: 합계
                ForEach(paymentMethodArray, id: \.self) { paymentMethod in
                    let filteredExpenseArray = expenseArray.filter { $0.paymentMethod == paymentMethod }
                    let currencies = Array(Set(filteredExpenseArray.map { $0.currency })).sorted { $0 < $1 }
                    let totalSum = currencies.reduce(0) { total, currency in
                        let sum = filteredExpenseArray.filter({ $0.currency == currency }).reduce(0) { $0 + ($1.payAmount == -1 ? 0 : $1.payAmount) }
                        let isoCodeName = currencyInfoModel[Int(currency)]?.isoCodeNm ?? "Unknown"
                        let rate = exchangeRateHandler.getExchangeRateFromKRW(currencyCode: isoCodeName)
                        return total + sum * (rate ?? -100)
                    }

                    NavigationLink {
                        TodayExpenseDetailView(
                            selectedTravel: mainVM.selectedTravel,
                            selectedDate: expenseViewModel.selectedDate,
                            selectedCountry: country,
                            selectedPaymentMethod: paymentMethod,
                            sumPaymentMethod: totalSum
                        )
                        .environmentObject(mainVM)
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
                                        let symbol = currencyInfoModel[Int(currency)]?.symbol ?? "-"
                                        let formattedSum = expenseViewModel.formatSum(from: sum, to: 2)
                                        Text("\(symbol) \(formattedSum)")
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
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16))
                                .foregroundStyle(.gray200)
                                .padding(.trailing, 16)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 10)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
    } // draw

    private var noDataView: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                Text("아직 지출 기록이 없어요")
                    .font(.subhead3_2)
                    .foregroundStyle(.gray300)
                    .padding(.top, 130)
                Spacer()
            }
            Spacer()
        }
    }
}

struct CurrencyAndSum {
    let currency: Int64
    let sum: Double
}
