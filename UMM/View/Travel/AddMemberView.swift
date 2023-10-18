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
    @State var participantArr: [String]
    @State var travelName: String?
    @State var travelID = UUID()
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var participantCnt = 0
    
    var body: some View {
        VStack {
            
            Spacer()
            
            headerView
            
            Spacer()
            
            selectBoxView
            
            Spacer()
            
            isTogetherView
            
            Spacer()
            
            doneButton
            
        }
        .onAppear {
            print(participantArr.count as Any)
        }
        .onDisappear {
            viewModel.participantArr = participantArr
            viewModel.startDate = startDate
            viewModel.endDate = endDate
            viewModel.travelName = participantArr[0] + "외 \(participantCnt)명"
            viewModel.travelID = travelID
            viewModel.addTravel()
            viewModel.saveTravel()
            
            // 저장 Test 코드
//            var fetchedTravel: Travel?
//            do {
//                fetchedTravel = try PersistenceController.shared.container.viewContext.fetch(Travel.fetchRequest()).filter { $0.id == viewModel.travelID }.first
//            } catch {
//                print("err: \(error.localizedDescription)")
//            }
//            print("fetchedTravel.name: \(fetchedTravel?.id ?? UUID())")
        }
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading) {
            Spacer()
            
            Text("누구와 함께하나요?")
                .font(.custom(FontsManager.Pretendard.semiBold, size: 24))
            
            Spacer()
            
            Text("여행 정산을 함께 할 참여자를 설정해요.")
                .font(.custom(FontsManager.Pretendard.medium, size: 24))
                .foregroundStyle(Color.gray300)
            
            Spacer()
        }
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
                        .stroke(isSelectedAlone ? Color.mainPink : Color.gray300, lineWidth: 2)
                        .frame(width: 350, height: 53)
                    
                    HStack {
                        Circle()
                            .foregroundStyle(isSelectedAlone ? Color.mainPink : Color.gray300)
                            .frame(width: 21)
                        
                        Text("정산이 필요 없어요")
                            .foregroundStyle(isSelectedAlone ? Color.black : Color.gray300)
                        
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
                        .stroke(isSelectedTogether ? Color.mainPink : Color.gray300, lineWidth: 2)
                        .frame(width: 350, height: 53)
                    
                    HStack {
                        Circle()
                            .foregroundStyle(isSelectedTogether ? Color.mainPink : Color.gray300)
                            .frame(width: 21)
                        
                        Text("여러 명이서 정산이 필요한 여행이에요")
                            .foregroundStyle(isSelectedTogether ? Color.black : Color.gray300)
                        
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
            HStack {
                if self.isSelectedTogether == true {
                    HStack {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 76, height: 30)
                                .background(Color.gray200)
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
                            participantCnt += 1
                            participantArr.append("")
                            
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
            }
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
               Text("  ")
            }
        }
    }
    
    struct CustomTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(10)
                .foregroundColor(.black)
                .frame(width: 83, height: 30)
                .background(Color(0xD9D9D9))
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
                NavigationLink(destination: CompleteAddTravelView()) {
                    DoneButtonActive(title: "완료", action: {
                    
                    })
                    .disabled(true)
                }
            }
        }
    }
    
    var backButton: some View {
        Button {
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
