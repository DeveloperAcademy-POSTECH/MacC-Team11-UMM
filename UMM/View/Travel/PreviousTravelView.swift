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
    @State var previousExpenses: [[Expense]]?
//    @State var allTravels: [Travel] = []
    @State var savedExpenses: [Expense]? = []
    @State var uniqueCountry: [(key: Int, value: [Int64])] = []
    @State private var travelCnt: Int = 0
    @State private var currentPage = 0
//    @State var flagImgArr: [[String]] = [[]]
    @State var flagImageName: [String] = []
    @State var flagImageArray: [[String]] = []
    
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
                                NavigationLink(destination: TravelDetailView(travelName: previousTravel?[index].name ?? "",
                                                                             startDate: previousTravel?[index].startDate ?? Date(),
                                                                             endDate: previousTravel?[index].endDate ?? Date(),
                                                                             dayCnt: viewModel.differenceBetweenToday(today: Date(), startDate: previousTravel?[index].startDate ?? Date()),
                                                                             participantCnt: previousTravel?[index].participantArray?.count ?? 0,
                                                                             participantArr: previousTravel?[index].participantArray ?? []), label: {
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
                                        
                                        VStack(alignment: .leading) {
                                            
                                            HStack {
                                                Spacer()
                                                
//                                                ForEach(flagImageArray[index], id: \.self) { imageName in
//                                                    Image(imageName)
//                                                        .resizable()
//                                                        .frame(width: 24, height: 24)
//                                                }
                                            }
                                            .padding(16)
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Text(previousTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                
                                                Text("~")
                                            }
                                            .font(.caption2)
                                            .foregroundStyle(Color.white.opacity(0.75))
                                            
                                            Text(previousTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                .font(.caption2)
                                                .foregroundStyle(Color.white.opacity(0.75))
                                        }
                                    }
                                    .onAppear {
                                        
                                        if let allTravels = allPreviousTravels {
                                            var allExpenses: [[Expense]] = []
                                            for travel in allTravels {
                                                if let selectedTravelID = travel.id {
                                                    let filteredExpenses = viewModel.filterExpensesByTravel(selectedTravelID: selectedTravelID)
                                                    allExpenses.append(filteredExpenses)
                                                }
                                            }
                                            self.previousExpenses = allExpenses
                                        }
                                        
                                        for index in 0..<(previousExpenses?.count ?? 0) {
                                            if let savedExpenses = previousExpenses?[index] {
                                                    let countryValues: [Int64] = savedExpenses.map { expense in
                                                        return viewModel.getCountryForExpense(expense)
                                                    }
                                                    let uniqueCountryValues = Array(Set(countryValues))
                                                print("index : ", index, "uniqueCountryValues: ", uniqueCountryValues)
                                            }
                                        }

                                        for index in 0..<(previousExpenses?.count ?? 0) {
                                            if let savedExpenses = previousExpenses?[index] {
                                                let countryValues: [Int64] = savedExpenses.map { expense in
                                                    return viewModel.getCountryForExpense(expense)
                                                }
                                                let uniqueCountryValues = Array(Set(countryValues))
                                                
                                                var flagImageNames: [String] = []
                                                for countryValue in uniqueCountryValues {
                                                    do {
                                                        let csvURL = Bundle.main.url(forResource: "CountryList", withExtension: "csv")!
                                                        let result = try createCountryInfoDictionary(from: csvURL)
                                                        if let flagString = result[Int(countryValue)]?.flagString {
                                                            flagImageNames.append(flagString)
                                                        } else {
                                                            flagImageNames.append("DefaultFlag")
                                                        }
                                                    } catch {
                                                        print("Error from csvURL in TravelListView: \(error)")
                                                        flagImageNames.append("DefaultFlag")
                                                    }
                                                }
                                                
                                                flagImageArray.append(flagImageNames)
                                            }
                                        }
                                        print("flagImageArray", flagImageArray)
                                        
                                    }
                                })
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
                            ForEach(0 ..< (travelCnt+5)/6, id: \.self) { page in
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach((page * 6) ..< min((page+1) * 6, travelCnt), id: \.self) { index in
                                            VStack {
                                                NavigationLink(destination: TravelDetailView(travelName: previousTravel?[index].name ?? "",
                                                                                             startDate: previousTravel?[index].startDate ?? Date(),
                                                                                             endDate: previousTravel?[index].endDate ?? Date(),
                                                                                             dayCnt: viewModel.differenceBetweenToday(today: Date(), startDate: previousTravel?[index].startDate ?? Date()),
                                                                                             participantCnt: previousTravel?[index].participantArray?.count ?? 0,
                                                                                             participantArr: previousTravel?[index].participantArray ?? []), label: {
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
                                                            
                                                            HStack {
                                                                Text(previousTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                                
                                                                Text("~")
                                                            }
                                                            .font(.caption2)
                                                            .foregroundStyle(Color.white.opacity(0.75))
                                                            
                                                            Text(previousTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                                .font(.caption2)
                                                                .foregroundStyle(Color.white.opacity(0.75))
                                                        }
                                                        
                                                    }
//                                                    .onAppear {
//                                                        self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: previousTravel?[index].id ?? UUID())
//                                                        
//                                                        if let savedExpenses = savedExpenses {
//                                                            let countryValues: [Int64] = savedExpenses.map { expense in
//                                                                return viewModel.getCountryForExpense(expense)
//                                                            }
//                                                            let uniqueCountryValues = Array(Set(countryValues))
//                                                            
//                                                            var flagImageNames: [String] = []
//                                                            for countryValue in uniqueCountryValues {
//                                                                do {
//                                                                    let csvURL = Bundle.main.url(forResource: "CountryList", withExtension: "csv")!
//                                                                    let result = try createCountryInfoDictionary(from: csvURL)
//                                                                    if let flagString = result[Int(countryValue)]?.flagString {
//                                                                        flagImageNames.append(flagString)
//                                                                    } else {
//                                                                        flagImageNames.append("DefaultFlag")
//                                                                    }
//                                                                } catch {
//                                                                    print("Error from csvURL in TravelListView: \(error)")
//                                                                    flagImageNames.append("DefaultFlag")
//                                                                }
//                                                            }
//                                                            self.flagImageName = flagImageNames
//                                                        }
//                                                    }
                                                })
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
                        ForEach(0..<(travelCnt+5)/6, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.black : Color.gray200)
                                .frame(width: 5, height: 5)
                        }
                    }
                    // TempView 가 있을 땐 125 없을 땐 85
                    .offset(y: 125)
                }
            }
        }
        .padding(.top, 12)
        .onAppear {
            let screenWidth = getWidth()
            self.currentPage = Int(round(offset / screenWidth))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                viewModel.fetchTravel()
                viewModel.fetchExpense()
                self.previousTravel = viewModel.filterPreviousTravel(todayDate: Date())
                self.travelCnt = Int(previousTravel?.count ?? 0)
                
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
    
    private var allPreviousTravels: [Travel]? {
        if let previousTravel = previousTravel {
            return previousTravel.compactMap { $0 }
        }
        return []
    }
    
    private var allPreviousExpenses: [[Expense]]? {
        if let previousExpense = previousExpenses {
            return previousExpense
        }
     return [[]]
    }
}

//struct CountryFlagImage: View {
//    @State var previousTravelCnt: Int
//    @State var flagImgArr: [[String]]
//    @State var flagImgName: [String] = []
//    @State var previousTravel: [Travel]?
//    @ObservedObject var viewModel: PreviousTravelViewModel
//    
//    var body: some View {
//        HStack {
//            Spacer()
//            
//            ForEach(flagImgName, id: \.self) { imageName in
//                Image(imageName)
//                    .resizable()
//                    .frame(width: 24, height: 24)
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.async {
//                viewModel.fetchTravel()
//                viewModel.fetchExpense()
//                self.previousTravel = viewModel.filterPreviousTravel(todayDate: Date())
//                self.previousTravelCnt = Int(previousTravel?.count ?? 0)
//            }
//            print(previousTravelCnt)
//        }
//        .padding(16)
//    }
//}

//#Preview {
//    PreviousTravelView()
//}
