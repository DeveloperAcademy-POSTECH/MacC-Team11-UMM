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
                    .foregroundStyle(Color(0xA6A6A6))
            } else if travelCnt <= 6 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0 ..< travelCnt, id: \.self) { index in
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.red)
                                        .frame(width: 110, height: 80)
                                        .cornerRadius(10)
                                    
                                    Text(previousTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                        .font(.caption2)
                                        .foregroundStyle(Color.white.opacity(0.75))
                                    +
                                    Text("~ \n")
                                        .font(.caption2)
                                        .foregroundStyle(Color.white.opacity(0.75))
                                    
                                    +
                                    Text(previousTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                        .font(.caption2)
                                        .foregroundStyle(Color.white.opacity(0.75))
                                    
                                }
                                
                                Text(previousTravel?[index].name ?? "제목 미정")
                                    .font(.subhead1)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                    
                    Spacer()
                }
            } else {
                TabView {
                    ForEach(0 ..< (travelCnt+5)/6, id: \.self) { page in
                        VStack {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                ForEach((page * 6) ..< min((page+1) * 6, travelCnt), id: \.self) { index in
                                    VStack {
                                        ZStack {
                                            Rectangle()
                                                .foregroundColor(.red)
                                                .frame(width: 110, height: 80)
                                                .cornerRadius(10)
                                            
                                            Text(previousTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                .font(.caption2)
                                                .foregroundStyle(Color.white.opacity(0.75))
                                            +
                                            Text("~ \n")
                                                .font(.caption2)
                                                .foregroundStyle(Color.white.opacity(0.75))
                                            
                                            +
                                            Text(previousTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                .font(.caption2)
                                                .foregroundStyle(Color.white.opacity(0.75))
                                            
                                        }
                                        
                                        Text(previousTravel?[index].name ?? "제목 미정")
                                            .font(.subhead1)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .padding(.top, 12)
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
