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
    @ObservedObject var dummyRecordViewModel = DummyRecordViewModel()
    
    var selectedTravel: Travel?
    var selectedDate: Date
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64 = -1
    @State private var currencyAndSums: [CurrencyAndSum] = []
    var sumPaymentMethod: Double
    @State private var isPaymentModalPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            paymentModal
            totalHeader
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
            dummyRecordViewModel.fetchDummyTravel()
            expenseViewModel.selectedTravel = selectedTravel
            
            let filteredResult = getFilteredExpenses()
            expenseViewModel.filteredExpenses = filteredResult
            currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
        }
    }
    
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
    
    private var paymentModal: some View {
        Button(action: {
            isPaymentModalPresented = true
        }, label: {
            HStack(spacing: 0) {
                Text("\(PaymentMethod.titleFor(rawValue: Int(selectedPaymentMethod)))")
                    .font(.subhead2_2)
                    .foregroundStyle(.gray400)
                    .padding(.vertical, 28)
                Image(systemName: "wifi")
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
                        expenseViewModel.filteredExpenses = getFilteredExpenses()
                        currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
                        isPaymentModalPresented = false
                    }, label: {
                        if selectedPaymentMethod == idx {
                            HStack {
                                Text("\(PaymentMethod.titleFor(rawValue: idx))").tag(Int64(idx))
                                    .font(.subhead3_1)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image(systemName: "wifi")
                                    .foregroundStyle(.mainPink)
                                    .font(.system(size: 24))
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

    private var totalHeader: some View {
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
            ForEach(expenseViewModel.filteredExpenses, id: \.id) { expense in
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "wifi")
                        .font(.system(size: 36))
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(expense.info ?? "info: unknown")")
                            .font(.subhead2_1)
                        HStack(alignment: .center, spacing: 0) {
                            Text("\(dateFormmaterWithHourMiniute(date: expense.payDate ?? Date()))")
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
                            Text("\(expense.currency)")
                                .font(.subhead2_1)
                            Text("\(expenseViewModel.formatSum(expense.payAmount, 2))")
                                .font(.subhead2_1)
                                .padding(.leading, 3)
                        }
                        Text("원화로 환산된 금액")
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
