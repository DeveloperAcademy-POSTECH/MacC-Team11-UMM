//
//  InterimProceedingView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/06.
//

import SwiftUI

struct InterimProceedingView: View {
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    @State private var currentPage = 0
    @State var proceedingCnt = 0
    @State var nowTravel: [Travel]? {
        didSet {
            proceedingCnt = Int(nowTravel?.count ?? 0)
        }
    }
    
    @Binding var isSelectedTravel: Bool
    
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        ZStack {
            if proceedingCnt == 0 {
                
                Text("현재 진행 중인 여행이 없어요")
                    .font(.custom(FontsManager.Pretendard.medium, size: 16))
                    .foregroundStyle(Color(0xA6A6A6))
                
            } else if proceedingCnt <= Constants.travelCnt {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<proceedingCnt, id: \.self) { index in
                            TravelButtonView(viewModel: viewModel, travel: nowTravel?[index] ?? Travel(), travelCnt: proceedingCnt, isSelectedTravel: $isSelectedTravel)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                    
                    Spacer()
                }
            } else {
                ZStack {
                      ScrollView(.init()) {
                          TabView(selection: $currentPage) {
                              ForEach(0 ..< (proceedingCnt+Constants.travelCnt-1)/Constants.travelCnt, id: \.self) { page in
                                  VStack {
                                      LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                          ForEach((page * Constants.travelCnt) ..< min((page+1) * Constants.travelCnt, proceedingCnt), id: \.self) { index in
                                              TravelButtonView(viewModel: viewModel, travel: nowTravel?[index] ?? Travel(), travelCnt: proceedingCnt, isSelectedTravel: $isSelectedTravel)
                                          }
                                      }
                                      Spacer()
                                  }
                              }
                          }
                          .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                          .padding(.horizontal, 20)
                          .padding(.vertical, 32)
                      }
                      
                      HStack(spacing: 6) {
                          ForEach(0..<(proceedingCnt+Constants.travelCnt-1)/Constants.travelCnt, id: \.self) { index in
                              Capsule()
                                  .fill(currentPage == index ? Color.black : Color.gray200)
                                  .frame(width: 5, height: 5)
                          }
                      }
                      .offset(y: Constants.interimOffset)
                  }
            }
        }
        .padding(.top, 30)
        .onAppear {
            DispatchQueue.main.async {
                viewModel.fetchNowTravel()
                viewModel.fetchSavedExpense()
                self.nowTravel = viewModel.filterTravelByDate(todayDate: Date())
                print("proceedingCnt : ", proceedingCnt )
            }
        }
    }

}

// #Preview {
//     InterimProceedingView()
// }
