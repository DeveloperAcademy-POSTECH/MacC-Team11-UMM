//
//  RecordView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

//import SwiftUI
//struct DummyRecordView: View {
//    @ObservedObject var viewModel = DummyRecordViewModel()
//    var body: some View {
//        VStack {
//            Text("RecordView")
//            Button {
//                viewModel.addDummyTravel()
//            } label: {
//                Text("addDummyTravel")
//            }
//            List {
//                ForEach(viewModel.savedTravels) { travel in
//                    Text(travel.name ?? "No Name")
//                }
//            }.listStyle(.automatic)
//        }
//        .onAppear {
//            print("####")
//            print("RecordView Appeared")
//            viewModel.fetchDummyTravel()
//            print("viewModel.savedTravels.count: \(viewModel.savedTravels.count)")
//        }
//    }
//}
//
//#Preview {
//    DummyRecordView()
//}
