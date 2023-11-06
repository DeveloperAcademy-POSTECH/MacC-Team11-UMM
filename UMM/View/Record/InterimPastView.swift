//
//  InterimPastView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/06.
//

import SwiftUI

struct InterimPastView: View {
    
    @State private var currentPage = 0
    @State private var pastCnt = 0
    @State var previousTravel: [Travel]? {
        didSet {
            pastCnt = Int(previousTravel?.count ?? 0)
        }
    }
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    var body: some View {
        ZStack {
            if pastCnt == 0 {
                
                Text("지난 여행이 없습니다.") // Doris
                
            } else if pastCnt <= 6 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<pastCnt, id: \.self) { index in
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
                ZStack {
                    ScrollView(.init()) {
                        TabView(selection: $currentPage) {
                            ForEach(0 ..< (pastCnt+5)/6, id: \.self) { page in
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach((page * 6) ..< min((page+1) * 6, pastCnt), id: \.self) { index in
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
                    .offset(y: 135)
                }
            }
        }
        .padding(.top, 30)
        .onAppear {
            DispatchQueue.main.async {
                viewModel.fetchPreviousTravel()
                self.previousTravel = viewModel.filterPreviousTravel(todayDate: Date())
                print("previous OnAppear : ", pastCnt)
            }
        }
    }
}

// #Preview {
//     InterimPastView()
// }
