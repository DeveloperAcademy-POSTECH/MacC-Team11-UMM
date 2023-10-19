//
//  PreviousTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import SwiftUI

struct PreviousTravelView: View {
    
    @ObservedObject var viewModel = PreviousTravelViewModel()
    @State var previousTravel: [Travel]?
    @State private var travelCnt: Int = 0
    
    var body: some View {
        
        ZStack {
            if travelCnt == 0 {
                Text("지난 여행 내역이 없어요")
            } else {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0 ..< travelCnt, id: \.self) { index in
                            Rectangle()
                                .foregroundColor(.red)
                                .frame(width: 110, height: 80)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.fetchTravel()
                self.previousTravel = viewModel.filterPreviouTravel(todayDate: Date())
                self.travelCnt = Int(previousTravel?.count ?? 0)
            }
        }
    }
}

#Preview {
    PreviousTravelView()
}
