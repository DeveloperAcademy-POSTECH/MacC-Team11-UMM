//
//  ManualRecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct ManualRecordView: View {
    @ObservedObject var viewModel: ManualRecordViewModel
    @Environment(\.dismiss) var dismiss
    let viewContext = PersistenceController.shared.container.viewContext
    
    init(prevViewModel: RecordViewModel, needToFill: Bool) {
        if needToFill {
            viewModel = ManualRecordViewModel()
            viewModel.payAmount = prevViewModel.payAmount
            //        viewModel.payAmountInWon = ...
            viewModel.payAmountInWon = prevViewModel.payAmount * 9.1
            viewModel.info = prevViewModel.info
            viewModel.category = prevViewModel.infoCategory
            viewModel.paymentMethod = prevViewModel.paymentMethod
        }
        
        viewModel.chosenTravel = prevViewModel.chosenTravel
        do {
            viewModel.travelArray = try viewContext.fetch(Travel.fetchRequest())
        } catch {
            print("error fetching travelArray: \(error.localizedDescription)")
        }
        
        if let participantArray = viewModel.chosenTravel?.participantArray {
            viewModel.participantTupleArray = [("나", true)] + participantArray.map { ($0, true) }
        } else {
            viewModel.participantTupleArray = [("나", true)]
        }
        var expenseArray: [Expense] = []
        if let chosenTravel = viewModel.chosenTravel {
            do {
                try expenseArray = viewContext.fetch(Expense.fetchRequest()).filter { expense in
                    if let belongTravel = expense.travel {
                        return belongTravel.id == chosenTravel.id
                    } else {
                        return false
                    }
                }
            } catch {
                print("error fetching expenses: \(error.localizedDescription)")
            }
        }
        viewModel.otherCountryCandidateArray = Array(Set(expenseArray.map { Int($0.country) })).sorted().compactMap { Country(rawValue: $0) }
    }
    
    var body: some View {
        ZStack {
            Color(.white)
            VStack(spacing: 0) {
                titleBlockView
                ScrollView {
                    payAmountBlockView
                    inStringPropertyBlockView
                    notInStringPropertyBlockView
                }
                saveButtonView
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var titleBlockView: some View {
        ZStack {
            Color(.white)
                .layoutPriority(-1)
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 20)
                ZStack {
                    HStack(spacing: 0) {
                        Button {
                            _ = 0
                        } label: {
                            Image("manualRecordTitleLeftChevron")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        
                        Spacer()
                    }
                    
                    Text("기록 완료")
                        .foregroundStyle(.black)
                        .font(.subhead2_1)
                }
                
                Spacer()
                    .frame(width: 20)
            }
        }
        .padding(.top, 68)
        .padding(.bottom, 15)
    }
    
    private var payAmountBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            Text("pay amount and...")
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var inStringPropertyBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            Text("in-string properties...")
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var notInStringPropertyBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            Text("not-in-string properties...")
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var saveButtonView: some View {
        LargeButtonActive(title: "저장하기") {
            viewModel.save()
            dismiss()
        }
    }
}

#Preview {
    ManualRecordView(prevViewModel: RecordViewModel())
}
