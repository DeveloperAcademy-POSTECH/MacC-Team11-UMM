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
                    .background(.black.opacity(0.2))
                
                    .cornerRadius(15.16129)
                
                Text("\(selectedTravel)" as String)
                
            }
            
            HStack {
                Spacer(minLength: 100)
                
                TextField("코어데이터 여행 이름값", text: $travelNM)
                
                Image(systemName: "pencil")
                
                Spacer(minLength: 100)
            }
        }
    }
}

// #Preview {
//     CompleteAddTravelView()
// }
