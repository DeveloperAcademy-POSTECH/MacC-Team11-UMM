//
//  TodayExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct TodayExpenseView: View {
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var dummyRecordViewModel: DummyRecordViewModel
    @ObservedObject var findCurrentTravelHandler = FindCurrentTravelHandler()
    
    init() {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("일별 지출")
                
                // Picker: 여행별
                Picker("현재 여행", selection: $expenseViewModel.selectedTravel) {
                    ForEach(dummyRecordViewModel.savedTravels, id: \.self) { travel in
                        Text(travel.name ?? "no name").tag(travel as Travel?) // travel의 id가 선택지로
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                // Picker: 날짜별
                DatePicker("날짜", selection: $expenseViewModel.selectedDate, displayedComponents: [.date])
                
                Button {
                    expenseViewModel.addExpense(travel: expenseViewModel.selectedTravel ?? Travel(context: dummyRecordViewModel.viewContext))
                    findCurrentTravelHandler.findCurrentTravel()
                } label: {
                    Text("지출 추가")
                }
                
                Spacer()
                
                // 여행별 + 날짜별 리스트
                // 국가별로 나눠서 보여줌
                let filteredExpensesByTravel = expenseViewModel.filterExpensesByTravel(selectedTravelID: expenseViewModel.selectedTravel?.id ?? UUID())
                let filteredExpensesByDate = expenseViewModel.filterExpensesByDate(expenses: filteredExpensesByTravel, selectedDate: expenseViewModel.selectedDate)
                drawExpensesByLocation(expenses: filteredExpensesByDate)
                
            }
        }
        .onAppear {
            print("####")
            print("TodayExpenseView Appeared")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            findCurrentTravelHandler.findCurrentTravel()
            expenseViewModel.selectedTravel = findCurrentTravelHandler.currentTravel
        }
    }
    
    // 국가별 + 결제수단별 지출액 표시
    private func drawExpensesByLocation(expenses: [Expense]) -> some View {
        let groupedExpenses = Dictionary(grouping: expenses, by: { $0.location })
        
        return ForEach(groupedExpenses.sorted(by: { $0.key ?? "" < $1.key ?? "" }), id: \.key) { location, expenses in
            let groupedExpensesByPaymentMethod = Dictionary(grouping: expenses, by: { $0.paymentMethod })
            Section(header: Text(location ?? "")) {
                
                // 모든 결제 금액
                let totalPayAmountForAllMethods = expenses.reduce(0.0) { $0 + ($1.payAmount ?? 0.0) }
                NavigationLink(destination:
                    TodayExpenseDetailView(
                        selectedTravel: $expenseViewModel.selectedTravel,
                        selectedDate: $expenseViewModel.selectedDate,
                        selectedLocation: .constant(location ?? "서울"),
                        selectedPaymentMethod: .constant(Int64(0)) // nil to represent all methods.
                    )
                ) {
                    VStack {
                        Text("All Payment Methods")
                        Text("Total Pay Amount for All Methods : \(totalPayAmountForAllMethods)")
                    }
                    .padding()
                }
                
                // 결제 수단별 금액
                ForEach(groupedExpensesByPaymentMethod.sorted(by: { $0.key < $1.key }), id: \.key) { paymentMethod, expensesForPaymentMethod in
                    let totalPayAmount = expensesForPaymentMethod.reduce(0.0) { $0 + ($1.payAmount ?? 0.0) }
                    NavigationLink(destination:
                        TodayExpenseDetailView(
                            selectedTravel:$expenseViewModel.selectedTravel,
                            selectedDate:$expenseViewModel.selectedDate,
                            selectedLocation:.constant(location ?? "서울"),
                            selectedPaymentMethod:.constant(Int64(paymentMethod))
                        )
                    ) {
                        VStack {
                            Text("Payment Method: \(paymentMethod)")
                            Text("Total Pay Amount: \(totalPayAmount)")
                        }
                        .padding()
                    }
                }
                Divider()
            }
        }
    }
}






//
//// 국가별로 비용 항목을 분류하여 표시
//private func drawExpensesByLocation(expenses: [Expense]) -> some View {
//    let groupedExpenses = Dictionary(grouping: expenses, by: { $0.paymentMethod })
//
//    return ForEach(groupedExpenses.sorted(by: { $0.key < $1.key }), id: \.key) { paymentMethod, expenses in
//        Section(header: Text(paymentMethod)) {
//            ForEach(expenses, id: \.id) { expense in
//                if let payDate = expense.payDate {
//                    VStack {
//                        HStack {
//                            Text(expense.info ?? "no info")
//                            Text(expense.paymentMethod ?? "no location")
//                        }
//                        Text(payDate.description)
//                    }
//                    .padding()
//                }
//            }
//            Divider()
//        }
//    }
//}



#Preview {
    TodayExpenseView()
}
