//
//  CompleteAddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/17.
//

import SwiftUI

struct CompleteAddTravelView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = CompleteAddTravelViewModel()
    @ObservedObject var addViewModel: AddTravelViewModel
    @Binding var travelID: UUID
    @State var travelNM: String
    @State var selectedTravel: [Travel]?
    
    @Binding var isDisappear: Bool 
//    {
//        didSet {
//            if isDisappear {
//                print("traveelID", travelID)
//                viewModel.fetchTravel()
//                self.selectedTravel = viewModel.filterTravelByID(selectedTravelID: travelID)
//                print("selectedTravel", selectedTravel!)
//            }
//        }
//    }
    
//    let filteredTravel = CompleteAddTravelViewModel.filterTravelByID(selectedTravelID: selectedTravel?.id ?? UUID())
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("여행 생성 완료 !")
                .font(.display2)
            
            travelSquareView
            
            Spacer()
            
            HStack {
                MediumButtonUnactive(title: "홈으로 가기", action: {
                    // 선택값 초기화
                    NavigationUtil.popToRootView()
                    addViewModel.startDate = Date()
                    addViewModel.endDate = nil
                })
                
                MediumButtonActive(title: "기록하기", action: {
                    NavigationUtil.popToRootView()
                })
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("traveelID", travelID)
                viewModel.fetchTravel()
                self.selectedTravel = viewModel.filterTravelByID(selectedTravelID: travelID)
                print("selectedTravel", selectedTravel!)
//                self.travelNM = ((selectedTravel?.first?.participantArray?[0]) ?? "나") + "와의 여행"
    
                if let participant = selectedTravel?.first?.participantArray?[0] {
                    self.travelNM = participant + "와의 여행"
                } else {
                    self.travelNM = "나의 여행"
                }

            }
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
                        Image("testImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 141, height: 141) // 원하는 크기로 조정
                            .cornerRadius(15.16129)
                    )
                
                Text(viewModel.dateToString(in: selectedTravel?.first?.startDate) + " ~")
                    .font(.custom(FontsManager.Pretendard.medium, size: 20))
                    .padding(.top, 90)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.75))
                
            }
            
            HStack {
                Spacer(minLength: 123)
                
                TextField("나의 여행", text: $travelNM)
                
                Image(systemName: "pencil")
                
                Spacer(minLength: 123)
            }
        }
    }
}

// #Preview {
//     CompleteAddTravelView()
// }
