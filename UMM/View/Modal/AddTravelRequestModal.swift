//
//  AddTravelRequestModal.swift
//  UMM
//
//  Created by Wonil Lee on 11/2/23.
//

import SwiftUI

struct AddTravelRequestModal: View {
    @ObservedObject var viewModel: RecordViewModel
    
    var body: some View {
        ZStack {
            Color(.white)
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 48)
                descriptionView
                Spacer()
                twoButtonsView
            }
        }
        .ignoresSafeArea()
    }
    
    private var descriptionView: some View {
        Text("현재 생성된 여행이 없어요.\n여행을 생성할까요?")
            .foregroundStyle(.black)
            .font(.display1)
            .multilineTextAlignment(.center)
            .opacity(0.8)
    }
    
    private var twoButtonsView: some View {
        HStack {
            MediumButtonUnactive(title: "임시 기록하기") {
                viewModel.isExplicitTempRecord = true
                viewModel.addTravelRequestModalIsShown = false
            }
            MediumButtonActive(title: "여행 생성하기") {
                viewModel.addTravelRequestModalIsShown = false
                MainViewModel.shared.selection = 0
            }
        }
    }
}

#Preview {
    AddTravelRequestModal(viewModel: RecordViewModel())
}
