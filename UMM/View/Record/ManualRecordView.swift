//
//  ManualRecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI
import CoreLocation

struct ManualRecordView: View {
    @ObservedObject var viewModel: ManualRecordViewModel
    var recordViewModel: RecordViewModel
    @Environment(\.dismiss) var dismiss
    let viewContext = PersistenceController.shared.container.viewContext
    let exchangeHandler = ExchangeRateHandler.shared
    let fraction0NumberFormatter = NumberFormatter()

    var body: some View {
        ZStack {
            Color(.white)
            VStack(spacing: 0) {
                ScrollView {
                    Spacer()
                        .frame(height: 107 - 9 + 45)
                    payAmountBlockView
                    Spacer()
                        .frame(height: 64)
                    inStringPropertyBlockView
                    Divider()
                        .foregroundStyle(.gray200)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                    notInStringPropertyBlockView
                    Spacer()
                        .frame(height: 150)
                }
            }
            VStack(spacing: 0) {
                Spacer()
                autoSaveTextView
                Spacer()
                    .frame(height: 16)
                saveButtonView
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.white, for: .navigationBar)
        .navigationTitle("기록 완료")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButtonView)
        .sheet(isPresented: $viewModel.travelChoiceModalIsShown) {
            TravelChoiceInRecordModal(chosenTravel: $viewModel.chosenTravel)
                .presentationDetents([.height(289 - 34)])
        }
        .sheet(isPresented: $viewModel.categoryChoiceModalIsShown) {
            CategoryChoiceModal(chosenCategory: $viewModel.category)
                .presentationDetents([.height(289 - 34)])
        }
        .sheet(isPresented: $viewModel.countryChoiceModalIsShown) {
            CountryChoiceModal(chosenCountry: $viewModel.country, countryIsModified: $viewModel.countryIsModified, countryArray: viewModel.otherCountryCandidateArray, currentCountry: viewModel.currentCountry)
                .presentationDetents([.height(289 - 34)])
        }
        .alert(Text("화면 전환 안내"), isPresented: $viewModel.backButtonAlertIsShown) {
            Button {
                viewModel.backButtonAlertIsShown = false
            } label: {
                Text("아니오")
            }
            Button {
                dismiss()
                viewModel.backButtonAlertIsShown = false
            } label: {
                Text("예")
            }
        } message: {Text("현재 화면의 정보를 모두 초기화하고 이전 화면으로 돌아가시겠습니까?")
        }
        .onAppear {
            viewModel.getLocation()
            viewModel.country = viewModel.currentCountry
            viewModel.countryExpression = viewModel.currentCountry.title
            viewModel.locationExpression = viewModel.currentLocation
            
            if !viewModel.otherCountryCandidateArray.contains(viewModel.country) {
                viewModel.otherCountryCandidateArray.append(viewModel.country)
            }
            
            viewModel.currency = viewModel.currentCountry.relatedCurrencyArray.first ?? .usd
            
            if viewModel.currentCountry == .usa {
                viewModel.currencyCandidateArray = [.usd, .krw]
            } else {
                viewModel.currencyCandidateArray = viewModel.currentCountry.relatedCurrencyArray
                if !viewModel.currencyCandidateArray.contains(.usd) {
                    viewModel.currencyCandidateArray.append(.usd)
                }
                if !viewModel.currencyCandidateArray.contains(.krw) {
                    viewModel.currencyCandidateArray.append(.krw)
                }
            }
            
            if viewModel.payAmount == -1 || viewModel.currency == .unknown {
                viewModel.payAmountInWon = -1
            } else {
                viewModel.payAmountInWon = viewModel.payAmount * (exchangeHandler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int(viewModel.currency.rawValue))) ?? -1)
            }
            
            // MARK: - NumberFormatter
            
            fraction0NumberFormatter.numberStyle = .decimal
            fraction0NumberFormatter.maximumFractionDigits = 0
            
            // MARK: - timer
            
