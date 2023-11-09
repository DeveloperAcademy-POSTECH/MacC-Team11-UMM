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
    
    @State private var nowTravel: [Travel]?
    
    @State private var defaultTravel: [Travel]?
    @State private var savedExpenses: [Expense]?
    @State private var defaultExpense: [Expense]?
    @State private var travelCount = 0

    @EnvironmentObject var mainVM: MainViewModel
  
    @State private var currentPage = 0
    @State private var defaultTravelCnt = 0
    @State private var flagImageName: [String] = []
    @State private var defaultImageName: [String] = []
    @State private var countryName: [String] = []

    let dateGapHandler = DateGapHandler.shared
    let handler = ExchangeRateHandler.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleHeader
                    .padding(.bottom, 16)
                
                if travelCount > 0 {
                    
                    nowTravelingView
                    
                } else {
                    ZStack {
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
                            .padding(.bottom, 22)
                    }
                }
                
                tempTravelView
                    .offset(y: -18)
                
                TravelTabView()
            }
            .onAppear {
                viewModel.fetchTravel()
                viewModel.fetchExpense()
                viewModel.fetchDefaultTravel()
                self.nowTravel = viewModel.filterTravelByDate(todayDate: Date())
                self.defaultExpense = viewModel.filterDefaultExpense(selectedTravelName: "Default")
                self.travelCount = Int(nowTravel?.count ?? 0)
                self.defaultTravelCnt = Int(defaultExpense?.count ?? 0)
                self.defaultTravel = viewModel.findTravelNameDefault()
                let loadedData = handler.loadExchangeRatesFromUserDefaults()
                if loadedData == nil || !handler.isSameDate(loadedData?.time_last_update_unix) {
                    handler.fetchAndSaveExchangeRates()
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
        VStack(spacing: 16) {
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
        ZStack(alignment: .center) {
            ScrollView(.init()) {
                TabView(selection: $currentPage) {
                    ForEach(0..<travelCount, id: \.self) { index in
                        let nowTravelWithDummy: [Travel]? = nowTravel != nil ? nowTravel! + [Travel()] : [Travel()]
                        
                        NavigationLink(destination: TravelDetailView(
                            travelID: nowTravelWithDummy?[index].id ?? UUID(),
                            travelName: nowTravelWithDummy?[index].name ?? "",
                            startDate: nowTravelWithDummy?[index].startDate ?? Date(),
                            endDate: nowTravelWithDummy?[index].endDate,
                            dayCnt: viewModel.differenceBetweenToday(today: Date(), startDate: nowTravelWithDummy?[index].startDate ?? Date()),
                            participantCnt: nowTravelWithDummy?[index].participantArray?.count ?? 0,
                            participantArr: nowTravelWithDummy?[index].participantArray ?? [],
                            flagImageArr: self.flagImageName,
                            defaultImageString: String(defaultImageName.first ?? "DefaultImage"),
                            koreanNM: self.countryName
                        ), label: {
                            ZStack(alignment: .top) {
                                
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 350, height: 137 + 46)
                                
                                if let imageString = {
                                    return String(defaultImageName.first ?? "DefaultImage")
                                }() {
                                    Image(imageString)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 350, height: 137)
                                        .cornerRadius(10)
                                        .overlay(
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
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    
                                    HStack(spacing: 0) {
                                        Spacer()
                                        
                                        ZStack {
                                            ForEach((0..<flagImageName.count).reversed(), id: \.self) { i in
                                                Image(flagImageName[i])
                                                    .resizable()
                                                    .frame(width: 24, height: 24)
                                                    .shadow(color: .gray400, radius: 4)
                                                    .offset(x: -12 * CGFloat(flagImageName.count - 1 - Int(i)))
                                            }
                                        }
                                    }
                                    .frame(height: 24)
                                    .padding(.trailing, 16)
                                    
                                    Spacer()
                                    
                                    Group {
                                        Text("Day ")
                                        +
                                        Text("\(viewModel.differenceBetweenToday(today: dateGapHandler.convertBeforeShowing(date: Date()), startDate: dateGapHandler.convertBeforeShowing(date: nowTravelWithDummy?[index].startDate ?? Date()))+1)")
                                    }
                                    .font(.caption1)
                                    .foregroundStyle(Color.white)
                                    .opacity(0.75)
                                    .padding(.leading, 16)
                                    
                                    Text(nowTravelWithDummy?[index].name ?? "제목 미정")
                                        .font(.display1)
                                        .foregroundStyle(Color.white)
                                        .padding(.leading, 16)
                                    
                                    HStack {
                                        HStack(spacing: 0) {
                                            Text(dateGapHandler.convertBeforeShowing(date: nowTravelWithDummy?[index].startDate ?? Date()), formatter: TravelListViewModel.dateFormatter)
                                                .font(.subhead2_2)
                                                .foregroundStyle(Color.white.opacity(0.75))
                                                .padding(.leading, 16)
                                            
                                            Text(" ~ ")
                                                .font(.subhead2_2)
                                                .foregroundStyle(Color.white.opacity(0.75))
                                            
                                            if let endDate = nowTravelWithDummy?[index].endDate {
                                                Text(dateGapHandler.convertBeforeShowing(date: endDate), formatter: TravelListViewModel.dateFormatter)
                                                    .font(.subhead2_2)
                                                    .foregroundStyle(Color.white.opacity(0.75))
                                            } else {
                                                Text("")
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 0) {
                                            HStack {
                                                Image(systemName: "person.fill")
                                                    .frame(width: 12, height: 12)
                                                    .foregroundStyle(Color.white)
                                                
                                                Text("me")
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.white)
                                            }
                                            
                                            Text(viewModel.arrayToString(partArray: nowTravelWithDummy?[index].participantArray ?? [""]))
                                                .lineLimit(1)
                                                .font(.caption2)
                                                .foregroundStyle(Color.white)
                                            
                                        }
                                        .padding(.leading, 50) // Doris : 참여자 뷰 제한을 위한 임의 수치
                                        .padding(.trailing, 16)
                                        
                                    }
                                    .frame(height: 16)
                                    
                                }
                                .padding(.vertical, 16)
                                .frame(width: 350, height: 137)
                                
                            }
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    
                                    self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: nowTravelWithDummy?[index].id ?? UUID())
                                    self.savedExpenses = sortExpenseByDate(expenseArr: savedExpenses)
                                    
                                    if let savedExpenses = savedExpenses {
                                        let countryValues: [Int64] = savedExpenses.map { expense in
                                            return viewModel.getCountryForExpense(expense)
                                        }
                                        let uniqueCountryValues = Array(Set(countryValues))
                                        
                                        var flagImageNames: [String] = []
                                        var defaultImage: [String] = []
                                        var koreanName: [String] = []
                                        
                                        for countryValue in uniqueCountryValues {
                                            
                                            if let flagString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.flagString {
                                                flagImageNames.append(flagString)
                                            } else {
                                                flagImageNames.append("DefaultFlag")
                                            }
                                            
                                            if let defaultString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.defaultImageString {
                                                defaultImage.append(defaultString)
                                            } else {
                                                defaultImage.append("DefaultImage")
                                            }
                                            
                                            if let koreanString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.koreanNm {
                                                koreanName.append(koreanString)
                                            } else {
                                                koreanName.append("")
                                            }
                                        }
                                        
                                        self.flagImageName = flagImageNames
                                        self.defaultImageName = defaultImage
                                        self.countryName = koreanName
                                        print("defaultImageName :", defaultImageName)
                                    }
                                }
                            }
                        })
                    }
                }
                .frame(width: 350, height: 137 + 46)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .frame(width: 350, height: 137 + 46)
            
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
            if defaultTravelCnt == 0 {
                
                EmptyView()
                
            } else {
                
                NavigationLink(destination: InterimRecordView(defaultTravelCnt: $defaultTravelCnt), label: {
                    HStack(alignment: .center, spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 36, height: 36)
                                .shadow(color: Color.black.opacity(0.25), radius: 1, x: 0, y: 0)
                                .overlay(
                                    Image("dollar-circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("분류가 필요한 지출 내역 \(defaultTravelCnt)개")
                                .font(.subhead2_1)
                                .foregroundColor(Color.black)
                            
                            Group {
                                Text("최근 지출 ")
                                +
                                Text("\(viewModel.formatAmount(amount: defaultExpense?.last?.payAmount))")
                                +
                                Text(" ")
                                +
                                Text(CountryInfoModel.shared.countryResult[Int(defaultExpense?.last?.currency ?? -1)]?.relatedCurrencyArray[0] ?? "-")
                            }
                                .font(.caption2)
                                .foregroundColor(Color.gray300)
                        }
                        Spacer()
                    }
                })
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
    
    @State private var currentTab: Int = 0
    
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
                .padding(.top, 36)
            
            TabBarView(currentTab: self.$currentTab)
        }
    }
}

struct TabBarView: View {
    @Binding var currentTab: Int
    @Namespace var namespace
    
    var tabBarOptions: [String] = ["지난 여행", "다가오는 여행"]
    var body: some View {
        HStack(spacing: 30) {
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
