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
    let countryInfoModel = CountryInfoModel.shared.countryResult
    @State private var isReverse = false

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
        }

        .frame(maxWidth: .infinity)
        .onAppear {
            expenseViewModel.fetchExpense()
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
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .foregroundColor(Color.black)
                    .padding(.trailing, 8)
                if selectedCountry != -2 {
                    Image(countryInfoModel[Int(selectedCountry)]?.flagString ?? "")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .shadow(color: .gray200, radius: 2)
                        .padding(.leading, 8)
                }
                Text("\(countryInfoModel[Int(selectedCountry)]?.koreanNm ?? "모든 국가")")
                    .font(.subhead2_1_fixed)
                    .foregroundStyle(.black)
            }
        }
    }
    
    private var paymentModal: some View {
        Button(action: {
            isPaymentModalPresented = true
        }, label: {
            HStack(spacing: 0) {
                Text("\(PaymentMethod.titleFor(rawValue: Int(selectedPaymentMethod)))")
                    .font(.subhead2_2_fixed)
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
                    .font(.display1_fixed)
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
                                    .font(.subhead3_1_fixed)
                                    .foregroundStyle(.black)
                                Spacer()
                                Image("check")
                            }
                        } else {
                            Text("\(PaymentMethod.titleFor(rawValue: idx))").tag(Int64(idx))
                                .font(.subhead3_1_fixed)
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
                        .font(.display1_fixed)
                        .padding(.leading, 8)
                }
            } else {
                HStack(alignment: .center, spacing: 0) {
                    Text("총 지출")
                        .font(.display1_fixed)
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
                .font(.display4_fixed)
                .padding(.top, 6)
            
            // 화폐별 합계
            HStack (spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(currencyAndSums.indices, id: \.self) { idx in
                            let currencyAndSum = currencyAndSums[idx]
                            Text("\(CurrencyInfoModel.shared.currencyResult[Int(currencyAndSum.currency)]?.symbol ?? "-")\(expenseViewModel.formatSum(from: currencyAndSum.sum, to: 2))")
                                .font(.caption2_fixed)
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
                Spacer()
                reverseButton
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
    
    private var reverseButton: some View {
        Button(action: {
            isReverse.toggle()
        }) {
            Image("arrowUpDown")
                .resizable()
                .frame(width: 18, height: 18)
        }
    }
    
    private var drawExpensesDetail: some View {
        VStack(alignment: .leading, spacing: 0) {
            let sortedExpenses = expenseViewModel.filteredAllExpensesForDetail.sorted(by: { (isReverse ? $0.payDate ?? Date() < $1.payDate ?? Date() : $0.payDate ?? Date() > $1.payDate ?? Date()) })

            let startDate = selectedTravel?.startDate ?? Date.distantPast
            let endDate = selectedTravel?.endDate ?? Date.distantFuture
            
            let beforeTravelExpenses = sortedExpenses.filter { Calendar.current.startOfDay(for: $0.payDate ?? Date()) < startDate }
            let duringTravelExpenses = sortedExpenses.filter { Calendar.current.startOfDay(for: $0.payDate ?? Date()) >= startDate && Calendar.current.startOfDay(for: $0.payDate ?? Date()) <= endDate }
            let afterTravelExpenses = sortedExpenses.filter { Calendar.current.startOfDay(for: $0.payDate ?? Date()) > endDate }
            
            let duringTravelGroupedByDate = Dictionary(grouping: duringTravelExpenses, by: { Calendar.current.startOfDay(for: $0.payDate ?? Date()) })
            let duringTravelDateKeys = duringTravelGroupedByDate.keys.sorted(by: >)
            
            if isReverse {
                if beforeTravelExpenses.count > 0 {
                    drawExpenseGroup(expenses: beforeTravelExpenses, title: "여행 전", backgroundColor: .white)
                    if duringTravelExpenses.count > 0 || afterTravelExpenses.count > 0 {
                        customDividerByDay
                    }
                }
                ForEach(Array(duringTravelDateKeys.enumerated().reversed()), id: \.element) { index, date in
                    if let expensesForDate = duringTravelGroupedByDate[date] {
                        drawExpenseGroup(expenses: expensesForDate, title: "Day \(expenseViewModel.daysBetweenTravelDates(selectedTravel: selectedTravel ?? Travel(context: expenseViewModel.viewContext), selectedDate: date) + 1)", backgroundColor: .white)
                        if index == 0 {
                            if afterTravelExpenses.count > 0 {
                                customDividerByDay
                            }
                        }
                    }
                }
                if afterTravelExpenses.count > 0 {
                    drawExpenseGroup(expenses: afterTravelExpenses, title: "여행 후", backgroundColor: .white)
                }
            } else {
                if afterTravelExpenses.count > 0 {
                    drawExpenseGroup(expenses: afterTravelExpenses, title: "여행 후", backgroundColor: .white)
                    if duringTravelExpenses.count > 0 || beforeTravelExpenses.count > 0 {
                        customDividerByDay
                    }
                }
                ForEach(Array(duringTravelDateKeys.enumerated()), id: \.element) { index, date in
                    if let expensesForDate = duringTravelGroupedByDate[date] {
                        drawExpenseGroup(expenses: expensesForDate, title: "Day \(expenseViewModel.daysBetweenTravelDates(selectedTravel: selectedTravel ?? Travel(context: expenseViewModel.viewContext), selectedDate: date) + 1)", backgroundColor: .white)
                        if index == duringTravelDateKeys.count - 1 {
                            if beforeTravelExpenses.count > 0 {
                                customDividerByDay
                            }
                        }
                    }
                }
                if beforeTravelExpenses.count > 0 {
                    drawExpenseGroup(expenses: beforeTravelExpenses, title: "여행 전", backgroundColor: .white)
                }
            }
        }
    }

    private func drawExpenseGroup(expenses: [Expense], title: String, backgroundColor: Color) -> some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(.subhead1_fixed)
                    .foregroundStyle(.gray400)
                if title == "여행 전" || title == "여행 후" {
                    Text("")
                } else {
                    Text("\(dateGapHandler.convertBeforeShowing(date: expenses.first?.payDate ?? Date()), formatter: dateFormatterWithDay)")
                        .font(.caption2_fixed)
                        .foregroundStyle(.gray300)
                        .padding(.leading, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            ForEach(expenses, id: \.id) { expense in
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
                        given_id: expense.id,
                        given_travel: expense.travel
                    )
                    .environmentObject(mainVM)
                } label : {
                    HStack(alignment: .center, spacing: 0) {
                        Image(ExpenseInfoCategory(rawValue: Int(expense.category))?.modalImageString ?? "nil")
                            .font(.system(size: 36))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(expense.info ?? "알 수 없는 내역")")
                                .font(.subhead2_1_fixed)
                                .foregroundStyle(.black)
                                .lineLimit(1)
                            HStack(alignment: .center, spacing: 3) {
                                // 소비 기록을 한 시각을 보여주는 부분
                                // 저장된 expense.payDate를 현지 시각으로 변환해서 보여준다.
                                
                                if title == "여행 전" || title == "여행 후" {
                                    Text("")
                                } else {
                                    if let payDate = expense.payDate {
                                        Text("\(dateFormatterWithHourMiniute(date: dateGapHandler.convertBeforeShowing(date: payDate)))")
                                            .font(.caption2_fixed)
                                            .foregroundStyle(.gray300)
                                    } else {
                                        Text("-")
                                            .font(.caption2_fixed)
                                            .foregroundStyle(.gray300)
                                    }
                                    Text("|")
                                        .font(.caption2_fixed)
                                        .foregroundStyle(.gray300)
                                }
                                Text("\(PaymentMethod.titleFor(rawValue: Int(expense.paymentMethod)))")
                                    .font(.caption2_fixed)
                                    .foregroundStyle(.gray300)
                            }
                            .padding(.top, 4)
                        }
                        .background(backgroundColor)
                        .padding(.leading, 10)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            HStack(alignment: .center, spacing: 0) {
                                Text("\(currencyInfoModel[Int(expense.currency)]?.symbol ?? "-")")
                                    .font(.subhead2_1_fixed)
                                    .foregroundStyle(.black)
                                
                                Text("\(expenseViewModel.formatSum(from: expense.payAmount == -1 ? Double.nan : expense.payAmount, to: 2))")
                                    .font(.subhead2_1_fixed)
                                    .foregroundStyle(.black)
                                    .padding(.leading, 3 )
                            }
                            let currencyCodeName = currencyInfoModel[Int(expense.currency)]?.isoCodeNm ?? "Unknown"
                            let exchangeRate = exchangeRatehandler.getExchangeRateFromKRW(currencyCode: currencyCodeName) ?? -100
                            let payAmount = expense.payAmount == -1 ? Double.nan : expense.payAmount * exchangeRate
                            let formattedPayAmount = expenseViewModel.formatSum(from: payAmount, to: 0)
                            Text("(\(formattedPayAmount)원)")
                                .font(.caption2_fixed)
                                .foregroundStyle(.gray200)
                                .padding(.top, 4 )
                        }
                    }
                    .padding(0)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private var customDividerByDay: some View {
            Rectangle()
                .fill(Color.gray100)
                .frame(height: 8)
    }
    
    private var customDividerByPayDateAndPayAmount: some View {
        Rectangle()
            .fill(.gray300)
            .font(.system(.caption2))
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

// #Preview {
//     AllExpenseDetailView()
// }
