//
//  CompleteAddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/17.
//

import SwiftUI

struct CompleteAddTravelView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mainVM: MainViewModel
    @ObservedObject var viewModel = CompleteAddTravelViewModel()
    @ObservedObject var addViewModel: AddTravelViewModel
    @ObservedObject var memberViewModel: AddMemberViewModel
    @Binding var travelID: UUID
    @State var travelNM: String
    @State var participantArr: [String]
    @State var selectedTravel: [Travel]?
    
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            Text("여행 생성 완료 !")
                .font(.display2)
                .padding(.bottom, 21)
            
            travelSquareView
                .padding(.bottom, 100)
            
            Spacer()
            
            HStack {
                MediumButtonStroke(title: "여행 확인하기", action: {
                    // 선택값 초기화
                    selectedTravel?.first?.name = travelNM
                    selectedTravel?.first?.participantArray = participantArr
                    mainVM.selectedTravel = self.selectedTravel?.first
                    viewModel.saveTravel()
                    NavigationUtil.popToRootView()
                    addViewModel.startDate = Date()
                    addViewModel.endDate = nil
                })
                
                MediumButtonActive(title: "지출 기록하기", action: {
                    selectedTravel?.first?.name = travelNM
                    selectedTravel?.first?.participantArray = participantArr
                    mainVM.selectedTravel = self.selectedTravel?.first
                    viewModel.saveTravel()
                    NavigationUtil.popToRootView()
                    mainVM.navigationToRecordView()
                })
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            viewModel.fetchTravel()
            self.selectedTravel = viewModel.filterTravelByID(selectedTravelID: travelID)
            self.travelNM = memberViewModel.travelName ?? "제목 미정"
            self.participantArr = memberViewModel.participantArr ?? ["me"]
        }
        .onAppear(perform: UIApplication.shared.hideKeyboard)
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
    }
    
    private var travelSquareView: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 243, height: 176)
                    .background(
                        Image("DefaultImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 243, height: 176) // 원하는 크기로 조정
                            .cornerRadius(15.16129)
                            .overlay(
                                Color.black.opacity(0.2)
                                    .cornerRadius(15.16129)
                            )
                    )
                
                VStack {
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            
                            Text(viewModel.dateToString(in: dateGapHandler.convertBeforeShowing(date: selectedTravel?.first?.startDate ?? Date())) + " ~")
                            
                            if let endDate = selectedTravel?.first?.endDate {
                                Text(dateGapHandler.convertBeforeShowing(date: endDate), formatter: PreviousTravelViewModel.dateFormatter)
                            } else {
                                Text("미정")
                            }
                        }
                        .font(.custom(FontsManager.Pretendard.medium, size: 20))
                        .padding(.top, 90)
                        .padding(.leading, 16)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.75))
                        
                        Spacer()
                    }
                    .frame(width: 243, height: 176)
                    .padding(16)
                }
            }
            .frame(width: 243, height: 176)
            
            HStack {
                Spacer()
                
                TextField(String(viewModel.travelName ?? ""), text: $travelNM)
                    .modifier(ClearTextFieldButton(text: $travelNM))
                    .font(.display1)
                    .textFieldStyle(CustomTextFieldStyle())
                    .onChange(of: travelNM) { _, newValue in
                        let maxLengthInKorean = 18
                        let maxLengthInEnglish = 28
                        
                        let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
                        let isEnglish = newValue.rangeOfCharacter(from: characterSet.inverted) == nil
                        
                        let maxLength = isEnglish ? maxLengthInEnglish : maxLengthInKorean
                        
                        if newValue.count > maxLength {
                            travelNM = String(newValue.prefix(maxLength))
                        }
                    }
                    .layoutPriority(-1)
                
                Spacer()
            }
            .padding(.top, 20)
            .frame(width: 243)
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
                        Image("xmark_circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(.trailing, 8)
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
                .frame(height: 32)
                .background(Color.gray100)
                .cornerRadius(6)
        }
    }
}

// #Preview {
//     CompleteAddTravelView()
// }
