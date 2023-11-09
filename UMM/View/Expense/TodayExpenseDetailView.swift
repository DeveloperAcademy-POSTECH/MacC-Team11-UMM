//
//  TodayExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
import CoreData

struct TodayExpenseDetailView: View {
    @StateObject var expenseViewModel = ExpenseViewModel()
    @EnvironmentObject var mainVM: MainViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var selectedTravel: Travel?
    var selectedDate: Date
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64
    @State private var currencyAndSums: [CurrencyAndSum] = []
    var sumPaymentMethod: Double
    @State private var isPaymentModalPresented = false
    let exchangeRatehandler = ExchangeRateHandler.shared
    let currencyInfoModel = CurrencyInfoModel.shared.currencyResult
    let countryInfoModel = CountryInfoModel.shared.countryResult
    let dateGapHandler = DateGapHandler.shared
    let viewContext = PersistenceController.shared.container.viewContext
    
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
            expenseViewModel.filteredTodayExpensesForDetail = self.getFilteredTodayExpenses(selectedTravel: selectedTravel ?? Travel(context: viewContext), selectedDate: selectedDate, selctedCountry: selectedCountry, selectedPaymentMethod: selectedPaymentMethod)
            currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredTodayExpensesForDetail)
            
            print("TEDV | selectedPaymentMethod: \(selectedPaymentMethod)")
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
                        expenseViewModel.filteredTodayExpensesForDetail = self.getFilteredTodayExpenses(selectedTravel: selectedTravel ?? Travel(context: viewContext), selectedDate: selectedDate, selctedCountry: selectedCountry, selectedPaymentMethod: selectedPaymentMethod)
                        currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredTodayExpensesForDetail)
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
            // 선택한 날짜를 보여주는 부분. 현지 시각으로 변환해서 보여준다.
            Text("\(dateGapHandler.convertBeforeShowing(date: selectedDate), formatter: dateFormatterWithDay)")
                .font(.caption2)
                .foregroundStyle(.gray300)
                .padding(.leading, 10)
        }
        .padding(.vertical, 20)
    }
    
    // 국가별로 비용 항목을 분류하여 표시하는 함수입니다.
    private var drawExpensesDetail: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(expenseViewModel.filteredTodayExpensesForDetail.sorted(by: { $0.payDate ?? Date() > $1.payDate ?? Date() }), id: \.self) { expense in
                
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
                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        Image(ExpenseInfoCategory(rawValue: Int(expense.category))?.modalImageString ?? "nil")
                            .font(.system(size: 36))
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("\(expense.info ?? "info: unknown")")
                                .font(.subhead2_1)
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
            }
            .padding(.bottom, 24)
        }
    }
    
    private func getFilteredTodayExpenses(selectedTravel: Travel, selectedDate: Date, selctedCountry: Int64, selectedPaymentMethod: Int64) -> [Expense] {
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel.id ?? UUID())
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
