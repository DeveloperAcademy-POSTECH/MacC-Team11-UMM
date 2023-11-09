//
//  RecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

import SwiftUI

struct RecordView: View {
    
    init() {
        print("RecordView | init")
    }
    
    let recordButtonAnimationLength = 0.25
    
    @ObservedObject var viewModel = RecordViewModel()
    @EnvironmentObject var mainVM: MainViewModel
    
    @GestureState private var isDetectingPress = false
    @State private var isDetectingPress_showOnButton = false {
        didSet {
            if isDetectingPress_showOnButton {
                withAnimation(.linear(duration: 0.01).delay(0.01)) {
                    isDetectingPress_letButtonBigger = true
                }
            }
        }
    }
    @State private var isDetectingPress_letButtonBigger = false {
        didSet {
            if !isDetectingPress_letButtonBigger {
                withAnimation(.linear(duration: 0.01).delay(recordButtonAnimationLength)) {
                    isDetectingPress_showOnButton = false
                }
            }
        }
    }
    
    let fraction0NumberFormatter = NumberFormatter()
    let fraction1NumberFormatter = NumberFormatter()
    let fraction2NumberFormatter = NumberFormatter()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.white)
                
                VStack(spacing: 0) {
                    travelChoiceView
                    rawSentenceView
                    livePropertyView
                    Spacer()
                        .frame(height: 40) // figma: 64
                    manualRecordButtonView
                    Spacer()
                }
                
                ZStack {
                    Color(.white)
                        .opacity(0.0000001)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        ZStack(alignment: .bottom) {
                            speakWhilePressingView
                            alertView_empty
                            alertView_short
//                            alertView_saved
                        }
                        Spacer()
                            .frame(height: 16)
                        recordButtonView
                            .hidden()
                        Spacer()
                            .frame(height: 18 + 83) // 탭바의 높이를 코드로 구할 수 있으면 83을 대체하기
                    }
                }
                .allowsHitTesting(viewModel.alertView_emptyIsShown || viewModel.alertView_shortIsShown)
                .onTapGesture {
                    viewModel.alertView_emptyIsShown = false
                    viewModel.alertView_shortIsShown = false
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    recordButtonView
                    Spacer()
                        .frame(height: 18 + 83) // 탭바의 높이를 코드로 구할 수 있으면 83을 대체하기
                }
            }
            .ignoresSafeArea()
            .onAppear {
                viewModel.resetInStringProperties()
                viewModel.wantToActivateAutoSaveTimer = true
                if let foundTravelName = findCurrentTravel()?.name {
                    if foundTravelName == "Default" {
                        viewModel.addTravelRequestModalIsShown = true
                    }
                }
                
                // MARK: - NumberFormatter
                
                fraction0NumberFormatter.numberStyle = .decimal
                fraction0NumberFormatter.maximumFractionDigits = 0
                fraction1NumberFormatter.numberStyle = .decimal
                fraction1NumberFormatter.maximumFractionDigits = 1
                fraction2NumberFormatter.numberStyle = .decimal
                fraction2NumberFormatter.maximumFractionDigits = 2
            }
            .sheet(isPresented: $viewModel.travelChoiceModalIsShown) {
                if viewModel.travelChoiceModalIsShown {
                    TravelChoiceInRecordModal(chosenTravel: $mainVM.selectedTravel)
                        .presentationDetents([.height(289 - 34)])
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $viewModel.addTravelRequestModalIsShown) {
                AddTravelRequestModal(viewModel: viewModel)
                    .presentationDetents([.height(247 - 34)])
            }
            .navigationDestination(isPresented: $viewModel.manualRecordViewIsShown) {
                if viewModel.manualRecordViewIsShown {
                    ManualRecordView(
                        given_wantToActivateAutoSaveTimer: viewModel.wantToActivateAutoSaveTimer,
                        given_payAmount: viewModel.payAmount,
                        given_info: viewModel.info,
                        given_infoCategory: viewModel.infoCategory,
                        given_paymentMethod: viewModel.paymentMethod,
                        given_soundRecordFileName: viewModel.soundRecordFileName
                    )
                        .environmentObject(mainVM)
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    private var travelChoiceView: some View {
        Button {
            viewModel.travelChoiceModalIsShown = true
        } label: {
            ZStack {
                Capsule()
                    .foregroundStyle(.white)
                    .layoutPriority(-1)
                
                Capsule()
                    .strokeBorder(.mainPink, lineWidth: 1.0)
                    .layoutPriority(-1)
                
                HStack(spacing: 12) {
                    Text(mainVM.selectedTravel?.name != "Default" ? mainVM.selectedTravel?.name ?? "-" : "임시 기록")
                        .font(.subhead2_2)
                        .foregroundStyle(mainVM.selectedTravel?.name != "Default" ? .black : .gray400)
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
                VStack {
                    Text("지출 내역을 말해주세요")
                        .foregroundStyle(.gray300)
                        .font(.display3)
                    Text("(ex. 빵집, 520엔, 현금으로)")
                        .foregroundStyle(.gray300)
                        .font(.display1)
                }
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
                    
                    // 뷰 크기 설정하기 위한 히든 뷰
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
                    let isClean0 = abs(viewModel.payAmount - Double(Int(viewModel.payAmount))) < 0.0000001
                    let isClean1 = abs(viewModel.payAmount * 10.0 - Double(Int(viewModel.payAmount * 10.0))) < 0.0000001
                    Group {
                        if isClean0 {
                            if let formattedString = fraction0NumberFormatter.string(from: NSNumber(value: viewModel.payAmount)) {
                                Text(formattedString)
                            } else {
                                Text(" ")
                            }
                        } else if isClean1 {
                            if let formattedString = fraction1NumberFormatter.string(from: NSNumber(value: viewModel.payAmount)) {
                                Text(formattedString)
                            } else {
                                Text(" ")
                            }
                        } else {
                            if let formattedString = fraction2NumberFormatter.string(from: NSNumber(value: viewModel.payAmount)) {
                                Text(formattedString)
                            } else {
                                Text(" ")
                            }
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
                    
                    // 뷰 크기 설정하기 위한 히든 뷰
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
            viewModel.wantToActivateAutoSaveTimer = false
            viewModel.manualRecordViewIsShown = true
        } label: {
                HStack(spacing: 4) {
                    Image("recordGrayPencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text("직접 기록")
                        .foregroundStyle(.gray300)
                        .font(.caption2)
                        .underline()
                }
                .padding(.vertical, 9.5)
                .padding(.horizontal, 16)
        }
        .opacity(isDetectingPress ? 0.000001 : 1)
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
                .shadow(color: Color(0xfa395c, alpha: 0.7), radius: isDetectingPress_letButtonBigger ? 8 : 0)
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
                isDetectingPress_letButtonBigger = false
                viewModel.stopSTT()
                viewModel.stopRecording()
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
                        }
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
                    // 녹음 시작 (지점 2: Publishing changes from within view updates 오류 발생 가능)
                    state = true
                    viewModel.startRecordTime = CFAbsoluteTimeGetCurrent()
                    Task {
                        await viewModel.startRecording()
                    }
                    DispatchQueue.main.async {
                        do {
                            try viewModel.startSTT()
                        } catch {
                            print("error starting record: \(error.localizedDescription)")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        isDetectingPress_showOnButton = true
                        viewModel.alertView_emptyIsShown = false
                        viewModel.alertView_shortIsShown = false
                        viewModel.recordButtonIsFocused = true
                        viewModel.wantToActivateAutoSaveTimer = true
                    }
                    
                default:
                    break
                }
            }
    }

    private var alertView_empty: some View {
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
    }
    
    private var alertView_short: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .foregroundStyle(.white)
                .opacity(viewModel.alertView_shortIsShown ? 1 : 0.0000001)
                .shadow(color: Color(0xCCCCCC), radius: 5)
                .layoutPriority(-1)
            
            VStack(spacing: 8) {
                Image("recordAlert")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text("길게 누른 채로 말해주세요")
                    .font(.subhead2_2)
                    .foregroundStyle(.gray300)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 41)
            }
            .padding(.top, 12)
            .padding(.bottom, 16)
            .opacity(viewModel.alertView_shortIsShown ? 1 : 0.0000001)
        }
        .padding(.horizontal, 30)
    }
    
//    private var alertView_saved: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 18)
//                .foregroundStyle(.white)
//                .opacity(mainVM.alertView_savedIsShown ? 1 : 0.0000001)
//                .shadow(color: Color(0xCCCCCC), radius: 5)
//                .layoutPriority(-1)
//            
//            VStack(spacing: 8) {
//                Image("recordBigMainPinkCheck")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 24, height: 24)
//                Text("지출 기록이 저장되었습니다")
//                    .font(.subhead2_2)
//                    .foregroundStyle(.gray300)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 41)
//            }
//            .padding(.top, 12)
//            .padding(.bottom, 16)
//            .opacity(mainVM.alertView_savedIsShown ? 1 : 0.0000001)
//        }
//        .padding(.horizontal, 30)
//    }
    
    private var speakWhilePressingView: some View {
        Text("누르는 동안 말하기")
            .font(.subhead3_2)
            .foregroundStyle(.gray300)
            .multilineTextAlignment(.center)
            .opacity(!isDetectingPress && !viewModel.alertView_emptyIsShown && !viewModel.alertView_shortIsShown ? 1 : 0.0000001)
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
