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
            } else if travelCnt <= 6 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0 ..< travelCnt, id: \.self) { index in
                            VStack {
                                NavigationLink(destination: TravelDetailView(), label: {
                                    ZStack {
                                        Image("basicImage")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 110, height: 80)
                                            .cornerRadius(10)
                                            .background(
                                                LinearGradient(
                                                    stops: [
                                                        Gradient.Stop(color: .black.opacity(0), location: 0.00),
                                                        Gradient.Stop(color: .black.opacity(0.75), location: 1.00)
                                                    ],
                                                    startPoint: UnitPoint(x: 0.5, y: 0),
                                                    endPoint: UnitPoint(x: 0.5, y: 1)
                                                )
                                            )
                                            .cornerRadius(10)
                                        
                                        Text(upcomingTravel?[index].startDate ?? Date(), formatter: UpcomingTravelViewModel.dateFormatter)
                                            .font(.caption2)
                                            .foregroundStyle(Color.white.opacity(0.75))
                                        +
                                        Text("~ \n")
                                            .font(.caption2)
                                            .foregroundStyle(Color.white.opacity(0.75))
                                        
                                        +
                                        Text(upcomingTravel?[index].endDate ?? Date(), formatter: UpcomingTravelViewModel.dateFormatter)
                                            .font(.caption2)
                                            .foregroundStyle(Color.white.opacity(0.75))
                                    }
                                })
                                
                                Text(upcomingTravel?[index].name ?? "제목 미정")
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
                                        NavigationLink(destination: TravelDetailView(), label: {
                                            ZStack {
                                                Image("basicImage")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 110, height: 80)
                                                    .cornerRadius(10)
                                                    .background(
                                                        LinearGradient(
                                                            stops: [
                                                                Gradient.Stop(color: .black.opacity(0), location: 0.00),
                                                                Gradient.Stop(color: .black.opacity(0.75), location: 1.00)
                                                            ],
                                                            startPoint: UnitPoint(x: 0.5, y: 0),
                                                            endPoint: UnitPoint(x: 0.5, y: 1)
                                                        )
                                                    )
                                                    .cornerRadius(10)
                                                
                                                Text(upcomingTravel?[index].startDate ?? Date(), formatter: UpcomingTravelViewModel.dateFormatter)
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.white.opacity(0.75))
                                                +
                                                Text("~ \n")
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.white.opacity(0.75))
                                                
                                                +
                                                Text(upcomingTravel?[index].endDate ?? Date(), formatter: UpcomingTravelViewModel.dateFormatter)
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.white.opacity(0.75))
                                            }
                                        })
                                        
                                        Text(upcomingTravel?[index].name ?? "제목 미정")
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
                self.upcomingTravel = viewModel.filterUpcomingTravel(todayDate: Date())
                self.travelCnt = Int(upcomingTravel?.count ?? 0)
            }
        }
    }
}

#Preview {
    UpcomingTravelView()
}
