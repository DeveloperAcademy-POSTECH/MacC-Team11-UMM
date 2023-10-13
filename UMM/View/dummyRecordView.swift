//
//  RecordView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
struct DummyRecordView: View {
    @ObservedObject var viewModel = DummyRecordViewModel()
    var body: some View {
        VStack {
            Text("RecordView")
            Button {
                viewModel.addDummyTravel()
            } label: {
                Text("addDummyTravel")
            }
            if viewModel.savedTravels.count > 0 {
                List {
                    ForEach(viewModel.savedTravels) { travel in
                        Text(travel.name ?? "No Name")
                        Text(travel.startDate ?? "No StartDate")
                    }
                }.listStyle(.automatic)
            }
        }
        .onAppear {
            viewModel.fetchDummyTravel()
            print("viewModel.savedTravels.count: \(viewModel.savedTravels.count)")
        }
    }
}

#Preview {
    DummyRecordView()
}
