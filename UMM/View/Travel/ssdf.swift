////
////  ssdf.swift
////  UMM
////
////  Created by 김태현 on 10/22/23.
////
//
//import Foundation
//
//private var drawExpensesDetail: some View {
//    VStack(alignment: .leading, spacing: 0) {
//        ForEach(expenseViewModel.filteredExpenses, id: \.id) { expense in
//            HStack(alignment: .center, spacing: 0) {
//                Image(systemName: "wifi")
//                    .font(.system(size: 36))
//                
//                VStack(alignment: .leading, spacing: 0) {
//                    Text("\(expense.info ?? "info: unknown")")
//                        .font(.subhead2_1)
//                    HStack(alignment: .center, spacing: 0) {
//                        Text("\(dateFormatterWithHourMiniute(date: expense.payDate ?? Date()))")
//                            .font(.caption2)
//                            .foregroundStyle(.gray300)
//                        Divider()
//                            .padding(.horizontal, 3)
//                        Text("\(PaymentMethod.titleFor(rawValue: Int(expense.paymentMethod)))")
//                            .font(.caption2)
//                            .foregroundStyle(.gray300)
//                    }
//                    .padding(.top, 4)
//                }
//                .padding(.leading, 10)
//                
//                Spacer()
//                
//                VStack(alignment: .trailing, spacing: 0) {
//                    HStack(alignment: .center, spacing: 0) {
//                        Text("\(expense.currency)")
//                            .font(.subhead2_1)
//                        Text("\(expenseViewModel.formatSum(from: expense.payAmount, to: 2))")
//                            .font(.subhead2_1)
//                            .padding(.leading, 3)
//                    }
//                    Text("원화로 환산된 금액")
//                        .font(.caption2)
//                        .foregroundStyle(.gray200)
//                        .padding(.top, 4)
//                }
//            }
//        }
//        .padding(.bottom, 24)
//    }
//}
