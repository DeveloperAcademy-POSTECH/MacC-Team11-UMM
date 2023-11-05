//
//  InterimOncomingView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/06.
//

import SwiftUI

struct InterimOncomingView: View {
    
    @State private var isModalPresented = false
    @State private var currentPage = 0
    @State private var oncomingCnt = 0
    @State var oncomingTravel: [Travel]? {
        didSet {
            oncomingCnt = Int(oncomingTravel?.count ?? 0)
        }
    }
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    var body: some View {
        ZStack {
            if oncomingCnt == 0 {
                
                NewTravelButton {
                    isModalPresented.toggle()
                }
                .sheet(isPresented: $isModalPresented) {
                    FullCalendarModal()
                }
                
            } else if oncomingCnt <= 5 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<oncomingCnt+1, id: \.self) { index in
                            if index == 0 {
                                
                                NewTravelButton {
                                    isModalPresented.toggle()
                                }
                                .sheet(isPresented: $isModalPresented) {
                                    FullCalendarModal()
                                }
                                
                            } else {
                                VStack {
                                    Button {
                                        print("index : ", index)
                                    } label: {
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
                                        }
                                    }
                                    Text(oncomingTravel?[index-1].name ?? "제목 미정")
                                        .font(.subhead1)
                                        .lineLimit(1)
                                }
                            }
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
                            ForEach(0 ..< (oncomingCnt+6)/6, id: \.self) { page in
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach((page * 6) ..< min((page+1) * 6, oncomingCnt+1), id: \.self) { index in
                                            
                                            if index == 0 {
                                                
                                                NewTravelButton {
                                                    isModalPresented.toggle()
                                                }
                                                .sheet(isPresented: $isModalPresented) {
                                                    FullCalendarModal()
                                                }
                                                
                                            } else {
                                                VStack {
                                                    Button {
                                                        
                                                    } label: {
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
                                                            
                                                        }
                                                    }
                                                    Text(oncomingTravel?[index-1].name ?? "제목 미정")
                                                        .font(.subhead1)
                                                        .lineLimit(1)
                                                }
                                            }
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
                        ForEach(0..<(oncomingCnt+6)/6, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.black : Color.gray200)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .offset(y: 135)
                }
            }
        }
        .padding(.top, 30)
        .onAppear {
            DispatchQueue.main.async {
                viewModel.fetchUpcomingTravel()
                self.oncomingTravel = viewModel.filterUpcomingTravel(todayDate: Date())
            }
        }
    }
}

// #Preview {
//     InterimOncomingView()
// }
