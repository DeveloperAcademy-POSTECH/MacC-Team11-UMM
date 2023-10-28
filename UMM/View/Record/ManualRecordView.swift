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

    var body: some View {
        ZStack {
            Color(.white)
            VStack(spacing: 0) {
                titleBlockView
                ScrollView {
                    Spacer()
                        .frame(height: 45)
                    payAmountBlockView
                    Spacer()
                        .frame(height: 64)
                    inStringPropertyBlockView
                    Divider()
                        .foregroundStyle(.gray200)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                    notInStringPropertyBlockView
                    
                    VStack {
                        Text("Address Information:")
                        Text("Name: \(viewModel.placemark?.name ?? "N/A")")
                        Text("Locality: \(viewModel.placemark?.locality ?? "N/A")")
                        Text("Administrative Area: \(viewModel.placemark?.administrativeArea ?? "N/A")")
                        Text("Country: \(viewModel.placemark?.country ?? "N/A")")
                    }
                    
                    Spacer()
                        .frame(height: 25)
                }
                saveButtonView
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $viewModel.travelChoiceModalIsShown) {
            TravelChoiceModal(viewModel: viewModel)
                .presentationDetents([.height(289 - 34)])
        }
        .sheet(isPresented: $viewModel.categoryChoiceModalIsShown) {
            CategoryChoiceModal(viewModel: viewModel)
                .presentationDetents([.height(289 - 34)])
        }
        .onTapGesture {
            if viewModel.newNameString.count > 0 {
                viewModel.additionalParticipantTupleArray.append((viewModel.newNameString, true))
            }
            DispatchQueue.main.async {
                viewModel.newNameString = ""
            }
        }
        .onAppear {
            print("ManualRecordView | before | viewModel.country: \(viewModel.country)")
            viewModel.getLocation()
            print("ManualRecordView | after | viewModel.country: \(viewModel.country)")
        }
    }
    
    init(prevViewModel: RecordViewModel) {
        viewModel = ManualRecordViewModel()
        recordViewModel = prevViewModel
        
        if prevViewModel.needToFill {
            viewModel.payAmount = prevViewModel.payAmount
            viewModel.payAmountString = viewModel.payAmount == -1 ? "" : String(viewModel.payAmount)
            viewModel.info = prevViewModel.info
            viewModel.infoString = viewModel.info == nil ? "" : viewModel.info!
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
                
                // MARK: - 현재 위치 정보와 연동
              
//        viewModel.currentCountry = LocationHandler.shared.getCurrentCounty()
//        viewModel.currentLocation = LocationHandler.shared.getCurrentLocation()
        viewModel.currentCountry = .japan
        viewModel.currentLocation = "일본 도쿄"
        viewModel.country = viewModel.currentCountry
        viewModel.locationExpression = viewModel.currentLocation
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
            viewModel.payAmountInWon = viewModel.payAmount * viewModel.currency.rate // ^^^
        }
    }
    
    private var titleBlockView: some View {
        ZStack {
            Color(.white)
                .layoutPriority(-1)
            HStack(spacing: 0) {
                Spacer()
                    .frame(width: 20)
                ZStack {
                    HStack(spacing: 0) {
                        Button {
                            dismiss()
                        } label: {
                            Image("manualRecordTitleLeftChevron")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        
                        Spacer()
                    }
                    
                    Text("기록 완료")
                        .foregroundStyle(.black)
                        .font(.subhead2_1)
                }
                
                Spacer()
                    .frame(width: 20)
            }
        }
        .padding(.top, 68)
        .padding(.bottom, 15)
    }
    
    private var payAmountBlockView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        ZStack {
                            Text(viewModel.payAmountString == "" ? "  -  " : viewModel.payAmountString)
                                .lineLimit(1)
                                .font(.display4)
                                .hidden()
                            
                            TextField(" - ", text: $viewModel.payAmountString)
                                .lineLimit(1)
                                .foregroundStyle(.black)
                                .font(.display4)
                                .keyboardType(.decimalPad)
                                .layoutPriority(-1)
                                .tint(.mainPink)
                        }
                        
                        ZStack {
                            Picker("화폐", selection: $viewModel.currency) {
                                ForEach(viewModel.currencyCandidateArray, id: \.self) { currency in
                                    Text(currency.title + " " + currency.officialSymbol)
                                }
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.gray100)
                                    .layoutPriority(-1)
                                Text(viewModel.currency.title + " " + viewModel.currency.officialSymbol) // viewModel.currency에 연동하기 ^^^
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
                        Text("(" + String(format: "%.2f", viewModel.payAmountInWon) + "원" + ")")
                            .foregroundStyle(.gray300)
                            .font(.caption2)
                    }
                }
                Spacer()
                Button {
                    print("소리 재생 버튼")
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
                        
                        TextField("-", text: $viewModel.infoString) // TextView로 고치기
                            .lineLimit(nil)
                            .foregroundStyle(.black)
                            .font(.body3)
                            .tint(.mainPink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                    }
                    
//                    Spacer()
//                    Button {
//                        print("소비 내역 수정 버튼")
//                    } label: {
//                        Image("manualRecordPencil")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 16, height: 16)
//                    }
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
                            ForEach(0..<(viewModel.participantTupleArray.count + viewModel.additionalParticipantTupleArray.count), id: \.self) { index in
                                let isBasicParticipant = index < viewModel.participantTupleArray.count
                                let tuple: (String, Bool) = isBasicParticipant ? viewModel.participantTupleArray[index] : viewModel.additionalParticipantTupleArray[index - viewModel.participantTupleArray.count]
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .foregroundStyle(tuple.1 == true ? Color(0x333333) : .gray100) // 색상 디자인 시스템 형식으로 고치기 ^^^
                                        .layoutPriority(-1)
                                    
                                    // 높이 설정용 히든 뷰
                                    Text("금")
                                        .lineLimit(1)
                                        .font(.subhead2_2)
                                        .padding(.vertical, 6)
                                        .hidden()
                                    
                                    HStack(spacing: 4) {
                                        if tuple.0 == "나" {
                                            Text("me")
                                                .lineLimit(1)
                                                .foregroundStyle(tuple.1 ? .gray200 : .gray300)
                                                .font(.subhead2_1)
                                        }
                                        Text(tuple.0)
                                            .lineLimit(1)
                                            .foregroundStyle(tuple.1 ? .white : .gray300)
                                            .font(.subhead2_2)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                }
                                .onTapGesture {
                                    print("참여 인원(\(tuple.0)) 참여 여부 설정 버튼")
                                    if isBasicParticipant {
                                        viewModel.participantTupleArray[index].1.toggle()
                                    } else {
                                        viewModel.additionalParticipantTupleArray[index - viewModel.participantTupleArray.count].1.toggle()
                                    }
                                }
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.gray100)
                                    .layoutPriority(-1)
                                
                                // 높이 설정용 히든 뷰
                                Text("금")
                                    .lineLimit(1)
                                    .font(.subhead2_2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .hidden()
                                
                                TextField("╋", text: $viewModel.newNameString) {
                                    print("asdfasdf")
                                    if viewModel.newNameString.count > 0 {
                                        viewModel.additionalParticipantTupleArray.append((viewModel.newNameString, true))
                                    }
                                    DispatchQueue.main.async {
                                        viewModel.newNameString = ""
                                    }
                                }
                                .lineLimit(1)
                                .foregroundStyle(.gray300)
                                .font(.subhead2_2)
                                .padding(.horizontal, 8)
                                .tint(.mainPink)
                            }
                            
                            Spacer()
                                .frame(width: 30)
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
                    
                    Image("manualRecordPencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("지출 일시 수정 버튼")
                        }
                }
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
                                Image("manualRecordExampleJapan") // country와 연동하기
                                    .resizable()
                                    .scaledToFit()
                                
                                Circle()
                                    .strokeBorder(.gray200, lineWidth: 1.0)
                            }
                            .frame(width: 24, height: 24)
                            Text(viewModel.locationExpression)
                        }
                    }
                    
                    Spacer()
                    
                    Image("manualRecordDownChevron")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .onTapGesture {
                            print("지출 위치 수정 버튼")
                        }
                }
                
            }
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var saveButtonView: some View {
        LargeButtonActive(title: "저장하기") {
            viewModel.save()
            recordViewModel.setChosenTravel(as: viewModel.chosenTravel ?? Travel())
            dismiss()
        }
    }
}

#Preview {
    ManualRecordView(prevViewModel: RecordViewModel())
}
