//
//  AllExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseDetailView: View {
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    
    var selectedTravel: Travel?
    var selectedCategory: Int64
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64
    @State private var currencyAndSums: [CurrencyAndSum] = []
    @State private var isPaymentModalPresented = false
    let exchangeRatehandler = ExchangeRateHandler.shared
    var sumPaymentMethod: Double
    let currencyInfoModel = CurrencyInfoModel.shared.currencyResult

    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            paymentModal
            allExpenseSummary
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    drawExpensesDetail
                }
            }
        }

        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            expenseViewModel.fetchExpense()
            expenseViewModel.fetchTravel()
            expenseViewModel.filteredAllExpenses = getFilteredExpenses()
            currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredAllExpenses)
            
            print("AllExpenseDetailView | selectedTravel: \(String(describing: selectedTravel?.name))")
            print("AllExpenseDetailView | selectedCountry: \(selectedCountry)")
            print("AllExpenseDetailView | expenseViewModel.selectedTravel : \(String(describing: expenseViewModel.selectedTravel?.name))")
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
                        expenseViewModel.filteredAllExpenses = getFilteredExpenses()
                        currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredAllExpenses)
                        isPaymentModalPresented = false
                    }, label: {
                        if selectedPaymentMethod == Int64(idx) {
                            HStack {
                                Text("\(PaymentMethod.titleFor(rawValue: idx))").tag(Int64(idx))
                                    .font(.subhead3_1)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image("check")
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
    
    private var allExpenseSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            //  카테고리 이름
            if selectedCategory != -2 {
                HStack(alignment: .center, spacing: 0) {
                    Image(ExpenseInfoCategory(rawValue: Int(selectedCategory))?.modalImageString ?? "nil")
                        .font(.system(size: 24))
                    Text("\(ExpenseInfoCategory.descriptionFor(rawValue: Int(selectedCategory)))")
                        .font(.display1)
                        .padding(.leading, 8)
                }
            } else {
                HStack(alignment: .center, spacing: 0) {
                    Text("총 지출")
                        .font(.display1)
                }
            }
            
            // 총 합계
            let totalSum = currencyAndSums.reduce(0) {
                let exchangeRate = exchangeRatehandler.getExchangeRateFromKRW(currencyCode: currencyInfoModel[Int($1.currency)]?.isoCodeNm ?? "Unknown")
                let sum = $1.sum == -1 ? 0 : $1.sum
                return $0 + sum * (exchangeRate ?? -100)
            }
            let formattedSum = expenseViewModel.formatSum(from: totalSum, to: 0)
            Text("\(formattedSum)원")
                .font(.display4)
                .padding(.top, 6)
            
            // 화폐별 합계
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(currencyAndSums.indices, id: \.self) { idx in
                        let currencyAndSum = currencyAndSums[idx]
                        Text("\(Currency.getSymbol(of: Int(currencyAndSum.currency)))\(expenseViewModel.formatSum(from: currencyAndSum.sum, to: 2))")
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
            }
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
    }

    // 국가별로 비용 항목을 분류하여 표시하는 함수입니다.
    private var drawExpensesDetail: some View {
        VStack(alignment: .leading, spacing: 0) {
            let sortedExpenses = expenseViewModel.filteredAllExpenses.sorted(by: { $0.payDate ?? Date() < $1.payDate ?? Date() }) // 날짜 순으로 정렬된 배열
            let groupedByDate = Dictionary(grouping: sortedExpenses, by: { Calendar.current.startOfDay(for: $0.payDate ?? Date()) }) // 날짜별로 그룹화
            
            ForEach(groupedByDate.keys.sorted(), id: \.self) { date in
                if let expensesForDate = groupedByDate[date] {
                    
                    let calculatedDay = expenseViewModel.daysBetweenTravelDates(selectedTravel: selectedTravel ?? Travel(context: expenseViewModel.viewContext), selectedDate: date)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("Day: \(calculatedDay)")
                            .font(.subhead1)
                            .foregroundStyle(.gray400)
                        Text("\(date, formatter: dateFormatterWithDay)")
                            .font(.caption2)
                            .foregroundStyle(.gray300)
                            .padding(.leading, 10)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    ForEach(expensesForDate, id: \.id) { expense in
                        HStack(alignment: .center, spacing: 0) {
                            
                            Image(ExpenseInfoCategory(rawValue: Int(expense.category))?.modalImageString ?? "nil")
                                .font(.system(size: 36))
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(expense.info ?? "info : unknown")")
                                    .font(.subhead2_1)
                                
                                HStack(alignment: .center, spacing: 0) {
                                    Text("\(dateFormatterWithHourMiniute(date: expense.payDate ?? Date()))")
                                        .font(.caption2)
                                        .foregroundStyle(.gray300)
                                    Divider()
                                        .padding(.horizontal, 3 )
                                    
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
                                    Text("\(Currency.getSymbol(of: Int(expense.currency)))")
                                        .font(.subhead2_1)
                                    
                                    Text("\(expenseViewModel.formatSum(from: expense.payAmount == -1 ? Double.nan : expense.payAmount, to: 2))")
                                        .font(.subhead2_1)
                                        .padding(.leading, 3 )
                                }
                                let currencyCodeName = Currency.getCurrencyCodeName(of: Int(expense.currency))
                                let exchangeRate = exchangeRatehandler.getExchangeRateFromKRW(currencyCode: currencyCodeName) ?? -100
                                let payAmount = expense.payAmount == -1 ? Double.nan : expense.payAmount * exchangeRate
                                let formattedPayAmount = expenseViewModel.formatSum(from: payAmount, to: 0)
                                Text("(\(formattedPayAmount)원)")
                                    .font(.caption2)
                                    .foregroundStyle(.gray200)
                                    .padding(.top, 4 )
                            }
                        }
                    }
                }
                Divider()
            }
            .padding(.bottom, 24)
        }
    }

    // 최종 배열
    func getFilteredExpenses() -> [Expense] {
        var filteredExpenses = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel?.id ?? UUID())
        
        if selectedPaymentMethod != -2 {
            filteredExpenses = expenseViewModel.filterExpensesByPaymentMethod(expenses: filteredExpenses, paymentMethod: selectedPaymentMethod)
        }
        
        if selectedCategory != -2 {
            filteredExpenses = expenseViewModel.filterExpensesByCategory(expenses: filteredExpenses, category: selectedCategory)
        }

        if selectedCountry != -2 {
            filteredExpenses = expenseViewModel.filterExpensesByCountry(expenses: filteredExpenses, country: selectedCountry)
        }
        
        return filteredExpenses
    }
}

//  #Preview {
//      AllExpenesDetailView()
//  }
