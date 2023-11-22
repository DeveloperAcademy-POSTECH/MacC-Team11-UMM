//
//  InterimPastView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/06.
//

import SwiftUI

struct InterimPastView: View {
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    @State private var currentPage = 0
    @State private var pastCnt = 0
    @State var previousTravel: [Travel]? {
        didSet {
            pastCnt = Int(previousTravel?.count ?? 0)
        }
    }
    
    @Binding var isSelectedTravel: Bool
    
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        ZStack {
            if pastCnt == 0 {
                
                Text("완료된 여행이 없어요")
                    .font(.custom(FontsManager.Pretendard.medium, size: 16))
                    .foregroundStyle(Color(0xA6A6A6))
                
            } else if pastCnt <= 6 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<pastCnt, id: \.self) { index in
                            TravelButtonView(viewModel: viewModel, travel: previousTravel?[index] ?? Travel(), travelCnt: pastCnt, isSelectedTravel: $isSelectedTravel)
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
                            ForEach(0 ..< (pastCnt+5)/6, id: \.self) { page in
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach((page * 6) ..< min((page+1) * 6, pastCnt), id: \.self) { index in
                                            TravelButtonView(viewModel: viewModel, travel: previousTravel?[index] ?? Travel(), travelCnt: pastCnt, isSelectedTravel: $isSelectedTravel)
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
                        ForEach(0..<(pastCnt+5)/6, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.black : Color.gray200)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .offset(y: 95)
                }
            }
        }
        .padding(.top, 30)
        .onAppear {
            DispatchQueue.main.async {
                viewModel.fetchPreviousTravel()
                viewModel.fetchSavedExpense()
                self.previousTravel = viewModel.filterPreviousTravel(todayDate: Date()).filter { $0.name != tempTravelName }
                print("previous OnAppear : ", pastCnt)
            }
        }
    }
}

// #Preview {
//     InterimPastView()
// }
