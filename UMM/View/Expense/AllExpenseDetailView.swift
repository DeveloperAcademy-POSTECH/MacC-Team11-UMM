//
//  AllExpenseDetailView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct AllExpenseDetailView: View {
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    @ObservedObject var dummyRecordViewModel = DummyRecordViewModel()
    
    var selectedTravel: Travel?
    var selectedCategory: Int64
    var selectedCountry: Int64
    @State var selectedPaymentMethod: Int64
//    @State private var currencySums: [CurrencyAndSum] = []
    @State private var currencyAndSums: [CurrencyAndSum] = []
    @State private var isPaymentModalPresented = false

    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            paymentModal
            allExpenseSummary
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
//                    dayField
                    drawExpensesDetail
                }
            }
        }

//        ScrollView {
//            Picker("현재 결제 수단", selection: $selectedPaymentMethod) {
//                ForEach(-1...1, id: \.self) { index in
//                    Text("\(index)").tag(Int64(index))
//                }
//            }
//            .pickerStyle(MenuPickerStyle())
//            .onChange(of: selectedPaymentMethod) {
//                expenseViewModel.filteredExpenses = getFilteredExpenses()
//                currencySums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
//            }
//            
//            Spacer()
//            
//            drawExpensesDetail
//            
//        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .onAppear {
            print("onAppear AllExpenseDetailView")
            print("AllExpenseDetailView | selected Country: \(selectedCountry)")
            print("AllExpenseDetailView | selected Travel: \(String(describing: selectedTravel?.expenseArray?.count))")
            print("AllExpenseDetailView | type of selected Country: \(type(of: selectedCountry))")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            
            expenseViewModel.filteredExpenses = getFilteredExpenses()
            currencyAndSums = expenseViewModel.calculateCurrencySums(from: expenseViewModel.filteredExpenses)
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
    
    private var allExpenseSummary: some View {
        VStack(alignment: .leading, spacing: 0) {
            //  카테고리 이름
            if selectedCategory != -2 {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "wifi")
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
            Text("\(expenseViewModel.formatSum(from: currencyAndSums.reduce(0) { $0 + $1.sum }, to: 0))원")
                .font(.display4)
                .padding(.top, 6)
            
            // 화폐별 합계
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(currencyAndSums.indices, id: \.self) { idx in
                        let currencySum = currencyAndSums[idx]
                        Text("\(currencySum.currency): \(expenseViewModel.formatSum(from: currencySum.sum, to: 2))")
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
            let sortedExpenses = expenseViewModel.filteredExpenses.sorted(by: { $0.payDate ?? Date() < $1.payDate ?? Date() }) // 날짜 순으로 정렬된 배열
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
                            Image(systemName: "wifi")
                                .font(.system(size: 36))
                            
                            VStack(alignment:.leading, spacing : 0){
                                Text("\(expense.info ?? "info : unknown")")
                                    .font(.subhead2_1)
                                
                                HStack(alignment:.center ,spacing : 0){
                                    Text("\(dateFormatterWithHourMiniute(date : expense.payDate ?? Date()))")
                                        .font(.caption2)
                                        .foregroundStyle(.gray300)
                                    Divider()
                                        .padding(.horizontal ,3 )
                                    
                                    Text("\(PaymentMethod.titleFor(rawValue:Int(expense.paymentMethod)))")
                                        .font(.caption2)
                                        .foregroundStyle(.gray300)
                                }
                                .padding(.top, 4)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                            
                            VStack(alignment:.trailing ,spacing : 0){
                                HStack(alignment:.center ,spacing : 0){
                                    Text("\(expense.currency)")
                                        .font(.subhead2_1)
                                    
                                    Text("\(expenseViewModel.formatSum(from: expense.payAmount, to: 2))")
                                        .font(.subhead2_1)
                                        .padding(.leading,3 )
                                }
                                
                                Text("원화로 환산된 금액")
                                    .font(.caption2)
                                    .foregroundStyle(.gray200)
                                    .padding(.top,4 )
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
        
        let filteredByTravel = expenseViewModel.filterExpensesByTravel(expenses: expenseViewModel.savedExpenses, selectedTravelID: selectedTravel?.id ?? UUID())
        print("Filtered by travel.count: \(filteredByTravel.count)")
        
        let filteredByCategory = expenseViewModel.filterExpensesByCategory(expenses: filteredByTravel, category: selectedCategory)
        print("Filtered by category.count: \(filteredByCategory.count)")

        let filteredByCountry = expenseViewModel.filterExpensesByCountry(expenses: filteredByCategory, country: selectedCountry)
        print("Filtered by Country.count: \(filteredByCountry.count)")
        print("Filtered by selectedPaymentMethod: \(selectedPaymentMethod)")
        
        if selectedCategory == -2 {
            return filteredByTravel
        } else {
            if selectedCountry == -2 {
                return filteredByCategory
            } else {
                return filteredByCountry
            }
        }
    }
}

//  #Preview {
//      AllExpenesDetailView()
//  }
