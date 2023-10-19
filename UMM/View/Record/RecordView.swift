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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    isDetectingPress_letButtonBigger = true
                    print("isDetectingPress_letButtonBigger is now true")
                }
            }
        }
    }
    @State private var isDetectingPress_letButtonBigger = false {
        didSet {
            if !isDetectingPress_letButtonBigger {
                print("isDetectingPress_letButtonBigger is now false")
                DispatchQueue.main.asyncAfter(deadline: .now() + recordButtonAnimationLength) {
                    isDetectingPress_showOnButton = false
                    print("isDetectingPress_showOnButton is now false")
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                travelChoiceView
                rawSentenceView
                livePropertyView
                manualRecordButtonView
                Spacer()
            }
            .ignoresSafeArea()
            
            alertView
            recordButtonView
                .offset(y: 274)
        }
        
        .onAppear {
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
        Button {
            viewModel.travelChoiceHalfModalIsShown = true
            print("viewModel.travelChoiceHalfModalIsShown = true")
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
                        .font(.custom(FontsManager.Pretendard.medium, size: 16))
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
                .font(.custom(FontsManager.Pretendard.semiBold, size: 28))
                .padding(.vertical, 36)
                .hidden()
            
            if !isDetectingPress {
                Text("지출을 기록해주세요")
                    .foregroundStyle(.gray300)
                    .font(.custom(FontsManager.Pretendard.semiBold, size: 28))
                    .padding(.horizontal, 48)
            } else {
                ZStack {
                    ThreeDotsView()
                        .offset(y: -74.5)
                    
                    if viewModel.voiceSentence == "" {
                        Text("듣고 있어요")
                            .foregroundStyle(.gray200)
                            .font(.custom(FontsManager.Pretendard.semiBold, size: 28))
                            .padding(.horizontal, 48)
                    } else {
                        Text(viewModel.voiceSentence)
                            .foregroundStyle(.black)
                            .font(.custom(FontsManager.Pretendard.semiBold, size: 28))
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
                        .font(.custom(FontsManager.Pretendard.medium, size: 16))
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
                        .font(.custom(FontsManager.Pretendard.medium, size: 18))
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
                        .font(.custom(FontsManager.Pretendard.medium, size: 18))
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
                        .font(.custom(FontsManager.Pretendard.medium, size: 16))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .hidden()
                    
                    Text("금액")
                        .foregroundStyle(.gray400)
                        .font(.custom(FontsManager.Pretendard.medium, size: 16))
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
                    Text(String(format: "%.2f", viewModel.payAmount))
                        .foregroundStyle(.black)
                        .font(.custom(FontsManager.Pretendard.medium, size: 18))
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
                        .font(.custom(FontsManager.Pretendard.medium, size: 18))
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
                        .font(.custom(FontsManager.Pretendard.medium, size: 16))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .hidden()
                    
                    Text("결제 방식")
                        .foregroundStyle(.gray400)
                        .font(.custom(FontsManager.Pretendard.medium, size: 16))
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
                        Text("현금")
                            .foregroundStyle(.gray200)
                        Text(" / ")
                            .foregroundStyle(.gray200)
                        Text("카드")
                            .foregroundStyle(.black)
                    }
                    .font(.custom(FontsManager.Pretendard.medium, size: 18))
                case .cash:
                    HStack(spacing: 0) {
                        Image("recordMainPinkCheck")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Spacer()
                            .frame(width: 12)
                        Text("현금")
                            .foregroundStyle(.black)
                        Text(" / ")
                            .foregroundStyle(.gray200)
                        Text("카드")
                            .foregroundStyle(.gray200)
                    }
                    .font(.custom(FontsManager.Pretendard.medium, size: 18))
                default:
                    HStack(spacing: 0) {
                        Image("recordGray100Check")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        Spacer()
                            .frame(width: 12)
                        Text("현금")
                            .foregroundStyle(.gray200)
                        Text(" / ")
                            .foregroundStyle(.gray200)
                        Text("카드")
                            .foregroundStyle(.gray200)
                    }
                    .font(.custom(FontsManager.Pretendard.medium, size: 18))
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
            viewModel.manualRecordModalIsShown = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 11)
                    .foregroundStyle(.white)
                    .layoutPriority(-1)
                
                RoundedRectangle(cornerRadius: 11)
                    .strokeBorder(.gray200, lineWidth: 1)
                    .layoutPriority(-1)
                
                HStack(spacing: 8) {
                    Image("manualRecordPencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("직접 기록")
                        .foregroundStyle(.gray400)
                        .font(.custom(FontsManager.Pretendard.medium, size: 14))
                }
                .padding(.vertical, 9.5)
                .padding(.horizontal, 16)
            }
        }
        .opacity(isDetectingPress ? 0.000001 : 1)
        .disabled(isDetectingPress)
        .padding(.top, 110)
    }
    
    private var recordButtonView: some View {
        VStack {
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
//                    .scaleEffect(isDetectingPress_letButtonBigger ? 1 * (164.0 / 84.0) : (28.0 / 84.0) * (164.0 / 84.0))
                    .scaleEffect(isDetectingPress_letButtonBigger ? 1 : (28.0 / 84.0))
                    .animation(.easeInOut(duration: recordButtonAnimationLength), value: isDetectingPress_letButtonBigger)
                    .opacity(isDetectingPress_showOnButton ? 1 : 0.0000001)
            }
            .gesture(continuousPress)
            .onChange(of: isDetectingPress) { _, newValue in
                if !newValue {
                    print("녹음 끝")
                    isDetectingPress_letButtonBigger = false
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
        LongPressGesture(minimumDuration: 0.01, maximumDistance: 40)
            .sequenced(before: LongPressGesture(minimumDuration: .infinity, maximumDistance: 40))
            .updating($isDetectingPress) { value, state, _ in
                switch value {
                case .second(true, nil):
                    state = true
                    DispatchQueue.main.async {
                        print("녹음 시작")
                        isDetectingPress_showOnButton = true
                    }
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
                .opacity(0.0000001)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .layoutPriority(-1)
                    .opacity(viewModel.alertViewIsShown ? 1 : 0.0000001)
                    .shadow(color: Color(0xACACAC), radius: 5)
                
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

struct ThreeDotsView: View {
    
    @State var timer: Timer?
    @State var level = 0
    @State var flicker = true
    
    let frameLength = 0.5
    
    func levelUp() {
        level = (level + 1) % 3
    }
    
    var body: some View {
        Group {
            ZStack {
                Color(.red)
                    .opacity(0.0000001)
                    .onAppear {
                        timer = Timer.scheduledTimer(withTimeInterval: frameLength, repeats: true) { _ in
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
                .animation(.bouncy(duration: frameLength), value: level)
            }
            .frame(width: 44, height: 17)
        }
    }
}

#Preview {
    RecordView()
}
