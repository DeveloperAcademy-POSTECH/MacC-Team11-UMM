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
    @State private var selectedTravel: Travel?
    @State private var selectedDate = Date()

    init() {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
    }

    var body: some View {
        ScrollView {
            Text("일별 지출")
            
            // Picker: 여행별
            Picker("현재 여행", selection: $selectedTravel) {
                ForEach(dummyRecordViewModel.savedTravels, id: \.self) { travel in
                    Text(travel.name ?? "no name").tag(travel as Travel?) // travel의 id가 선택지로
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedTravel) { _, newValue in
                print(newValue?.name ?? "")
            }
            
            // Picker: 날짜별
            DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date])
            
            Button {
                expenseViewModel.addExpense(travel: selectedTravel ?? Travel(context: dummyRecordViewModel.viewContext))
                findCurrentTravelHandler.findCurrentTravel()
            } label: {
                Text("지출 추가")
            }
            
            Spacer()
            
            // 여행별 + 날짜별 리스트
            // 국가별로 나눠서 보여줌
            let filteredExpensesByTravelByDate = expenseViewModel.filterExpensesByTravelByDate(selectedTravel: selectedTravel, selectedDate: selectedDate)
            drawExpensesByLocation(filteredExpensesByTravelByDate: filteredExpensesByTravelByDate)

        }
        .onAppear {
            print("####")
            print("TodayExpenseView Appeared")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            findCurrentTravelHandler.findCurrentTravel()
            self.selectedTravel = findCurrentTravelHandler.currentTravel
        }
    }
}

// 국가별로 비용 항목을 분류하여 표시
private func drawExpensesByLocation(filteredExpensesByTravelByDate: [Expense]) -> some View {
    let groupedExpenses = Dictionary(grouping: filteredExpensesByTravelByDate, by: { $0.location })
    
    return ForEach(groupedExpenses.sorted(by: { $0.key ?? "" < $1.key ?? "" }), id: \.key) { location, expenses in
        Section(header: Text(location ?? "")) {
            ForEach(expenses, id: \.id) { expense in
                if let payDate = expense.payDate {
                    VStack {
                        HStack {
                            Text(expense.info ?? "no info")
                            Text(expense.location ?? "no location")
                        }
                        Text(payDate.description)
                    }
                    .padding()
                }
            }
            Divider()
        }
    }
}



#Preview {
    TodayExpenseView()
}
