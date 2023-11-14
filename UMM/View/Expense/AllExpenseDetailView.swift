//
//  AllExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseDetailView: View {
    @StateObject var expenseViewModel = ExpenseViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var mainVM: MainViewModel
    
    var selectedTravel: Travel?
    var selectedCategory: Int64
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64
    @State private var currencyAndSums: [CurrencyAndSum] = []
    @State private var isPaymentModalPresented = false
    var sumPaymentMethod: Double
    let exchangeRatehandler = ExchangeRateHandler.shared
    let currencyInfoModel = CurrencyInfoModel.shared.currencyResult
    let dateGapHandler = DateGapHandler.shared
    let viewContext = PersistenceController.shared.container.viewContext

    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            paymentModal
                .padding(.horizontal, 20)
            allExpenseSummary
                .padding(.horizontal, 20)
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    drawExpensesDetail
                }
            }
            .padding(.horizontal, 20)
        }

        .frame(maxWidth: .infinity)
        .onAppear {
            expenseViewModel.filteredAllExpensesForDetail = self.getFilteredAllExpenses(selectedTravel: selectedTravel ?? Travel(context: viewContext), selectedPaymentMethod: selectedPaymentMethod, selectedCategory: selectedCategory, selectedCountry: selectedCountry)
            currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredAllExpensesForDetail)
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.white, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButtonView)
    }
    
    private var backButtonView: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .imageScale(.large)
                .foregroundColor(Color.black)
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
                        expenseViewModel.filteredAllExpensesForDetail = self.getFilteredAllExpenses(selectedTravel: selectedTravel ?? Travel(context: viewContext), selectedPaymentMethod: selectedPaymentMethod, selectedCategory: selectedCategory, selectedCountry: selectedCountry)
                        currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredAllExpensesForDetail)
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
            let sortedExpenses = expenseViewModel.filteredAllExpensesForDetail.sorted(by: { $0.payDate ?? Date() > $1.payDate ?? Date() }) // 날짜 순으로 정렬된 배열
            let groupedByDate = Dictionary(grouping: sortedExpenses, by: { Calendar.current.startOfDay(for: $0.payDate ?? Date()) }) // 날짜별로 그룹화
            
            ForEach(groupedByDate.keys.sorted(by: >), id: \.self) { date in
                if let expensesForDate = groupedByDate[date] {
                    
                    let calculatedDay = expenseViewModel.daysBetweenTravelDates(selectedTravel: selectedTravel ?? Travel(context: expenseViewModel.viewContext), selectedDate: date)
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("Day \(calculatedDay + 1)")
                            .font(.subhead1)
                            .foregroundStyle(.gray400)
                        // 선택한 날짜를 보여주는 부분. 현지 시각으로 변환해서 보여준다.
                        Text("\(dateGapHandler.convertBeforeShowing(date: date), formatter: dateFormatterWithDay)")
                            .font(.caption2)
                            .foregroundStyle(.gray300)
                            .padding(.leading, 10)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    ForEach(expensesForDate, id: \.id) { expense in
                        NavigationLink {
                            ManualRecordInExpenseView(
                                given_wantToActivateAutoSaveTimer: false,
                                given_payAmount: expense.payAmount,
                                given_currency: Int(expense.currency),
                                given_info: expense.info,
                                given_infoCategory: ExpenseInfoCategory(rawValue: Int(expense.category)) ?? .unknown,
                                given_paymentMethod: PaymentMethod(rawValue: Int(expense.paymentMethod)) ?? .unknown,
                                given_soundRecordData: expense.voiceRecordFile,
                                given_expense: expense,
                                given_payDate: expense.payDate,
                                given_country: Int(expense.country),
                                given_location: expense.location,
                                given_id: expense.id
                            )
                            .environmentObject(mainVM) // ^^^
                        } label : {
                            HStack(alignment: .center, spacing: 0) {
                                Image(ExpenseInfoCategory(rawValue: Int(expense.category))?.modalImageString ?? "nil")
                                    .font(.system(size: 36))
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("\(expense.info ?? "알 수 없는 내역")")
                                        .font(.subhead2_1)
                                        .foregroundStyle(.black)
                                        .lineLimit(1)
                                    HStack(alignment: .center, spacing: 0) {
                                        // 소비 기록을 한 시각을 보여주는 부분
                                        // 저장된 expense.payDate를 현지 시각으로 변환해서 보여준다.
                                        if let payDate = expense.payDate {
                                            Text("\(dateFormatterWithHourMiniute(date: dateGapHandler.convertBeforeShowing(date: payDate)))")
                                                .font(.caption2)
                                                .foregroundStyle(.gray300)
                                        } else {
                                            Text("-")
                                                .font(.caption2)
                                                .foregroundStyle(.gray300)
                                        }
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
                                            .foregroundStyle(.black)
                                        
                                        Text("\(expenseViewModel.formatSum(from: expense.payAmount == -1 ? Double.nan : expense.payAmount, to: 2))")
                                            .font(.subhead2_1)
                                            .foregroundStyle(.black)
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
                }
                Divider()
            }
            .padding(.bottom, 24)
        }
    }
    
    private func getFilteredAllExpenses(selectedTravel: Travel, selectedPaymentMethod: Int64, selectedCategory: Int64, selectedCountry: Int64) -> [Expense] {
        var filteredExpenses = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel.id ?? UUID())
        
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
