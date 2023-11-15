//
//  TravelItemView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/14.
//

import SwiftUI

struct TravelItemView: View {
    
    @ObservedObject var viewModel = TravelItemViewModel()
    @State var travel: Travel
    @State var travelCnt: Int
    
    @State private var savedExpenses: [Expense]? = []
    @State private var flagImageDict: [UUID: [String]] = [:]
    @State private var defaultImg: [UUID: [String]] = [:]
    @State private var countryName: [UUID: [String]] = [:]
    
    let dateGapHandler = DateGapHandler.shared
    
    var body: some View {
        VStack {
            NavigationLink(destination: TravelDetailView(
                travelID: travel.id ?? UUID(),
                travelName: travel.name ?? "",
                startDate: travel.startDate ?? Date(),
                endDate: travel.endDate ?? Date(),
                dayCnt: viewModel.differenceBetweenToday(today: Date(), startDate: travel.startDate ?? Date()),
                participantCnt: travel.participantArray?.count ?? 0,
                participantArr: travel.participantArray ?? [],
                flagImageArr: flagImageDict[travel.id ?? UUID()] ?? [],
                defaultImageString: defaultImg[travel.id ?? UUID()]?.first ?? "DefaultImage",
                koreanNM: countryName[travel.id ?? UUID()] ?? []), label: {
                    ZStack {
                        if let imageString = {
                            return defaultImg[travel.id ?? UUID()]?.first ?? "DefaultImage"
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
                                    let imageNames = flagImageDict[travel.id ?? UUID()] ?? []
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
                                    Text(dateGapHandler.convertBeforeShowing(date: travel.startDate ?? Date()), formatter: PreviousTravelViewModel.dateFormatter)
                                    
                                    Text("~")
                                    
                                    Spacer()
                                }
                                .font(.caption2)
                                .foregroundStyle(Color.white.opacity(0.75))
                                
                                if let endDate = travel.endDate {
                                    Text(dateGapHandler.convertBeforeShowing(date: endDate), formatter: PreviousTravelViewModel.dateFormatter)
                                        .font(.caption2)
                                        .foregroundStyle(Color.white.opacity(0.75))
                                } else {
                                    Text("미정")
                                        .font(.caption2)
                                        .foregroundStyle(Color.white.opacity(0.75))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.bottom, 8)
                        }
                        .frame(width: 110, height: 80)
                    }
                    .onAppear {
                        
                        viewModel.fetchTravel()
                        viewModel.fetchExpense()
                        
                        self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: travel.id ?? UUID())
                        self.savedExpenses = sortExpenseByDate(expenseArr: savedExpenses)
                        
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
                            self.flagImageDict[travel.id ?? UUID()] = flagImageNames
                            self.defaultImg[travel.id ?? UUID()] = countryDefaultImg
                            self.countryName[travel.id ?? UUID()] = koreanName
                        }
                    }
                })
            
            Text(travel.name ?? "제목 미정")
                .font(.subhead1)
                .lineLimit(1)
        }
    }
}

// #Preview {
//     TravelItemView()
// }
