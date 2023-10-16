//
//  RecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

import SwiftUI

struct RecordView: View {
    
    @ObservedObject var viewModel = RecordViewModel()
    @GestureState private var isDetectingPress = false
    
    var body: some View {
        VStack(spacing: 50) {
            travelChoiceView
            sentenceView
            livePropertyView
            recordButton
        }
    }
    
    var travelChoiceView: some View {
        Capsule()
            .fill(.gray)
            .frame(width: 80, height: 40)
    }
    
    var sentenceView: some View {
        if !viewModel.buttonPressed {
            Text("지출을 기록해주세요")
        } else {
            if viewModel.voiceSentence == "" {
                Text("듣고 있어요")
            } else {
                Text(viewModel.voiceSentence)
            }
            
        }
    }
    
    var livePropertyView: some View {
        VStack(spacing: 20) {
            HStack {
                Text("소비내역")
                if viewModel.info != nil {
                    Image(systemName: "wifi")
                        .foregroundStyle(.red)
                    Text(viewModel.info!)
                } else {
                    Image(systemName: "wifi")
                        .foregroundStyle(.blue)
                    Text("-")
                }
            }
            HStack {
                Text("금액")
                if viewModel.payAmount != -1 {
                    Image(systemName: "wifi")
                        .foregroundStyle(.red)
                    Text(String(format: "%.2f", viewModel.payAmount))
                } else {
                    Image(systemName: "wifi")
                        .foregroundStyle(.blue)
                    Text("-")
                }
            }
            HStack {
                Text("결제 수단")
                switch viewModel.paymentMethod {
                case .card:
                    HStack {
                        Text("현금")
                            .foregroundStyle(.gray)
                        Text("/")
                            .foregroundStyle(.gray)
                        Text("카드")
                    }
                case .cash:
                    HStack {
                        Text("현금")
                        Text("/")
                            .foregroundStyle(.gray)
                        Text("카드")
                            .foregroundStyle(.gray)
                    }
                case .unknown:
                    HStack {
                        Text("현금")
                        Text("/")
                        Text("카드")
                    }
                    .foregroundStyle(.gray)
                }
            }
        }
    }
    
    var continuousPress: some Gesture {
        LongPressGesture(minimumDuration: 0.1)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .updating($isDetectingPress) { value, gestureState, _ in
                switch value {
                case .first(true):
                    gestureState = true
                    print("녹음 시작")
                case .second(true, nil):
                    gestureState = true
                    print("녹음 중")
                default:
                    break
                }
            }.onEnded { value in
                switch value {
                case .second:
                    print("녹음완료")
                    print(viewModel.voiceSentence)
                default:
                    break
                }
            }
    }
    
    var recordButton: some View {
        VStack {
            Button {
                viewModel.invalidateButton()
                do {
                    try viewModel.startRecording()
                } catch {
                    print("error while recording: \(error.localizedDescription)")
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isDetectingPress ? .gray : .blue)
                        .frame(width: 50, height: 50)
                    Image(systemName: "record.circle")
                        .foregroundStyle(Color.white)
                }
            }
            .simultaneousGesture(continuousPress)
        }
    }
}

#Preview {
    RecordView()
}
