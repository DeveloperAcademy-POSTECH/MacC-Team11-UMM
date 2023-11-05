//
//  FullCompleteModal.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/05.
//

import SwiftUI

struct FullCompleteModal: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var mainVM: MainViewModel
    
    @ObservedObject var viewModel = CompleteAddTravelViewModel()
    @ObservedObject var addViewModel: AddTravelViewModel
    
    @State var travelNM: String
    @State var selectedTravel: [Travel]?
    @Binding var isDisappear: Bool
    @Binding var travelID: UUID
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Spacer()
                
                Text("여행 생성 완료 !")
                    .font(.display2)
                
                travelSquareView
                
                Spacer()
                
                LargeButtonActive(title: "분류 계속하기", action: {
                    presentationMode.wrappedValue.dismiss()
                })
            }
            
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundStyle(Color.gray400)
                    .padding(20)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                viewModel.fetchTravel()
                self.selectedTravel = viewModel.filterTravelByID(selectedTravelID: travelID)
                if let firstParticipant = selectedTravel?.first?.participantArray?.first {
                    self.travelNM = firstParticipant + "와의 여행"
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
                Spacer(minLength: 125)
                
                TextField("나의 여행", text: $travelNM)
                
                Image(systemName: "pencil")
                
                Spacer(minLength: 125)
            }
        }
    }
}

// #Preview {
//     FullCompleteModal()
// }
