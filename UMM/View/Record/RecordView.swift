//
//  RecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

import SwiftUI

struct RecordView: View {
    
    let recordButtonAnimationLength = 0.25
    
    @ObservedObject var viewModel = RecordViewModel()
    
    @GestureState private var isDetectingPress = false
    @State private var isDetectingPress_showOnButton = false {
        didSet {
            if isDetectingPress_showOnButton {
                print("isDetectingPress_showOnButton is now true")
                withAnimation(.linear(duration: 0.01).delay(0.01)) {
                    isDetectingPress_letButtonBigger = true
                }
                print("isDetectingPress_letButtonBigger is now true")
            }
        }
    }
    @State private var isDetectingPress_letButtonBigger = false {
        didSet {
            if !isDetectingPress_letButtonBigger {
                print("isDetectingPress_letButtonBigger is now false")
                withAnimation(.linear(duration: 0.01).delay(recordButtonAnimationLength)) {
                    isDetectingPress_showOnButton = false
                }
                print("isDetectingPress_showOnButton is now false")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.white)
                
                VStack(spacing: 0) {
                    travelChoiceView
                    rawSentenceView
                    livePropertyView
                    Spacer()
                }
                
                manualRecordButtonView
                
                Group {
                    alertView_empty
                    alertView_short
                    speakWhilePressingView
                    recordButtonView
                }
            }
            .ignoresSafeArea()
            .onAppear {
                viewModel.resetInStringProperties()
                viewModel.needToFill = true
            }
            .sheet(isPresented: $viewModel.travelChoiceModalIsShown) {
                TravelChoiceInRecordModal(chosenTravel: $viewModel.chosenTravel)
                    .presentationDetents([.height(289 - 34)])
            }
            .navigationDestination(isPresented: $viewModel.manualRecordViewIsShown) {
                ManualRecordView(prevViewModel: viewModel)
            }
        }
    }
    
    private var travelChoiceView: some View {
        Button {
            viewModel.travelChoiceModalIsShown = true
            print("viewModel.travelChoiceModalIsShown = true")
        } label: {
            ZStack {
                Capsule()
                    .foregroundStyle(.white)
                    .layoutPriority(-1)
                
                Capsule()
                    .strokeBorder(.mainPink, lineWidth: 1.0)
                    .layoutPriority(-1)
                
                HStack(spacing: 12) {
                    Text(viewModel.chosenTravel?.name != "Default" ? viewModel.chosenTravel?.name ?? "-" : "-")
                        .font(.subhead2_2)
                        .foregroundStyle(.black)
                    Image("recordTravelChoiceDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .padding(.vertical, 6)
                .padding(.leading, 16)
                .padding(.trailing, 12)
            }
        }
        .padding(.top, 80)
    }
    
    private var rawSentenceView: some View {
        ZStack {
            Text("0000\n0000\n0000\n0000")
                .foregroundStyle(.gray300)
                .font(.display3)
                .padding(.vertical, 36)
                .hidden()
            
            if !isDetectingPress {
                Text("지출을 기록해주세요")
                    .foregroundStyle(.gray300)
                    .font(.display3)
                    .padding(.horizontal, 48)
            } else {
                ZStack {
                    ThreeDotsView()
                        .offset(y: -74.5)
                    
                    if viewModel.voiceSentence == "" {
                        Text("듣고 있어요")
                            .foregroundStyle(.gray200)
                            .font(.display3)
                            .padding(.horizontal, 48)
                    } else {
                        Text(viewModel.voiceSentence)
                            .foregroundStyle(.black)
                            .font(.display3)
                            .padding(.horizontal, 48)
                            .lineLimit(4)
                    }
                }
                
            }
        }
    }
    
    private var livePropertyView: some View {
        VStack(spacing: 18) {
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray100)
                        .layoutPriority(-1)
                    
                    Text("결제 내역")
                        .foregroundStyle(.gray400)
                        .font(.subhead2_2)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                }
                Spacer()
                    .frame(width: 12)
                if viewModel.info != nil {
                    Image("recordMainPinkCheck")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Spacer()
                        .frame(width: 12)
                    Text(viewModel.info!)
                        .foregroundStyle(.black)
                        .font(.subhead3_2)
                        .lineLimit(3)
                } else {
                    Image("recordGray100Check")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Spacer()
                        .frame(width: 12)
                    Text("-")
                        .foregroundStyle(.gray200)
                        .font(.subhead3_2)
                }
                Spacer()
                    .frame(minWidth: 0)
                    .layoutPriority(-2)
            }
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray100)
                        .layoutPriority(-1)
                    
                    Text("결제 내역")
                        .foregroundStyle(.gray400)
                        .font(.subhead2_2)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .hidden()
                    
                    Text("금액")
                        .foregroundStyle(.gray400)
                        .font(.subhead2_2)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                }
                Spacer()
                    .frame(width: 12)
                if viewModel.payAmount != -1 {
                    Image("recordMainPinkCheck")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Spacer()
                        .frame(width: 12)
                    let isClean0 = viewModel.payAmount - Double(Int(viewModel.payAmount)) == 0.0
                    let isClean2 = viewModel.payAmount * 100.0 - Double(Int(viewModel.payAmount * 100.0)) == 0.0
                    Group {
                        if isClean0 {
                            Text(String(format: "%.0f", viewModel.payAmount))
                        } else if isClean2 {
                            Text(String(format: "%.2f", viewModel.payAmount))
                        } else {
                            Text(String(format: "%.4f", viewModel.payAmount))
                        }
                    }
                    .foregroundStyle(.black)
                    .font(.subhead3_2)
                    .lineLimit(3)
                } else {
                    Image("recordGray100Check")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Spacer()
                        .frame(width: 12)
                    Text("-")
                        .foregroundStyle(.gray200)
                        .font(.subhead3_2)
                }
                Spacer()
                    .frame(minWidth: 0)
                    .layoutPriority(-2)
            }
            HStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.gray100)
                        .layoutPriority(-1)
                    
                    Text("결제 내역")
                        .foregroundStyle(.gray400)
                        .font(.subhead2_2)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .hidden()
                    
                    Text("결제 방식")
                        .foregroundStyle(.gray400)
                        .font(.subhead2_2)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                }
                Spacer()
                    .frame(width: 12)
                switch viewModel.paymentMethod {
                case .card:
                    HStack(spacing: 0) {
                        Image("recordMainPinkCheck")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Spacer()
                            .frame(width: 12)
                        Group {
                            Text("현금")
                                .foregroundStyle(.gray200)
                            Text(" / ")
                                .foregroundStyle(.gray200)
                            Text("카드")
                                .foregroundStyle(.black)
                        }
                        .font(.subhead3_2)
                    }
                case .cash:
                    HStack(spacing: 0) {
                        Image("recordMainPinkCheck")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Spacer()
                            .frame(width: 12)
                        Group {
                            Text("현금")
                                .foregroundStyle(.black)
                            Text(" / ")
                                .foregroundStyle(.gray200)
                            Text("카드")
                                .foregroundStyle(.gray200)
                        }
                        .font(.subhead3_2)
                    }
                default:
                    HStack(spacing: 0) {
                        Image("recordGray100Check")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Spacer()
                            .frame(width: 12)
                        Group {
                            Text("현금")
                                .foregroundStyle(.gray200)
                            Text(" / ")
                                .foregroundStyle(.gray200)
                            Text("카드")
                                .foregroundStyle(.gray200)
                        }
                        .font(.subhead3_2)
                    }
                }
                Spacer()
                    .frame(minWidth: 0)
                    .layoutPriority(-2)
            }
        }
        .padding(.horizontal, 63)
    }
    
    private var manualRecordButtonView: some View {
        Button {
            viewModel.needToFill = false
            viewModel.manualRecordViewIsShown = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 11)
                    .foregroundStyle(.white)
                    .layoutPriority(-1)
                
                RoundedRectangle(cornerRadius: 11)
                    .strokeBorder(.gray200, lineWidth: 1)
                    .layoutPriority(-1)
                
                HStack(spacing: 8) {
                    Image("manualRecordBlackPencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("직접 기록")
                        .foregroundStyle(.gray400)
                        .font(.caption2)
                }
                .padding(.vertical, 9.5)
                .padding(.horizontal, 16)
            }
        }
        .opacity(isDetectingPress ? 0.000001 : 1)
        .offset(y: 124.5)
        .disabled(isDetectingPress)
    }
    
    private var recordButtonView: some View {
        ZStack {
            Image("recordButtonOff")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
            Image("recordButtonOn")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
                .shadow(color: Color(0xfa395c, alpha: 0.7), radius: isDetectingPress_letButtonBigger ? 20 : 0)
                .scaleEffect(isDetectingPress_letButtonBigger ? 1 : (28.0 / 84.0))
                .animation(.easeInOut(duration: recordButtonAnimationLength), value: isDetectingPress_letButtonBigger)
                .opacity(isDetectingPress_showOnButton ? 1 : 0.0000001)
        }
        .gesture(continuousPress)
        .onChange(of: isDetectingPress) { oldValue, newValue in
            if !oldValue && newValue {
                // 녹음 시작 (지점 1: 녹음 끝과 순서 뒤집히는 오류 발생 가능)
            } else if oldValue && !newValue {
                // 녹음 끝
                viewModel.endRecordTime = CFAbsoluteTimeGetCurrent()
                print("녹음 끝")
                isDetectingPress_letButtonBigger = false
                viewModel.stopSTT()
//                viewModel.stopRecording()
                print("time diff: \(viewModel.endRecordTime - viewModel.startRecordTime)")
                if Double(viewModel.endRecordTime - viewModel.startRecordTime) < 1.5 {
                    DispatchQueue.main.async {
                        viewModel.alertView_shortIsShown = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        viewModel.resetInStringProperties()
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        if viewModel.info == nil && viewModel.payAmount == -1 {
                            viewModel.resetTranscribedString()
                            viewModel.alertView_emptyIsShown = true
                            viewModel.resetInStringProperties()
                        } else {
                            viewModel.manualRecordViewIsShown = true
                            print("넘어간다 !!!")
                        }
                    }
                }
                    
            }
        }
        .offset(y: 274)
    }
    
    private var continuousPress: some Gesture {
        LongPressGesture(minimumDuration: 0.01, maximumDistance: 40)
            .sequenced(before: LongPressGesture(minimumDuration: .infinity, maximumDistance: 40))
            .updating($isDetectingPress) { value, state, _ in
                switch value {
                case .second(true, nil):
                    // 녹음 시작 (지점 2: Publishing changes from within view updates 오류 발생 가능)
                    state = true
                    print("녹음 시작")
                    viewModel.startRecordTime = CFAbsoluteTimeGetCurrent()
//                    Task {
//                        await viewModel.startRecording()
//                    }
                    DispatchQueue.main.async {
                        do {
                            try viewModel.startSTT()
                        } catch {
                            print("error starting record: \(error.localizedDescription)")
                        }
                        isDetectingPress_showOnButton = true
                        viewModel.alertView_emptyIsShown = false
                        viewModel.alertView_shortIsShown = false
                        viewModel.recordButtonIsFocused = true
                    }
                default:
                    break
                }
            }
    }
    
    private var alertView_empty: some View {
        ZStack {
            Color(.white)
                .opacity(0.0000001)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .foregroundStyle(.white)
                    .opacity(viewModel.alertView_emptyIsShown ? 1 : 0.0000001)
                    .shadow(color: Color(0xCCCCCC), radius: 5)
                    .layoutPriority(-1)
                
                VStack(spacing: 8) {
                    Image("recordAlert")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("소비내역이나 금액 중 한 가지는\n반드시 기록해야 저장할 수 있어요")
                        .font(.subhead2_2)
                        .foregroundStyle(.gray300)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 41)
                }
                .padding(.top, 12)
                .padding(.bottom, 16)
                .opacity(viewModel.alertView_emptyIsShown ? 1 : 0.0000001)
            }
            .padding(.horizontal, 30)
            .offset(y: 167)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(viewModel.alertView_emptyIsShown)
        .onTapGesture {
            viewModel.alertView_emptyIsShown = false
        }
    }
    
    private var alertView_short: some View {
        ZStack {
            Color(.white)
                .opacity(0.0000001)
            ZStack {
                VStack(spacing: 9.34) {
                    Image("recordAlert")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("길게 누른 채로 말해주세요")
                        .font(.subhead3_2)
                        .foregroundStyle(.gray300)
                        .multilineTextAlignment(.center)
                }
                .opacity(viewModel.alertView_shortIsShown ? 1 : 0.0000001)
            }
            .offset(y: 191.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(viewModel.alertView_shortIsShown)
        .onTapGesture {
            viewModel.alertView_shortIsShown = false
        }
    }
    
    private var speakWhilePressingView: some View {
        Text("누르는 동안 말하기")
            .font(.subhead3_2)
            .foregroundStyle(.gray300)
            .multilineTextAlignment(.center)
            .opacity(!isDetectingPress && !viewModel.alertView_emptyIsShown && !viewModel.alertView_shortIsShown ? 1 : 0.0000001)
            .offset(y: 205.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)
    }
}

struct ThreeDotsView: View {
    
    @State var timer: Timer?
    @State var level = 0
    @State var flicker = true
    
    let stepLength = 0.5
    
    func levelUp() {
        level = (level + 1) % 3
    }
    
    var body: some View {
        Group {
            ZStack {
                Color(.red)
                    .opacity(0.0000001)
                    .onAppear {
                        timer = Timer.scheduledTimer(withTimeInterval: stepLength, repeats: true) { _ in
                            levelUp()
                        }
                    }
                    .onDisappear {
                        timer?.invalidate()
                    }
                
                HStack(spacing: 10) {
                    Circle()
                        .foregroundStyle(.gray200)
                        .frame(width: 8, height: 8)
                        .offset(y: level == 0 ? -9 : 0)
                    Circle()
                        .foregroundStyle(.gray200)
                        .frame(width: 8, height: 8)
                        .offset(y: level == 1 ? -9 : 0)
                    Circle()
                        .foregroundStyle(.gray200)
                        .frame(width: 8, height: 8)
                        .offset(y: level == 2 ? -9 : 0)
                }
                .animation(.bouncy(duration: stepLength * 1.25), value: level)
            }
            .frame(width: 44, height: 17)
        }
    }
}

#Preview {
    RecordView()
}
