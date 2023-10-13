//
//  RecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

import SwiftUI

struct RecordView: View {
    
    @ObservedObject var viewModel = RecordViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            travelChoiceView
            sentenceView
            livePropertyView
            sentenceAlterButton
        }
        .onAppear {
            viewModel.divideVoiceSentence()
        }
    }
    
    var travelChoiceView: some View {
        Capsule()
            .fill(.gray)
            .frame(width: 80, height: 40)
    }
    
    var sentenceView: some View {
        Text("보정 전 문장: \(viewModel.voiceSentence)")
    }
    
    var livePropertyView: some View {
        VStack {
            HStack {
                Text("소비내역")
                Text(viewModel.info ?? " ")
            }
            HStack {
                Text("금액")
                Text(String(format: "%.2f", viewModel.payAmount))
            }
            HStack {
                Text("결제 수단(-1미정0카드1현금)")
                Text("\(viewModel.paymentMethod.rawValue)")
            }
        }
    }
    
    var sentenceAlterButton: some View {
        Button {
            viewModel.alterVoiceSentence()
            viewModel.divideVoiceSentence()
        } label: {
            ZStack {
                Circle()
                    .fill(.gray)
                    .frame(width: 50, height: 50)
                Text("다음")
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    RecordView()
}