            if viewModel.recordButtonIsUsed && (viewModel.payAmount != -1 || viewModel.info != nil) {
                viewModel.secondCounter = 8
                viewModel.autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if let secondCounter = viewModel.secondCounter {
                        if secondCounter > 1 {
                            viewModel.secondCounter! -= 1
                        } else {
                            if viewModel.payAmount != -1 || viewModel.info != nil {
                                viewModel.secondCounter = nil
                                viewModel.save()
                                if viewModel.chosenTravel != nil {
                                    recordViewModel.setChosenTravel(as: viewModel.chosenTravel!)
                                }
                                self.dismiss()
                                timer.invalidate()
                            } else {
                                viewModel.secondCounter = nil
                                timer.invalidate()
                            }
                        }
                    }
                }
            }
        }
        .onDisappear {
            viewModel.autoSaveTimer?.invalidate()
            viewModel.secondCounter = nil
        }
    }
    
    init(prevViewModel: RecordViewModel) {
        viewModel = ManualRecordViewModel()
        recordViewModel = prevViewModel
        
        viewModel.recordButtonIsUsed = prevViewModel.recordButtonIsFocused
        
        if viewModel.recordButtonIsUsed {
            viewModel.payAmount = prevViewModel.payAmount
            if viewModel.payAmount == -1 {
                viewModel.visiblePayAmount = ""
            } else {
                if abs(viewModel.payAmount - Double(Int(viewModel.payAmount))) < 0.0000001 {
                    viewModel.visiblePayAmount = String(format: "%.0f", viewModel.payAmount)
                } else {
                    viewModel.visiblePayAmount = String(viewModel.payAmount)
                }
            }
            viewModel.info = prevViewModel.info
            viewModel.visibleInfo = viewModel.info == nil ? "" : viewModel.info!
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
        
        if viewModel.currentCountry == .usa {
            viewModel.currencyCandidateArray = [.usd, .krw]
        } else {
            viewModel.currencyCandidateArray = viewModel.currentCountry.relatedCurrencyArray
            if !viewModel.currencyCandidateArray.contains(.usd) {
                viewModel.currencyCandidateArray.append(.usd)
            }
            if !viewModel.currencyCandidateArray.contains(.krw) {
                viewModel.currencyCandidateArray.append(.krw)
            }
        }
        
        if viewModel.payAmount == -1 || viewModel.currency == .unknown {
            viewModel.payAmountInWon = -1
        } else {
            viewModel.payAmountInWon = viewModel.payAmount * (exchangeHandler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int(viewModel.currency.rawValue))) ?? -1) // ^^^
        }
        viewModel.soundRecordFileName = prevViewModel.soundRecordFileName
    }
    
    private var backButtonView: some View {
        Button {
            viewModel.autoSaveTimer?.invalidate()
            viewModel.secondCounter = nil
            viewModel.backButtonAlertIsShown = true
            print("back button tapped")
        } label: {
            Image(systemName: "chevron.left")
                .imageScale(.large)
                .foregroundColor(Color.black)
        }
    }
    
    private var payAmountBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        ZStack {
                            Text(viewModel.visiblePayAmount == "" ? "  -  " : viewModel.visiblePayAmount)
                                .lineLimit(1)
                                .font(.display4)
                                .hidden()
                            
                            TextField(" - ", text: $viewModel.visiblePayAmount)
                                .lineLimit(1)
                                .foregroundStyle(.black)
                                .font(.display4)
                                .keyboardType(.decimalPad)
                                .layoutPriority(-1)
                                .tint(.mainPink)
                                .onTapGesture {
                                    viewModel.autoSaveTimer?.invalidate()
                                    viewModel.secondCounter = nil
                                }
                        }
                        
                        ZStack {
                            Picker("화폐", selection: $viewModel.currency) {
                                ForEach(viewModel.currencyCandidateArray, id: \.self) { currency in
                                    Text(currency.title + " " + currency.officialSymbol)
                                }
                            }
                            .onTapGesture {
                                viewModel.autoSaveTimer?.invalidate()
                                viewModel.secondCounter = nil
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.gray100)
                                    .layoutPriority(-1)
                                Text(viewModel.currency.title + " " + viewModel.currency.officialSymbol)
                                    .foregroundStyle(.gray400)
                                    .font(.display2)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                            .allowsHitTesting(false)
                        }
                    }
                    
                    if viewModel.payAmount == -1 {
                        Text("( - 원)")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    } else {
                        if let formattedString = fraction0NumberFormatter.string(from: NSNumber(value: viewModel.payAmountInWon)) {
                            Text("(" + formattedString + "원" + ")")
                                .foregroundStyle(.gray300)
                                .font(.caption2)
                        } else {
                            Text("( - 원)")
                                .foregroundStyle(.gray300)
                                .font(.caption2)
                        }
                    }
                }
                Spacer()
                Button {
                    print("소리 재생 버튼")
                    viewModel.autoSaveTimer?.invalidate()
                    viewModel.secondCounter = nil
                } label: {
                    Circle() // replace ^^^
                        .foregroundStyle(.gray200)
                        .frame(width: 54, height: 54)
                }
                .hidden() // 코어 데이터 저장 기능 구현한 후에 화면에 표시하기 ^^^
                
            }
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var inStringPropertyBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        
                        Text("소비 내역")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack(alignment: .leading) {
//                        높이 설정용 히든 뷰
                        ZStack {
                            Text("금")
                                .foregroundStyle(.black)
                                .font(.subhead2_1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                        }
                        .hidden()
                        
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundStyle(.gray100)
                            .layoutPriority(-1)
                        
                        TextField("-", text: $viewModel.visibleInfo)
                            .lineLimit(nil)
                            .foregroundStyle(.black)
                            .font(.body3)
                            .tint(.mainPink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .onTapGesture {
                                viewModel.autoSaveTimer?.invalidate()
                                viewModel.secondCounter = nil
                            }
                    }
                }
                
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("카테고리")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack {
                        // 높이 설정용 히든 뷰
                        ZStack {
                            Text("금")
                                .foregroundStyle(.black)
                                .font(.subhead2_1)
                                .padding(.vertical, 6)
                        }
                        .hidden()
                        
                        HStack(spacing: 8) {
                            Image(viewModel.category.manualRecordImageString)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text(viewModel.category.visibleDescription)
                                .foregroundStyle(.black)
                                .font(.body3)
                        }
                    }
                    Spacer()
                    Image("manualRecordDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("카테고리 수정 버튼")
                            viewModel.autoSaveTimer?.invalidate()
                            viewModel.secondCounter = nil
                            viewModel.categoryChoiceModalIsShown = true
                        }
                    
                }
                
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("결제 수단")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    
                    Group {
                        if viewModel.paymentMethod == .cash {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.black, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("현금")
                                    .foregroundStyle(.black)
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.gray200, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("현금")
                                    .foregroundStyle(Color(0xbfbfbf)) // 색상 디자인 시스템 형식으로 고치기 ^^^
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        }
                    }
                    .onTapGesture {
                        print("현금 선택 버튼")
                        viewModel.autoSaveTimer?.invalidate()
                        viewModel.secondCounter = nil
                        if viewModel.paymentMethod == .cash {
                            viewModel.paymentMethod = .unknown
                        } else {
                            viewModel.paymentMethod = .cash
                        }
                    }
                    
                    Spacer()
                        .frame(width: 6)
                    
                    Group {
                        if viewModel.paymentMethod == .card {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.black, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("카드")
                                    .foregroundStyle(.black)
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(.gray200, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("카드")
                                    .foregroundStyle(Color(0xbfbfbf)) // 색상 디자인 시스템 형식으로 고치기 ^^^
                                    .font(.subhead2_1)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                            }
                        }
                    }
                    .onTapGesture {
                        print("카드 선택 버튼")
                        viewModel.autoSaveTimer?.invalidate()
                        viewModel.secondCounter = nil
                        if viewModel.paymentMethod == .card {
                            viewModel.paymentMethod = .unknown
                        } else {
                            viewModel.paymentMethod = .card
                        }
                    }
                    
                    Spacer()
                }
            }
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var notInStringPropertyBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("여행 제목")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack {
                        // 높이 설정용 히든 뷰
                        ZStack {
                            Text("금")
                                .foregroundStyle(.black)
                                .font(.subhead2_1)
                                .padding(.vertical, 6)
                        }
                        .hidden()
                        
                        Text(viewModel.chosenTravel?.name != "Default" ? viewModel.chosenTravel?.name ?? "-" : "-")
                            .lineLimit(nil)
                            .foregroundStyle(.black)
                            .font(.subhead2_1)
                    }
                    Spacer()

                    Image("manualRecordDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("여행 선택 버튼")
                            viewModel.autoSaveTimer?.invalidate()
                            viewModel.secondCounter = nil
                            viewModel.travelChoiceModalIsShown = true
                        }
                    
                }
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("결제 인원")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ScrollView(.horizontal) {
                        HStack(spacing: 6) {
                            if viewModel.participantTupleArray.count > 0 {
                                ParticipantArrayView(viewModel: viewModel)
                            } else {
                                EmptyView()
                            }
                        }
                    }
                    .scrollIndicators(.never)

                }
                HStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Spacer()
                            .frame(width: 116, height: 1)
                        Text("지출 일시")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                    ZStack {
                        // 높이 설정용 히든 뷰
                        Text("금")
                            .lineLimit(1)
                            .font(.subhead2_2)
                            .padding(.vertical, 6)
                            .hidden()
                        
                        Text(viewModel.payDate.toString(dateFormat: "yyyy년 M월 d일 a hh:mm"))
                            .foregroundStyle(.black)
                            .font(.subhead2_2)
                    }
                    Spacer()
                    
                    Image("manualRecordDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("지출 일시 수정 버튼")
                            viewModel.autoSaveTimer?.invalidate()
                            viewModel.secondCounter = nil
                        }
                }
                VStack(spacing: 10) {
                    HStack(spacing: 0) {
                        ZStack(alignment: .leading) {
                            Spacer()
                                .frame(width: 116, height: 1)
                            Text("지출 위치")
                                .foregroundStyle(.gray300)
                                .font(.caption2)
                        }
                        ZStack {
                            // 높이 설정용 히든 뷰
                            Text("금")
                                .lineLimit(1)
                                .font(.subhead2_2)
                                .padding(.vertical, 6)
                                .hidden()
                            
                            HStack(spacing: 8) {
                                ZStack {
                                    Image(viewModel.country.flagImageString) // 이뉴머레이션 못 쓰면 수정해야 함
                                        .resizable()
                                        .scaledToFit()
                                    
                                    Circle()
                                        .strokeBorder(.gray200, lineWidth: 1.0)
                                }
                                .frame(width: 24, height: 24)
                                
                                if !viewModel.countryIsModified {
                                    Text(viewModel.countryExpression + " " + viewModel.locationExpression)
                                        .foregroundStyle(.black)
                                        .font(.subhead2_2)
                                } else {
                                    Text(viewModel.countryExpression)
                                        .foregroundStyle(.black)
                                        .font(.subhead2_2)
                                }
                                
                            }
                        }
                        
                        Spacer()
                        
                        Image("manualRecordDownChevron")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .onTapGesture {
                                print("지출 위치 수정 버튼")
                                viewModel.autoSaveTimer?.invalidate()
                                viewModel.secondCounter = nil
                                viewModel.countryChoiceModalIsShown = true
                            }
                    }
                    
                    if viewModel.countryIsModified {
                        HStack(spacing: 0) {
                            ZStack(alignment: .leading) {
                                Spacer()
                                    .frame(width: 116, height: 1)
                                
                                Text(" ")
                                    .foregroundStyle(.gray300)
                                    .font(.caption2)
                            }
                            ZStack(alignment: .leading) {
                                //                        높이 설정용 히든 뷰
                                ZStack {
                                    Text("금")
                                        .foregroundStyle(.black)
                                        .font(.subhead2_1)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                }
                                .hidden()
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.gray100)
                                    .layoutPriority(-1)
                                
                                TextField("-", text: $viewModel.locationExpression)
                                    .lineLimit(nil)
                                    .foregroundStyle(.black)
                                    .font(.body3)
                                    .tint(.mainPink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .onTapGesture {
                                        viewModel.autoSaveTimer?.invalidate()
                                        viewModel.secondCounter = nil
                                    }
                            }
                        }
                    }
                }
                
            }
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var autoSaveTextView: some View {
        Group {
            if let secondCounter = viewModel.secondCounter {
                if secondCounter > 0 && secondCounter <= 3 {
                    Text("\(secondCounter)초 후 자동 저장")
                        .foregroundStyle(.gray300)
                        .font(.body2)
                } else {
                    EmptyView()
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private var saveButtonView: some View {
        ZStack {
            LargeButtonActive(title: "저장하기") {
                viewModel.save()
                var defaultTravel = Travel()
                do {
                    defaultTravel = try viewContext.fetch(Travel.fetchRequest()).filter { $0.name == "Default" }.first ?? Travel()
                } catch {
                    print("error fetching default travel: \(error.localizedDescription)")
                }
                recordViewModel.setChosenTravel(as: viewModel.chosenTravel ?? defaultTravel)
                dismiss()
            }
            .opacity((viewModel.payAmount != -1 || viewModel.info != nil) ? 1 : 0.0000001)
            .allowsHitTesting(viewModel.payAmount != -1 || viewModel.info != nil)
            
            LargeButtonUnactive(title: "저장하기") { }
                .opacity((viewModel.payAmount != -1 || viewModel.info != nil) ? 0.0000001 : 1)
                .allowsHitTesting(!(viewModel.payAmount != -1 || viewModel.info != nil))
        }
    }
}

struct ParticipantArrayView: View {
    @ObservedObject var viewModel: ManualRecordViewModel
    
    let buttonCountInARow = 3
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(0..<((viewModel.participantTupleArray.count - 1) / buttonCountInARow + 1), id: \.self) { rowNum in
                let diff = viewModel.participantTupleArray.count - 1 - rowNum * buttonCountInARow
                if diff == 0 {
                    HStack(spacing: 6) {
                        ParticipantToggleView(viewModel: viewModel, index: rowNum * buttonCountInARow)
                    }
                } else if diff == 1 {
                    HStack(spacing: 6) {
                        ParticipantToggleView(viewModel: viewModel, index: rowNum * buttonCountInARow)
                        ParticipantToggleView(viewModel: viewModel, index: rowNum * buttonCountInARow + 1)
                    }
                } else {
                    HStack(spacing: 6) {
                        ParticipantToggleView(viewModel: viewModel, index: rowNum * buttonCountInARow)
                        ParticipantToggleView(viewModel: viewModel, index: rowNum * buttonCountInARow + 1)
                        ParticipantToggleView(viewModel: viewModel, index: rowNum * buttonCountInARow + 2)
                    }
                }
            }
        }
    }
}

struct ParticipantToggleView: View {
    @ObservedObject var viewModel: ManualRecordViewModel
    let index: Int
    
    var body: some View {
        if index < viewModel.participantTupleArray.count {
            let tuple = viewModel.participantTupleArray[index]
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(tuple.isOn ? Color(0x333333) : .gray100) // 색상 디자인 시스템 형식으로 고치기 ^^^
                    .layoutPriority(-1)
                
                // 높이 설정용 히든 뷰
                Text("금")
                    .lineLimit(1)
                    .font(.subhead2_2)
                    .padding(.vertical, 6)
                    .hidden()
                
                HStack(spacing: 4) {
                    if tuple.name == "나" {
                        Text("me")
                            .lineLimit(1)
                            .foregroundStyle(tuple.isOn ? .gray200 : .gray300)
                            .font(.subhead2_1)
                    }
                    Text(tuple.0)
                        .lineLimit(1)
                        .foregroundStyle(tuple.isOn ? .white : .gray300)
                        .font(.subhead2_2)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
            }
            .onTapGesture {
                print("참여 인원(\(tuple.name)) 참여 여부 설정 버튼")
                viewModel.autoSaveTimer?.invalidate()
                viewModel.secondCounter = nil
                viewModel.participantTupleArray[index].isOn.toggle()
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    ManualRecordView(prevViewModel: RecordViewModel())
}
