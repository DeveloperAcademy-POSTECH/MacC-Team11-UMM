//
//  TodayExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
import CoreData

struct TodayExpenseDetailView: View {
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    
    var selectedTravel: Travel?
    var selectedDate: Date
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64 = -2
    @State private var currencyAndSums: [CurrencyAndSum] = []
    var sumPaymentMethod: Double
    @State private var isPaymentModalPresented = false
    @EnvironmentObject var mainVM: MainViewModel
    let exchangeRatehandler = ExchangeRateHandler.shared
    let currencyInfoModel = CurrencyInfoModel.shared.currencyResult
    let countryInfoModel = CountryInfoModel.shared.countryResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            paymentModal
            todayExpenseSummary
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    dayField
                    drawExpensesDetail
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            expenseViewModel.fetchExpense()
            expenseViewModel.fetchTravel()
            mainVM.selectedTravel = selectedTravel

            let filteredResult = getFilteredExpenses()
            expenseViewModel.filteredTodayExpenses = filteredResult
            currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredTodayExpenses)
        }
    }
    
    private var paymentModal: some View {
        Button(action: {
            isPaymentModalPresented = true
        }, label: {
            HStack(spacing: 0) {
                Text("\(PaymentMethod.titleFor(rawValue: Int(selectedPaymentMethod)))")
                    .font(.subhead2_2)
                    .foregroundStyle(.gray400)
                    .padding(.vertical, 28)
                Image("recordTravelChoiceDownChevron")
                    .font(.system(size: 9))
                    .padding(.leading, 6)
            }
        })
        .sheet(isPresented: $isPaymentModalPresented) {
            VStack(alignment: .leading, spacing: 0) {
                Text("내역 선택")
                    .font(.display1)
                ForEach([-2, 0, 1, -1], id: \.self) { idx in
                    Button(action: {
                        selectedPaymentMethod = Int64(idx)
                        expenseViewModel.filteredTodayExpenses = getFilteredExpenses()
                        currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredTodayExpenses)
                        isPaymentModalPresented = false
                    }, label: {
                        if selectedPaymentMethod == Int64(idx) {
                            HStack {
                                Text("\(PaymentMethod.titleFor(rawValue: idx))").tag(Int64(idx))
                                    .font(.subhead3_1)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image("check")
//                                    .font(.system(size: 24))
                            }
                        } else {
                            Text("\(PaymentMethod.titleFor(rawValue: idx))").tag(Int64(idx))
                                .font(.subhead3_1)
                                .foregroundStyle(.gray400)
                        }
                    })
                    .padding(.top, 28)
                }
            }
            .padding(.horizontal)
            .presentationDetents([.height(289)])
        }
    }

    private var todayExpenseSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 나라 이름
            HStack(alignment: .center, spacing: 8) {
                Image(countryInfoModel[Int(selectedCountry)]?.flagString ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .shadow(color: .gray200, radius: 2)
                Text("\(countryInfoModel[Int(selectedCountry)]?.koreanNm ?? "")")
                    .font(.display1)
            }
            
            // 총 합계
            Text("\(expenseViewModel.formatSum(from: sumPaymentMethod, to: 0))원")
                .font(.display4)
                .padding(.top, 6)
            
            // 화폐별 합계
            HStack(spacing: 0) {
                ForEach(currencyAndSums.indices, id: \.self) { idx in
                    let currencyAndSum = currencyAndSums[idx]
                    Text((Currency(rawValue: Int(currencyAndSum.currency))?.officialSymbol ?? "?") + "\(expenseViewModel.formatSum(from: currencyAndSum.sum, to: 2))")
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
    
    private var dayField: some View {
        let calculatedDay = expenseViewModel.daysBetweenTravelDates(selectedTravel: selectedTravel ?? Travel(context: expenseViewModel.viewContext), selectedDate: selectedDate)
        return HStack(alignment: .center, spacing: 0) {
            Text("Day: \(calculatedDay)")
                .font(.subhead1)
                .foregroundStyle(.gray400)
            Text("\(selectedDate, formatter: dateFormatterWithDay)")
                .font(.caption2)
                .foregroundStyle(.gray300)
                .padding(.leading, 10)
        }
        .padding(.vertical, 20)
    }
    
    // 국가별로 비용 항목을 분류하여 표시하는 함수입니다.
    private var drawExpensesDetail: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(expenseViewModel.filteredTodayExpenses, id: \.id) { expense in
                HStack(alignment: .center, spacing: 0) {
                    Image(ExpenseInfoCategory(rawValue: Int(expense.category))?.modalImageString ?? "nil")
                        .font(.system(size: 36))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(expense.info ?? "info: unknown")")
                            .font(.subhead2_1)
                        HStack(alignment: .center, spacing: 0) {
                            Text("\(dateFormatterWithHourMiniute(date: expense.payDate ?? Date()))")
                                .font(.caption2)
                                .foregroundStyle(.gray300)
                            Divider()
                                .padding(.horizontal, 3)
                            Text("\(PaymentMethod.titleFor(rawValue: Int(expense.paymentMethod)))")
                                .font(.caption2)
                                .foregroundStyle(.gray300)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.leading, 10)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(Currency(rawValue: Int(expense.currency))?.officialSymbol ?? "?")
                                .font(.subhead2_1)
                            Text("\(expenseViewModel.formatSum(from: expense.payAmount >= 0 ? expense.payAmount : Double.nan, to: 2))")
                                .font(.subhead2_1)
                                .padding(.leading, 3)
                        }
                        Text("(\(expenseViewModel.formatSum(from: expense.payAmount >= 0 ? expense.payAmount * (exchangeRatehandler.getExchangeRateFromKRW(currencyCode: currencyInfoModel[Int(expense.currency)]?.isoCodeNm ?? "-") ?? -100) : Double.nan, to: 0))원)")
                            .font(.caption2)
                            .foregroundStyle(.gray200)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(.bottom, 24)
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
