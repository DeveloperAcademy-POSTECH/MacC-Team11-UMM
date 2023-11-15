//
//  PreviousTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import SwiftUI

struct PreviousTravelView: View {
    
    @ObservedObject var viewModel = PreviousTravelViewModel()
    @State var previousTravel: [Travel]? {
        didSet {
            travelCnt = Int(previousTravel?.count ?? 0)
        }
    }
    
    @State private var travelCnt: Int = 0
    @State private var currentPage = 0
    
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        
        ZStack {
            if travelCnt == 0 {
                Text("지난 여행 내역이 없어요")
                    .foregroundStyle(Color(0xA6A6A6))
            } else if travelCnt <= 6 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0 ..< travelCnt, id: \.self) { index in
                            TravelItemView(travel: previousTravel?[index] ?? Travel(), travelCnt: travelCnt)
                        }
                    }
                
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
            } else {
              ZStack {
                    ScrollView(.init()) {
                        TabView(selection: $currentPage) {
                            ForEach(0 ..< (travelCnt+5)/6, id: \.self) { page in
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach((page * 6) ..< min((page+1) * 6, travelCnt), id: \.self) { index in
                                            TravelItemView(travel: previousTravel?[index] ?? Travel(), travelCnt: travelCnt)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 22)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    
                    HStack(spacing: 6) {
                        ForEach(0..<(travelCnt+5)/6, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.black : Color.gray200)
                                .frame(width: 5, height: 5)
                        }
                    }
                    // TempView 가 있을 땐 125 없을 땐 85
                    .offset(y: 125)
                }
            }
        }
        .padding(.top, 12)
        .onAppear {
            let screenWidth = getWidth()
            self.currentPage = Int(round(offset / screenWidth))
            
            DispatchQueue.main.async {
                viewModel.fetchTravel()
                viewModel.fetchExpense()
                self.previousTravel = viewModel.filterPreviousTravel(todayDate: Date()).filter { $0.name != tempTravelName }
            }
        }
    }
    
    private func getWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    private var offset: CGFloat {
        let screenWidth = getWidth()
        return CGFloat(currentPage) * screenWidth
    }
}

// #Preview {
//     PreviousTravelView()
// }
