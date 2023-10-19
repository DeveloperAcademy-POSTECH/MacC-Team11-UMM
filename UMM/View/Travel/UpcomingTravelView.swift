//
//  UpcomingTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import SwiftUI

struct UpcomingTravelView: View {
    
    @ObservedObject var viewModel = UpcomingTravelViewModel()
    @State var upcomingTravel: [Travel]?
    @State private var travelCnt: Int = 0
    
    var body: some View {
        ZStack {
            if travelCnt == 0 {
                Text("다가오는 여행 내역이 없어요")
                    .foregroundStyle(Color(0xA6A6A6))
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0 ..< travelCnt, id: \.self) { index in
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 110, height: 80)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.fetchTravel()
                self.upcomingTravel = viewModel.filterUpcomingTravel(todayDate: Date())
                self.travelCnt = Int(upcomingTravel?.count ?? 0)
            }
        }
    }
}

#Preview {
    UpcomingTravelView()
}
