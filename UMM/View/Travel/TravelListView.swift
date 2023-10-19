//
//  TravelListView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct TravelListView: View {

    @State var month: Date
    @ObservedObject var viewModel = TravelListViewModel()
    @State var nowTravel: [Travel]?
    @State private var travelCount: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                titleHeader
                
                nowTravelingView
                
                tempTravelView
                
                Spacer()
                
                TravelTabView()
                
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.fetchTravel()
                    self.nowTravel = viewModel.filterTravelByDate(todayDate: Date())
                    self.travelCount = Int(nowTravel?.count ?? 0)
//                    print("nowTravel", Int(nowTravel?.count ?? 0))
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        NavigationLink(destination: AddTravelView(), label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.gray300)
                        })
                        
                        NavigationLink(destination: SettingView(), label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.gray300)
                        })
                    }
                }
            }
        }
    }
    
    private var titleHeader: some View {
        VStack(spacing: 20) {
            HStack {
                Text("여행 관리")
                    .font(.display2)
                    .padding(.leading, 20)
                
                Spacer()
            }
        
            HStack {
                Text("진행 중인 여행")
                    .padding(.leading, 20)
                    .font(.subhead3_1)
                Spacer()
            }
        }
    }
    
    private var nowTravelingView: some View {
        // 가로스크롤뷰
        ZStack {
            if travelCount == 0 {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 350, height: 137)
                    .background(
                        ZStack {
                            Color.gray100
                            Text("현재 진행 중인 여행이 없어요")
                                .font(.body2)
                                .foregroundStyle(Color(0xA6A6A6))
                        }
                    )
                    .cornerRadius(10)
            } else {
                TabView {
                    ForEach(0..<travelCount, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 350, height: 137)
                                .background(
                                    Image("testImage")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                    
                                )
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading) {
                                Spacer()
                                
                                Text("Day 3 ! 수정 해야됨 !")
                                    .font(.caption1)
                                    .foregroundStyle(Color.white)
                                    .opacity(0.75)
                                    .padding(.leading, 16)
                                
                                Text(nowTravel?[index].name ?? "제목 미정")
                                    .font(.display1)
                                    .foregroundStyle(Color.white)
                                    .padding(.leading, 16)
                                
                                HStack {
                                    Text("날짜")
                                        .font(.subhead2_2)
                                        .foregroundStyle(Color.white)
                                        .opacity(0.75)
                                        .padding(.leading, 16)
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(Color.white)
                                        
                                        Text(viewModel.arrayToString(partArray: nowTravel?[index].participantArray ?? ["me"]))
                                            .font(.caption2)
                                            .foregroundStyle(Color.white)
                                            
                                    }
                                    .padding(.trailing, 16)
                                }
                            }
                            .frame(width: 350, height: 137)
                            .padding(.bottom, 16)
                            
                        }
                    }
                }
                .frame(width: 350, height: 230)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
    
    private var tempTravelView: some View {
        EmptyView()
    }
}

struct TravelTabView: View {
    
    @State var currentTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: self.$currentTab) {
                PreviousTravelView().tag(0)
                
                UpcomingTravelView().tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            TabBarView(currentTab: self.$currentTab)
        }
    }
}

struct TabBarView: View {
    @Binding var currentTab: Int
    @Namespace var namespace
    
    var tabBarOptions: [String] = ["지난 여행", "다가오는 여행"]
    var body: some View {
        HStack(spacing: 20) {
            ForEach(Array(zip(self.tabBarOptions.indices,
                              self.tabBarOptions)),
                    id: \.0,
            content: { index, name in
                TabBarItem(currentTab: self.$currentTab,
                           namespace: namespace.self,
                           tabBarItemName: name,
                           tab: index)
            })
        }
        .padding(.horizontal)
        .background(Color.white)
        .frame(height: 40)
        .ignoresSafeArea(.all)
    }
}

struct TabBarItem: View {
    
    @Binding var currentTab: Int
    
    let namespace: Namespace.ID
    let tabBarItemName: String
    var tab: Int
    
    var body: some View {
        Button {
            self.currentTab = tab
        } label: {
            VStack {
                
                Spacer()
                
                Text(tabBarItemName)
                
                if currentTab == tab {
                    Color.black
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline",
                                               in: namespace,
                                               properties: .frame)
                } else {
                    Color.clear.frame(height: 2)
                }
            }
            .animation(.spring(), value: self.currentTab)
        }
        .buttonStyle(.plain)
    }
}

// #Preview {
//     TravelListView(month: Date())
// }
