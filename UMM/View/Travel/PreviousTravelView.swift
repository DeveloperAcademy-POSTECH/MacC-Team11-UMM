//
//  PreviousTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/19.
//

import SwiftUI

struct PreviousTravelView: View {
    
    @ObservedObject var viewModel = PreviousTravelViewModel()
    @State var previousTravel: [Travel]? {
        didSet {
            travelCnt = Int(previousTravel?.count ?? 0)
        }
    }
    @State var savedExpenses: [Expense]? = []
    @State private var travelCnt: Int = 0
    @State private var currentPage = 0
    @State var flagImageDict: [UUID: [String]] = [:]
    @State var defaultImg: [UUID: [String]] = [:]
    @State private var countryName: [UUID: [String]] = [:]
    
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
                                NavigationLink(destination: TravelDetailView(
                                    travelID: previousTravel?[index].id ?? UUID(),
                                    travelName: previousTravel?[index].name ?? "",
                                    startDate: previousTravel?[index].startDate ?? Date(),
                                    endDate: previousTravel?[index].endDate ?? Date(),
                                    dayCnt: viewModel.differenceBetweenToday(today: Date(), startDate: previousTravel?[index].startDate ?? Date()),
                                    participantCnt: previousTravel?[index].participantArray?.count ?? 0,
                                    participantArr: previousTravel?[index].participantArray ?? [],
                                    flagImageArr: flagImageDict[previousTravel?[index].id ?? UUID()] ?? [],
                                    defaultImageString: defaultImg[previousTravel?[index].id ?? UUID()]?.first ?? "DefaultImage",
                                    koreanNM: countryName[previousTravel?[index].id ?? UUID()] ?? []), label: {
                                        ZStack {
                                            if let imageString = {
                                                return defaultImg[previousTravel?[index].id ?? UUID()]?.first ?? "DefaultImage"
                                            }() {
                                                Image(imageString)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 110, height: 80)
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
                                            
                                            VStack {
                                                
                                                HStack(spacing: 0) {
                                                    Spacer()
                                                    
                                                    ZStack {
                                                        let imageNames = flagImageDict[previousTravel?[index].id ?? UUID()] ?? []
                                                        ForEach((0..<imageNames.count).reversed(), id: \.self) { i in
                                                            Image(imageNames[i])
                                                                .resizable()
                                                                .frame(width: 24, height: 24)
                                                                .shadow(color: .gray400, radius: 4)
                                                                .offset(x: -13 * CGFloat(imageNames.count - 1 - Int(i)))
                                                        }
                                                    }
                                                    Spacer()
                                                        .frame(width: 8)
                                                }
                                                .padding(.top, 8)
                                                //
                                                Spacer()
                                                
                                                VStack(alignment: .leading, spacing: 0) {
                                                    
                                                    HStack {
                                                        Text(previousTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                        
                                                        Text("~")
                                                        
                                                        Spacer()
                                                    }
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.white.opacity(0.75))
                                                    
                                                    Text(previousTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                        .font(.caption2)
                                                        .foregroundStyle(Color.white.opacity(0.75))
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.bottom, 8)
                                            }
                                            .frame(width: 110, height: 80)
                                        }
                                        .onAppear {
                                            self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: previousTravel?[index].id ?? UUID())
                                            
                                            if let savedExpenses = savedExpenses {
                                                let countryValues: [Int64] = savedExpenses.map { expense in
                                                    return viewModel.getCountryForExpense(expense)
                                                }
                                                let uniqueCountryValues = Array(Set(countryValues))
                                                
                                                var flagImageNames: [String] = []
                                                var countryDefaultImg: [String] = []
                                                var koreanName: [String] = []
                                                
                                                for countryValue in uniqueCountryValues {
                                                    
                                                    if let flagString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.flagString {
                                                        flagImageNames.append(flagString)
                                                    } else {
                                                        flagImageNames.append("DefaultFlag")
                                                    }
                                                    
                                                    if let imgString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.defaultImageString {
                                                        countryDefaultImg.append(imgString)
                                                    } else {
                                                        countryDefaultImg.append("DefaultImage")
                                                    }
                                                    
                                                    if let koreanString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.koreanNm {
                                                        koreanName.append(koreanString)
                                                    } else {
                                                        koreanName.append("")
                                                    }
                                                }
                                                self.flagImageDict[previousTravel?[index].id ?? UUID()] = flagImageNames
                                                self.defaultImg[previousTravel?[index].id ?? UUID()] = countryDefaultImg
                                                self.countryName[previousTravel?[index].id ?? UUID()] = koreanName
                                            }
                                        }
                                    })
                                Text(previousTravel?[index].name ?? "제목 미정")
                                    .font(.subhead1)
                                    .lineLimit(1)
                            }
                        }
                    }
                
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
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
                                                                                             participantArr: previousTravel?[index].participantArray ?? [],
                                                                                             flagImageArr: flagImageDict[previousTravel?[index].id ?? UUID()] ?? [], defaultImageString: defaultImg[previousTravel?[index].id ?? UUID()]?.first ?? "DefaultImage",
                                                                                             koreanNM: countryName[previousTravel?[index].id ?? UUID()] ?? []), label: {
                                                    ZStack {
                                                        
                                                        if let imageString = {
                                                            return defaultImg[previousTravel?[index].id ?? UUID()]?.first ?? "DefaultImage"
                                                        }() {
                                                            Image(imageString)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 110, height: 80)
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
                                                        
                                                        VStack {
                                                            
                                                            HStack(spacing: 0) {
                                                                Spacer()
                                                                
                                                                ZStack {
                                                                    let imageNames = flagImageDict[previousTravel?[index].id ?? UUID()] ?? []
                                                                    ForEach((0..<imageNames.count).reversed(), id: \.self) { i in
                                                                        Image(imageNames[i])
                                                                            .resizable()
                                                                            .frame(width: 24, height: 24)
                                                                            .shadow(color: .gray400, radius: 4)
                                                                            .offset(x: -13 * CGFloat(imageNames.count - 1 - Int(i)))
                                                                    }
                                                                }
                                                                Spacer()
                                                                    .frame(width: 8)
                                                            }
                                                            .padding(.top, 8)
//                                                            
                                                            Spacer()
                                                            
                                                            VStack(alignment: .leading, spacing: 0) {
                                                                
                                                                HStack {
                                                                    Text(previousTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                                    
                                                                    Text("~")
                                                                    
                                                                    Spacer()
                                                                }
                                                                .font(.caption2)
                                                                .foregroundStyle(Color.white.opacity(0.75))
                                                                
                                                                Text(previousTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                                    .font(.caption2)
                                                                    .foregroundStyle(Color.white.opacity(0.75))
                                                            }
                                                            .padding(.horizontal, 8)
                                                            .padding(.bottom, 8)
                                                        }
                                                        .frame(width: 110, height: 80)
                                                    }
                                                    .onAppear {
                                                        self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: previousTravel?[index].id ?? UUID())
                                                        
                                                        if let savedExpenses = savedExpenses {
                                                            let countryValues: [Int64] = savedExpenses.map { expense in
                                                                return viewModel.getCountryForExpense(expense)
                                                            }
                                                            let uniqueCountryValues = Array(Set(countryValues))
                                                            
                                                            var flagImageNames: [String] = []
                                                            var countryDefaultImg: [String] = []
                                                            var koreanName: [String] = []
                                                            
                                                            for countryValue in uniqueCountryValues {
                                                                
                                                                if let flagString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.flagString {
                                                                    flagImageNames.append(flagString)
                                                                } else {
                                                                    flagImageNames.append("DefaultFlag")
                                                                }
                                                                
                                                                if let imgString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.defaultImageString {
                                                                    countryDefaultImg.append(imgString)
                                                                } else {
                                                                    countryDefaultImg.append("DefaultImage")
                                                                }
                                                                
                                                                if let koreanString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.koreanNm {
                                                                    koreanName.append(koreanString)
                                                                } else {
                                                                    koreanName.append("")
                                                                }
                                                            }
                                                            self.flagImageDict[previousTravel?[index].id ?? UUID()] = flagImageNames
                                                            self.defaultImg[previousTravel?[index].id ?? UUID()] = countryDefaultImg
                                                            self.countryName[previousTravel?[index].id ?? UUID()] = koreanName
                                                        }
                                                    }
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
                        .padding(.horizontal, 20)
                        .padding(.vertical, 22)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
            
            DispatchQueue.main.async {
                viewModel.fetchTravel()
                viewModel.fetchExpense()
                self.previousTravel = viewModel.filterPreviousTravel(todayDate: Date())
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
}

// #Preview {
//     PreviousTravelView()
// }
