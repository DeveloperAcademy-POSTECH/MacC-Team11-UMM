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
        .onAppear {
            isBackButton = false
        }
        .onDisappear {
            if !isBackButton {
                if participantArr.count > 0 {
                    participantCnt -= 1
                    let updateArr = Array(participantArr.dropLast())
                    viewModel.participantArr = updateArr
                } else {
                    viewModel.participantArr = participantArr
                }
                viewModel.startDate = startDate
                viewModel.endDate = endDate
                if let arr = viewModel.participantArr {
                    if arr.count > 0 {
                        viewModel.travelName = arr[0] + "외 \(participantCnt)명"
                    } else {
                        viewModel.travelName = "나의 여행"
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
                Text("누구와 함께하나요?")
                    .font(.display2)
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.bottom, 10)
            
            HStack {
                Text("여행 정산을 함께 할 참여자를 설정해요.")
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
                print("정산이 필요 없어요")
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
                print("여러 명이서 정산이 필요한 여행이에요")
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
                                .frame(width: 76, height: 30)
                                .background(Color.gray100)
                                .cornerRadius(15)
                            
                            Text("me")
                                .font(.custom(FontsManager.Pretendard.medium, size: 16))
                                .foregroundStyle(Color.white)
                            +
                            Text(" 나")
                                .font(.custom(FontsManager.Pretendard.medium, size: 16))
                                .foregroundStyle(Color.black)
                        }
                        
                        participantListView
                        
                        Button {
                            participantArr.append("")
                            participantCnt += 1
                            print("participantArr", $viewModel.participantArr)
                        } label: {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 44, height: 30)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .inset(by: 0.5)
                                            .stroke(.black, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                    )
                                
                                Image(systemName: "plus")
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.leading, 36)
            
            Spacer()
        }
    }
    
    private var participantListView: some View {
        // LazyVGrid 로 해서 Count에 너비를 개수로 나눈 값으로
        HStack {
            if participantCnt != 0 {
                ForEach(0..<participantCnt, id: \.self) { index in
                    
                    HStack {
                        
                        TextField("참여자 \(index+1)", text: $participantArr[index])
                            .font(.custom(FontsManager.Pretendard.medium, size: 16))
                            .foregroundStyle(Color.black)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                }
                
            } else {
               Text(" ")
            }
        }
    }
    
    struct CustomTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(10)
                .foregroundColor(.black)
                .frame(width: 83, height: 30)
                .background(Color.gray100)
                .cornerRadius(15)
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
                NavigationLink(destination: CompleteAddTravelView(addViewModel: addViewModel, travelID: $travelID, travelNM: travelName ?? "nil", isDisappear: $isDisappear)) {
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
