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
            rawSentenceView
            livePropertyView
            manualRecordButton
            recordButton
        }
        .sheet(isPresented: $viewModel.manualRecordModalIsShown) {
            ManualRecordView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.completeRecordModalIsShown) {
            CompleteRecordView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.travelChoiceHalfModalIsShown) {
            TravelChoiceHalfView(viewModel: viewModel)
                .presentationDetents([.height(226)])
        }
    }
    
    private var travelChoiceView: some View {
        Capsule()
            .fill(.gray)
            .frame(width: 80, height: 40)
            .onTapGesture {
                viewModel.travelChoiceHalfModalIsShown = true
            }
    }
    
    private var rawSentenceView: some View {
        if !isDetectingPress {
            Text("지출을 기록해주세요")
        } else {
            if viewModel.voiceSentence == "" {
                Text("듣고 있어요")
            } else {
                Text(viewModel.voiceSentence)
            }
            
        }
    }
    
    private var livePropertyView: some View {
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
    
    private var manualRecordButton: some View {
        Button {
            viewModel.manualRecordModalIsShown = true
        } label: {
            Text("직접 기록")
        }
        .buttonStyle(.bordered)
    }
    
    private var recordButton: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isDetectingPress ? .gray : .blue)
                    .frame(width: 50, height: 50)
                Image(systemName: "record.circle")
                    .foregroundStyle(Color.white)
            }
            .gesture(continuousPress)
            .onChange(of: isDetectingPress) { value in
                if !value {
                    print("녹음 끝")
                    viewModel.stopSTT()
                    viewModel.stopRecording()
                    viewModel.completeRecordModalIsShown = true
                }
            }
            
        }
    }
    
    private var continuousPress: some Gesture {
        LongPressGesture(minimumDuration: 0.1, maximumDistance: 40)
            .sequenced(before: LongPressGesture(minimumDuration: .infinity, maximumDistance: 40))
            .updating($isDetectingPress) { value, state, _ in
                switch value {
                case .second(true, nil):
                    state = true
                    print("녹음 시작")
                    do {
                        try viewModel.startSTT()
                        viewModel.startRecording()
                    } catch {
                        print("error starting record: \(error.localizedDescription)")
                    }
                default:
                    break
                }
            }
    }
}

#Preview {
    RecordView()
}
