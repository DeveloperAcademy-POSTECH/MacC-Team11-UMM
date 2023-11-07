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
    @Binding var travelID: UUID
    @State var travelNM: String
    @State var selectedTravel: [Travel]?
    @Binding var isDisappear: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("여행 생성 완료 !")
                .font(.display2)
                .padding(.bottom, 10)
            
            travelSquareView
            
            Spacer()
            
            HStack {
                MediumButtonStroke(title: "여행 확인하기", action: {
                    // 선택값 초기화
                    NavigationUtil.popToRootView()
                    addViewModel.startDate = Date()
                    addViewModel.endDate = nil
                })
                
                MediumButtonActive(title: "지출 기록하기", action: {
                    NavigationUtil.popToRootView()
                    mainVM.navigationToRecordView()
                    DispatchQueue.main.async {
                        mainVM.selectedTravel = self.selectedTravel?.first
                    }
                })
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("ooooo appear")
                viewModel.fetchTravel()
                self.selectedTravel = viewModel.filterTravelByID(selectedTravelID: travelID)
                if let firstParticipant = selectedTravel?.first?.participantArray?.first {
                    self.travelNM = firstParticipant + "외" + "\(String(describing: selectedTravel?.first?.participantArray?.count))명의 여행"
                } else {
                    self.travelNM = "나의 여행"
                }
            }
        }
        .onDisappear {
            selectedTravel?.first?.name = travelNM
            mainVM.selectedTravel = self.selectedTravel?.first
        }
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
    }
    
    private var travelSquareView: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 141, height: 141)
                    .background(
                        Image("DefaultImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 141, height: 141) // 원하는 크기로 조정
                            .cornerRadius(15.16129)
                            .overlay(
                                Color.black.opacity(0.2)
                                    .cornerRadius(15.16129)
                                )
                    )
                    
                
                Text(viewModel.dateToString(in: selectedTravel?.first?.startDate) + " ~")
                    .font(.custom(FontsManager.Pretendard.medium, size: 20))
                    .padding(.top, 90)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.75))
                
            }
            
            HStack {
                Spacer(minLength: 125)
                
                TextField("나의 여행", text: $travelNM)
                
                Image(systemName: "pencil")
                
                Spacer(minLength: 125)
            }
        }
    }
}

// #Preview {
//     CompleteAddTravelView()
// }
