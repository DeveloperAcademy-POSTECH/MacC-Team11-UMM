//
//  ManualRecordView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct ManualRecordView: View {
    @ObservedObject var viewModel: ManualRecordViewModel
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
                }
                saveButtonView
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden()
    }
    
    init(prevViewModel: RecordViewModel) {
        viewModel = ManualRecordViewModel()
        if prevViewModel.needToFill {
            viewModel.payAmount = prevViewModel.payAmount
            //        viewModel.payAmountInWon = ...
            viewModel.payAmountInWon = prevViewModel.payAmount * 9.1 // ^^^
            viewModel.info = prevViewModel.info
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
                        Button {
                            print("금액 수정 버튼")
                        } label: {
                            if viewModel.payAmount == -1 {
                                Text(String("  -  "))
                                    .foregroundStyle(.black)
                                    .font(.display3) // 4로 고치기 ^^^
                            } else {
                                let isClean0 = viewModel.payAmount - Double(Int(viewModel.payAmount)) == 0.0
                                let isClean2 = viewModel.payAmount * 100.0 - Double(Int(viewModel.payAmount * 100.0)) == 0.0
                                
                                if isClean0 {
                                    Text(String(format: "%.0f", viewModel.payAmount))
                                        .lineLimit(1)
                                        .foregroundStyle(.black)
                                        .font(.display3) // 4로 고치기 ^^^
                                } else if isClean2 {
                                    Text(String(format: "%.2f", viewModel.payAmount))
                                        .lineLimit(1)
                                        .foregroundStyle(.black)
                                        .font(.display3) // 4로 고치기 ^^^
                                } else {
                                    Text(String(format: "%.4f", viewModel.payAmount))
                                        .lineLimit(1)
                                        .foregroundStyle(.black)
                                        .font(.display3) // 4로 고치기 ^^^
                                }
                            }
                        }
                        
                        Button {
                            print("통화 수정 버튼")
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .foregroundStyle(.gray100)
                                    .layoutPriority(-1)
                                Text("엔" + " " + "￥") // viewModel.currency에 연동하기 ^^^
                                    .foregroundStyle(.gray400)
                                    .font(.display2)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                    
                    Text("(" + String(format: "%.2f", viewModel.payAmountInWon) + "원" + ")")
                        .foregroundStyle(.gray300)
                        .font(.caption2)
                }
                Spacer()
                Button {
                    print("소리 재생 버튼")
                } label: {
                    Circle()
                        .foregroundStyle(.gray200)
                        .frame(width: 54, height: 54) // replace ^^^
                }
                
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
                    ZStack {
//                        높이 설정용 히든 뷰
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
                        .hidden()
                        
                        Text(viewModel.info ?? "-")
                            .lineLimit(nil)
                            .foregroundStyle(.black)
                            .font(.body3)
                    }
                    Spacer()
                    Button {
                        print("소비 내역 수정 버튼")
                    } label: {
                        Image("manualRecordPencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
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
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(.black, lineWidth: 1.0)
                                .layoutPriority(-1)
                            
                            Text("현금")
                                .foregroundStyle(.black)
                                .font(.subhead2_1)
                                .padding(.horizontal, 12)
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
                    Button {
                        print("카테고리 수정 버튼")
                    } label: {
                        Image("manualRecordDownChevron")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
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
                    Button {
                        print("현금 선택 버튼")
                    } label: {
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
                    
                    Spacer()
                        .frame(width: 6)
                    
                    Button {
                        print("카드 선택 버튼")
                    } label: {
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
            Text("not-in-string properties...")
            Spacer()
                .frame(width: 20)
        }
    }
    
    private var saveButtonView: some View {
        LargeButtonActive(title: "저장하기") {
            viewModel.save()
            dismiss()
        }
    }
}

#Preview {
    ManualRecordView(prevViewModel: RecordViewModel())
}
