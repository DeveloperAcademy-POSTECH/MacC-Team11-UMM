//
//  InterimOncomingView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/06.
//

import SwiftUI

struct InterimOncomingView: View {
    
    @State private var currentPage = 0
    @State private var onComingCnt = 0
    @State var onComingTravel: [Travel]? {
        didSet {
            onComingCnt = Int(onComingTravel?.count ?? 0)
        }
    }
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    @Binding var isSelectedTravel: Bool
    
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        ZStack {
            if onComingCnt == 0 {
                
                Text("예정된 여행이 없어요")
                    .font(.custom(FontsManager.Pretendard.medium, size: 16))
                    .foregroundStyle(Color(0xA6A6A6))
                
            } else if onComingCnt <= 6 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<onComingCnt, id: \.self) { index in
                            TravelButtonView(viewModel: viewModel, travel: onComingTravel?[index] ?? Travel(), travelCnt: onComingCnt, isSelectedTravel: $isSelectedTravel)
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
                            ForEach(0 ..< (onComingCnt+5)/6, id: \.self) { page in
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach((page * 6) ..< min((page+1) * 6, onComingCnt), id: \.self) { index in
                                            TravelButtonView(viewModel: viewModel, travel: onComingTravel?[index] ?? Travel(), travelCnt: onComingCnt, isSelectedTravel: $isSelectedTravel)
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
                        ForEach(0..<(onComingCnt+5)/6, id: \.self) { index in
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
                viewModel.fetchUpcomingTravel()
                viewModel.fetchSavedExpense()
                self.onComingTravel = viewModel.filterUpcomingTravel(todayDate: Date())
            }
        }
    }
}

// #Preview {
//     InterimOncomingView()
// }
