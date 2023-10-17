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
        ZStack {
            VStack(spacing: 50) {
                travelChoiceView
                rawSentenceView
                livePropertyView
                manualRecordButtonView
            }
            alertView
            recordButtonView
                .offset(y: 250)
        }
        .onAppear() {
            viewModel.chosenTravel = findCurrentTravel()
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
        Text(viewModel.chosenTravel?.name != "Default" ? viewModel.chosenTravel?.name ?? "-" : "-")
            .onTapGesture {
                viewModel.travelChoiceHalfModalIsShown = true
                print("viewModel.travelChoiceHalfModalIsShown = true")
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
    
    private var manualRecordButtonView: some View {
        Button {
            viewModel.manualRecordModalIsShown = true
        } label: {
            Text("직접 기록")
        }
        .buttonStyle(.bordered)
        .opacity(viewModel.recordButtonIsFocused ? 0.000001 : 1)
        .disabled(viewModel.recordButtonIsFocused)
    }
    
    private var recordButtonView: some View {
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
                    if viewModel.info != nil || viewModel.payAmount != -1 {
                        viewModel.manualRecordModalIsShown = true
                    } else {
                        viewModel.resetTranscribedString()
                        viewModel.alertViewIsShown = true
                    }
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
                    viewModel.alertViewIsShown = false
                    do {
                        try viewModel.startSTT()
                    } catch {
                        print("error starting record: \(error.localizedDescription)")
                    }
                    viewModel.startRecording()
                    viewModel.recordButtonIsFocused = true
                default:
                    break
                }
            }
    }
    
    private var alertView: some View {
        ZStack {
            Color(.white)
                .opacity(1)
                .opacity(viewModel.alertViewIsShown ? 1 : 0.0000001)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .layoutPriority(-1)
                    .opacity(viewModel.alertViewIsShown ? 1 : 0.0000001)
                    .shadow(color: .gray, radius: 5)
                
                VStack(spacing: 8) {
                    Image("recordAlert")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("소비내역이나 금액 중 한 가지는 반드시 기록해야 저장할 수 있어요")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 41)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                .opacity(viewModel.alertViewIsShown ? 1 : 0.0000001)
            }
            .padding(.horizontal, 30)
            .offset(y: 160)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(viewModel.alertViewIsShown)
        .onTapGesture {
            viewModel.alertViewIsShown = false
        }
    }
}

#Preview {
    RecordView()
}
