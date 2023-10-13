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
    @State private var selectedTravel: Travel?

    init() {
        self.expenseViewModel = ExpenseViewModel()
        self.dummyRecordViewModel = DummyRecordViewModel()
    }

    var body: some View {
        VStack {
            Text("일별 지출")
            // 여행별 Picker
            Picker("현재 여행", selection: $selectedTravel) {
                ForEach(dummyRecordViewModel.savedTravels, id: \.self) { travel in
                    Text(travel.name ?? "no name").tag(travel as Travel?) // travel의 id가 선택지로
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedTravel) { _, newValue in
                print(newValue ?? "")
            }
            Button {
                expenseViewModel.addExpense(travel: selectedTravel ?? Travel(context: dummyRecordViewModel.viewContext))
            } label: {
                Text("지출 추가")
            }
            // 여행별 리스트
            List {
                ForEach(expenseViewModel.savedExpenses.filter { $0.travel?.id == selectedTravel?.id }) { expense in
                    VStack {
                        Text(expense.info ?? "no info")
                        Text(expense.location ?? "no location")
                    }
                }
            }.listStyle(.automatic)
        }
        .onAppear {
            print("1 selectedTravel: \(String(describing: selectedTravel))")
            expenseViewModel.fetchExpense()
            dummyRecordViewModel.fetchDummyTravel()
            selectedTravel = dummyRecordViewModel.savedTravels.first
            print("2 selectedTravel: \(String(describing: selectedTravel))")
        }
    }
}

#Preview {
    TodayExpenseView()
}
