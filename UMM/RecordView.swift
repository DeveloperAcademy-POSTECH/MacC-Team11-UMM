//
//  RecordView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
struct RecordView: View {
//    @Environment(\.managedObjectContext) private var viewContext
    let viewModel = RecordViewModel()
    var body: some View {
        VStack {
            Text("RecordView")
            Button {
                viewModel.saveDD()
            } label: {
                Text("save")
            }
            ForEach(dummyExpenses) {expense in
                Text(expense.info ?? "no data")
            }
        }
    }
}

#Preview {
    RecordView()
}
