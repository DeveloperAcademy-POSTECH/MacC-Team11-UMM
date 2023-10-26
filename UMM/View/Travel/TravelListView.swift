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
    @State var defaultTravel: [Travel]?
    
    var body: some View {
        NavigationStack {
            VStack {
                titleHeader
                
                nowTravelingView
                
                tempTravelView
                
                Spacer()
                
                TravelTabView()
                
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.fetchTravel()
                    self.nowTravel = viewModel.filterTravelByDate(todayDate: Date())
                    self.travelCount = Int(nowTravel?.count ?? 0)
                    self.defaultTravel = viewModel.findTravelNameDefault()
                    print("onAppear")
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
        ZStack(alignment: .top) {
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
                            NavigationLink(destination: TravelDetailView(), label: {
                                ZStack(alignment: .top) {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 350, height: 137 + 46)
                                    
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 350, height: 137)
                                        .background(
                                            Image("testImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                            
                                        )
                                        .cornerRadius(10)
                                    
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 350, height: 137)
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
                                    
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        
                                        Text("Day 3❌")
                                            .font(.caption1)
                                            .foregroundStyle(Color.white)
                                            .opacity(0.75)
                                            .padding(.leading, 16)
                                        
                                        Text(nowTravel?[index].name ?? "제목 미정")
                                            .font(.display1)
                                            .foregroundStyle(Color.white)
                                            .padding(.leading, 16)
                                        
                                        HStack {
                                            Group {
                                                Text(nowTravel?[index].startDate ?? Date(), formatter: TravelListViewModel.dateFormatter) +
                                                Text(" ~ ") +
                                                Text(nowTravel?[index].endDate ?? Date(), formatter: TravelListViewModel.dateFormatter)
                                            }
                                            .font(.subhead2_2)
                                            .foregroundStyle(Color.white.opacity(0.75))
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
                                    .padding(.bottom, 16)
                                    .frame(width: 350, height: 137)
                                    
                                }
                            })
                        }
                    }
                    .frame(width: 350, height: 230)
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
    
    private var tempTravelView: some View {
        // Travel의 "Default" 라는 이름의 여행이 길이가 1이상이면 임시 기록이 존재함
        // 뷰모델에서 Default이름 가진 여행 fetch 필요
        ZStack {
            if defaultTravel?.count == 0 {
                
                EmptyView()
                
            } else {
                HStack(alignment: .center, spacing: 20) {
                    Image("dollar-circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .background(.white)
                        .shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 0)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("분류가 필요한 지출 내역 \(viewModel.defaultTravel.count)개")
                            .font(.subhead2_1)
                            .foregroundColor(Color.black)
                        
                        Text("최근 지출 ❌11,650원❌")
                            .font(.caption2)
                            .foregroundColor(Color.gray300)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .frame(width: 350, alignment: .leading)
                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                .cornerRadius(10)
            }
        }
    }
}

struct TravelTabView: View {
    
    @State var currentTab: Int = 0
//    @State var disableGesture = false
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: self.$currentTab) {
                PreviousTravelView()
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(0)
                
                UpcomingTravelView()
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(1)
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
        .background(Color.clear)
        .frame(height: 10)
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
       
            HStack {
                if currentTab == tab {
                    VStack {
                        
                        Spacer()
                        
                        Text(tabBarItemName)
                            .font(.subhead3_1)
                        
                        Color.black
                            .frame(width: 136, height: 2)
                            .matchedGeometryEffect(id: "underline",
                                                   in: namespace,
                                                   properties: .frame)
                    }
                } else {
                    
                    VStack {
                        
                        Spacer()
                        
                        Text(tabBarItemName)
                            .foregroundStyle(Color.gray300)
                            .font(.subhead3_1)
                        
                        Color.clear.frame(width: 136, height: 2)
                    }
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
