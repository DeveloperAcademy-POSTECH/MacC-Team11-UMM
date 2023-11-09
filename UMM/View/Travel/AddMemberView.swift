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
    @State var participantArr: [String]
    @State var travelName: String?
    @State var travelID = UUID()
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var participantCnt = 0
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
        .onDisappear {
            
            if !isBackButton {
                if participantArr.count > 0 {
                    participantCnt -= 1
                    let updateArr = Array(participantArr.dropLast())
                    viewModel.participantArr = updateArr
                } else {
                    viewModel.participantArr = participantArr
                }
                viewModel.startDate = startDate?.local000().convertBeforeSaving()
                viewModel.endDate = endDate?.local235959().convertBeforeSaving()
                
                // 여행 이름
                if let arr = viewModel.participantArr {
                    if arr.count == 1 {
                        viewModel.travelName = "me 나, \(participantArr[0])"
                    } else if arr.count < 1 {
                        viewModel.travelName = "나의 여행"
                    } else {
                        viewModel.travelName = "\(participantArr[0]) 외 \(participantCnt+1)명의 여행"
                    }
                }
                viewModel.travelID = travelID
                viewModel.addTravel()
                viewModel.saveTravel()
                isDisappear = true
            }
        }
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var headerView: some View {
        VStack {
            
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
                print("혼자 하는 여행이에요")
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 1)
                        .stroke(isSelectedAlone ? Color.mainPink : Color.gray200, lineWidth: 1)
                        .frame(width: 350, height: 53)
                    
                    HStack {
                        Image(isSelectedTogether ? "selectUnactive" : "selectActive")
                            .frame(width: 21)
                        
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
                print("여러 명이서 함께하는 여행이에요")
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 1)
                        .stroke(isSelectedTogether ? Color.mainPink : Color.gray200, lineWidth: 1)
                        .frame(width: 350, height: 53)
                    
                    HStack {
                        Image(isSelectedAlone ? "selectUnactive" : "selectActive")
                            .frame(width: 21)
                        
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
                                participantCnt += 1
                                print("participantArr", $viewModel.participantArr)
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
        // LazyVGrid 로 해서 Count에 너비를 개수로 나눈 값으로
        HStack {
            if participantCnt != 0 {
                HStack {
                    ForEach(0..<participantCnt, id: \.self) { index in
                        ZStack {
                            Text(participantArr[index] + "이름입력")
                                .hidden()
                            
                            TextField("", text: $participantArr[index])
                                .modifier(ClearTextFieldButton(text: $participantArr[index]))
                                .font(.custom(FontsManager.Pretendard.medium, size: 16))
                                .foregroundStyle(Color.black)
                                .textFieldStyle(CustomTextFieldStyle())
                                .layoutPriority(-1)
                        }
                        .padding(.horizontal, 5)
                    }
                }
                
            } else {
                Text(" ")
            }
        }
    }
    
    struct ClearTextFieldButton: ViewModifier {
        
        @Binding var text: String
        
        public func body(content: Content) -> some View {
            ZStack(alignment: .trailing) {
                content
                
                if !text.isEmpty || text.isEmpty {
                    Button {
                        self.text = ""
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
    
    // 이슈 : 위에서 만든 히든 뷰의 index 범위 오류
//    struct ClearTextFieldButton: ViewModifier {
//        
//        @Binding var text: String
//        @Binding var participantArr: [String]
//        
//        public func body(content: Content) -> some View {
//            ZStack(alignment: .trailing) {
//                content
//                
//                if !text.isEmpty || text.isEmpty {
//                    Button {
//                        self.text = ""
//                        self.participantArr = Array(self.participantArr.dropLast())
//                    } label: {
//                        Image("xmark 1")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 10, height: 10)
//                            .padding(.trailing, 15)
//                    }
//                }
//            }
//        }
//    }
    
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
            
            if isSelectedTogether == true && participantCnt == 0 {
                DoneButtonUnactive(title: "완료", action: {
                    
                })
                .disabled(true)
                  
            } else {
                NavigationLink(destination: CompleteAddTravelView(addViewModel: addViewModel, 
                                                                  memberViewModel: viewModel,
                                                                  travelID: $travelID,
                                                                  travelNM: travelName ?? "nil",
                                                                  isDisappear: $isDisappear)) {
                    DoneButtonActive(title: "완료", action: {
                        isBackButton = false
                    })
                    .disabled(true)
                }
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
