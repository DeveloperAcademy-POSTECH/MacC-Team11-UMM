//
//  TravelListView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI
import CoreLocation

struct TravelListView: View {
    
    @State var month: Date
    @ObservedObject var viewModel = TravelListViewModel()
    @State var nowTravel: [Travel]?
    @State var defaultTravel: [Travel]?
    @State var savedExpenses: [Expense]?
    @State private var travelCount: Int = 0
    @State private var currentPage = 0
    @State var flagImageName: [String] = []
    
    let handler = ExchangeRateHandler.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleHeader
                
                nowTravelingView
                
                tempTravelView
                
                Spacer(minLength: 16)
                
                TravelTabView()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.fetchTravel()
                    viewModel.fetchExpense()
                    self.nowTravel = viewModel.filterTravelByDate(todayDate: Date())
                    self.travelCount = Int(nowTravel?.count ?? 0)
                    self.defaultTravel = viewModel.findTravelNameDefault()
                    let loadedData = handler.loadExchangeRatesFromUserDefaults()
                    if loadedData == nil || !handler.isSameDate(loadedData?.time_last_update_unix) {
                        handler.fetchAndSaveExchangeRates()
                    }
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
                ZStack {
                    ScrollView(.init()) {
                        TabView(selection: $currentPage) {
                            ForEach(0..<travelCount, id: \.self) { index in
                                NavigationLink(destination: TravelDetailView(
                                    travelName: nowTravel?[index].name ?? "",
                                    startDate: nowTravel?[index].startDate ?? Date(),
                                    endDate: nowTravel?[index].endDate ?? Date(),
                                    dayCnt: viewModel.differenceBetweenToday(today: Date(), startDate: nowTravel?[index].startDate ?? Date()),
                                    participantCnt: nowTravel?[index].participantArray?.count ?? 0,
                                    participantArr: nowTravel?[index].participantArray ?? [],
                                    flagImageArr: self.flagImageName
                                ), label: {
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
                                            
                                            HStack {
                                                Spacer()
                                                
                                                ForEach(flagImageName, id: \.self) { imageName in
                                                    Image(imageName)
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                }
                                            }
                                            .padding(16)
                                            
                                            Spacer()
                                            
                                            Group {
                                                Text("Day ")
                                                +
                                                Text("\(viewModel.differenceBetweenToday(today: Date(), startDate: nowTravel?[index].startDate ?? Date()))")
                                            }
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
                                    .onAppear {
                                        self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: nowTravel?[index].id ?? UUID())
                                        
                                        if let savedExpenses = savedExpenses {
                                            let countryValues: [Int64] = savedExpenses.map { expense in
                                                return viewModel.getCountryForExpense(expense)
                                            }
                                            let uniqueCountryValues = Array(Set(countryValues))
                                            
                                            var flagImageNames: [String] = []
                                            for countryValue in uniqueCountryValues {
                                                
                                                if let flagString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.flagString {
                                                    flagImageNames.append(flagString)
                                                } else {
                                                    flagImageNames.append("DefaultFlag")
                                                }
                                            }
                                            self.flagImageName = flagImageNames
                                        }
                                    }
                                })
                            }
                        }
                        .frame(width: 350, height: 230)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                    HStack(spacing: 6) {
                        ForEach(0..<travelCount, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.black : Color.gray200)
                                .frame(width: 5, height: 5)
                        }
                    }
                    .offset(y: 60)
                    .onAppear {
                        let screenWidth = getWidth()
                        self.currentPage = Int(round(offset / screenWidth))
                    }
                }
                .frame(height: 200)
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
    
    private var tempTravelView: some View {
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

extension View {
    func getWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
}

struct TravelTabView: View {
    
    @State var currentTab: Int = 0
    
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
            .padding(.top, 12)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Divider()
                .frame(height: 1)
                .padding(.top, 44)
            
            TabBarView(currentTab: self.$currentTab)
        }
    }
}

struct TabBarView: View {
    @Binding var currentTab: Int
    @Namespace var namespace
    
    var tabBarOptions: [String] = ["지난 여행", "다가오는 여행"]
    var body: some View {
        HStack {
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
        .background(Color.clear)
        .frame(height: 30)
        .padding(.top, 8)
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
