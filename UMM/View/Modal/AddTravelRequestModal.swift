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
        Text("현재 진행 중인 여행이 없어요.\n여행을 생성할까요?")
            .foregroundStyle(.black)
            .font(.display1)
            .multilineTextAlignment(.center)
            .opacity(0.8)
    }
    
    private var twoButtonsView: some View {
        HStack {
            MediumButtonUnactive(title: "여행 생성하기") {
                viewModel.addTravelRequestModalIsShown = false
                // 탭 이동하고 여행 생성하는 페이지로 자동으로 넘어가기 구현하기 ^^^
            }
            MediumButtonActive(title: "임시 기록하기") {
                viewModel.defaultTravelNameReplacer = "임시 기록"
                viewModel.addTravelRequestModalIsShown = false
            }
        }
        .padding(.bottom, 45) // 버튼 템플릿 변화하면 변화에  맞춰서 수정하기 ^^^
    }
}

#Preview {
    AddTravelRequestModal(viewModel: RecordViewModel())
}
