//
//  AddMemberView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/14.
//

import SwiftUI

struct AddMemberView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isSelectedAlone = true
    @State private var isSelectedTogether = false
    
    @ObservedObject private var viewModel = AddMemberViewModel()
    @ObservedObject var addViewModel: AddTravelViewModel
    
    @State var participantArr: [String] {
        didSet {
            print("participantArr.count: \(participantArr.count)")
        }
    }
    @State var travelName: String?
    @State var travelID = UUID()
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var isBackButton = false
    @State var isDisappear = false
    
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        VStack {
            
            headerView
                .padding(.bottom, 45)
            
            selectBoxView
                .padding(.bottom, 26)
            
            isTogetherView
            
            Spacer()
            
            doneButton
            
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            isBackButton = false
        }
        .onAppear(perform: UIApplication.shared.hideKeyboard)
        .navigationDestination(isPresented: $isDisappear) {
            
            CompleteAddTravelView(addViewModel: addViewModel,
                                  memberViewModel: viewModel,
                                  travelID: $travelID,
                                  travelNM: travelName ?? "", 
                                  participantArr: participantArr)
        }
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            
            HStack {
                Text("이 여행은 누구와 함께하나요?")
                    .font(.display2)
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom, 10)
            
            HStack {
                Text("가계부에 표시할 여행 인원의 이름을 알려주세요. ")
                    .font(.subhead2_2)
                    .foregroundStyle(Color.gray300)
                
                Spacer()
            }
            .padding(.leading, 20)
        }
        .padding(.top, 36)
    }
    
    private var selectBoxView: some View {
        VStack {
            Button {
                self.isSelectedAlone = true
                self.isSelectedTogether = false
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 1)
                        .stroke(isSelectedAlone ? Color.mainPink : Color.gray200, lineWidth: 1)
                        .frame(width: 350, height: 53)
                    
                    HStack(spacing: 0) {
                        Image(isSelectedTogether ? "selectUnactive" : "selectActive")
                            .frame(width: 21)
                            .padding(.trailing, 12)
                        
                        Text("정산이 필요 없어요")
                            .foregroundStyle(isSelectedAlone ? Color.black : Color.gray300)
                            .font(.subhead2_1)
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .frame(width: 350, height: 53)
                }
            }
            
            Button {
                self.isSelectedTogether = true
                self.isSelectedAlone = false
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 1)
                        .stroke(isSelectedTogether ? Color.mainPink : Color.gray200, lineWidth: 1)
                        .frame(width: 350, height: 53)
                    
                    HStack(spacing: 0) {
                        Image(isSelectedAlone ? "selectUnactive" : "selectActive")
                            .frame(width: 21)
                            .padding(.trailing, 12)
                        
                        Text("여러 명이서 정산이 필요한 여행이에요")
                            .foregroundStyle(isSelectedTogether ? Color.black : Color.gray300)
                            .font(.subhead2_1)
                        
                        Spacer()
                    }
                    .padding(.leading, 10)
                    .frame(width: 350, height: 53)
                }
            }
        }
    }
    
    private var isTogetherView: some View {
        
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                if self.isSelectedTogether == true {
                    HStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 57, height: 28)
                                .background(Color.gray100)
                                .cornerRadius(6)
                            
                            Text("me")
                                .font(.subhead2_1)
                                .foregroundStyle(Color.gray300)
                            +
                            Text(" 나")
                                .font(.subhead2_2)
                                .foregroundStyle(Color.black)
                        }
                        
                        HStack {
                            participantListView
                            
                            Button {
                                participantArr.append("")
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(Color.gray200)
                                        .frame(width: 32, height: 28)
                                        .cornerRadius(6)
                                    
                                    Image("plus_gray")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 13, height: 13)
                                }
                                
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
    
    private var participantListView: some View {
        HStack {
            HStack {
                ForEach(0..<participantArr.count, id: \.self) { index in
                    ZStack {
                        Text(participantArr[index] + "이름입력이름입력")
                            .hidden()
                        
                        TextField("이름입력", text: $participantArr[index])
                            .modifier(ClearTextFieldButton(text: $participantArr[index], participantArr: $participantArr, index: index))
                            .font(.custom(FontsManager.Pretendard.medium, size: 16))
                            .foregroundStyle(Color.black)
                            .textFieldStyle(CustomTextFieldStyle())
                            .onChange(of: participantArr[index]) { _, newValue in
                                let maxLengthInKorean = 5
                                let maxLengthInEnglish = 8
                                
                                let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
                                let isEnglish = newValue.rangeOfCharacter(from: characterSet.inverted) == nil
                                
                                let maxLength = isEnglish ? maxLengthInEnglish : maxLengthInKorean
                                
                                if newValue.count > maxLength {
                                    participantArr[index] = String(newValue.prefix(maxLength))
                                }
                            }
                            .layoutPriority(-1)
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
    }
    
    struct ClearTextFieldButton: ViewModifier {
        
        @Binding var text: String
        @Binding var participantArr: [String]
        let index: Int
        
        public func body(content: Content) -> some View {
            ZStack(alignment: .trailing) {
                content
                
                if !text.isEmpty || text.isEmpty {
                    Button {
                        participantArr.remove(at: index)
                    } label: {
                        Image("xmark 1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                            .padding(.trailing, 15)
                    }
                }
            }
        }
    }
    
    struct CustomTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(10)
                .foregroundColor(.black)
                .frame(height: 30)
                .background(Color.gray100)
                .cornerRadius(6)
        }
    }
    
    private var doneButton: some View {
        HStack {
            Spacer()
            
            if isSelectedTogether == true && participantArr.count == 0 {
                DoneButtonUnactive(title: "완료", action: {
                    
                })
                .disabled(true)
                
            } else {
                DoneButtonActive(title: "완료", action: {
                    isBackButton = false
                    if !isBackButton {
                        
                        viewModel.startDate = startDate?.local000().convertBeforeSaving()
                        viewModel.endDate = endDate?.local235959().convertBeforeSaving()
                        
                        // 여행 이름
                        if participantArr.count == 1 && self.isSelectedTogether == true {
                            viewModel.travelName = "\(participantArr[0])님과의 여행"
                            viewModel.participantArr = participantArr
                        } else if participantArr.count == 1 && self.isSelectedAlone == true {
                            let updateArr = Array(participantArr.dropLast())
                            viewModel.participantArr = updateArr
                            viewModel.travelName = "나의 여행"
                        } else {
                            viewModel.travelName = "\(participantArr[0]) 외 \(participantArr.count)명의 여행"
                            viewModel.participantArr = participantArr
                        }
                        
                        viewModel.travelID = travelID
                        viewModel.addTravel()
                        viewModel.saveTravel()
                    }
                    isDisappear = true
                })
            }
        }
    }
    
    var backButton: some View {
        Button {
            isBackButton = true
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .imageScale(.large)
                .foregroundColor(Color.black)
        }
    }
}

// #Preview {
//     AddMemberView()
// }
