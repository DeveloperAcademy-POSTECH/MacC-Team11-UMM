//
//  TravelButtonView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/14.
//

import SwiftUI

struct TravelButtonView: View {
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    @State var travel: Travel
    @State var travelCnt: Int
    
    @State var chosenTravel: Travel?
    @State var flagImageDict: [UUID: [String]] = [:]
    @State var defaultImg: [UUID: [String]] = [:]
    @State var savedExpenses: [Expense]? = []
    
    @Binding var isSelectedTravel: Bool
    
    let dateGapHandler = DateGapHandler.shared
    
//    @State private var isSelected: Bool = false
//    private func onTravelSelected() {
//        isSelected.toggle()
//        
//        // 여행이 선택되었을 때 추가로 수행해야 할 로직이 있다면 여기에 추가
//        viewModel.chosenTravel = isSelected ? travel : nil
//        if chosenTravel == travel {
//            chosenTravel = nil
//        } else {
//            chosenTravel = travel
//        }
//        isSelectedTravel = (chosenTravel != nil)
//    }
    
    var body: some View {
        VStack {
            Button {
                if chosenTravel == travel {
                    chosenTravel = nil
                } else {
                    chosenTravel = travel
                }
                isSelectedTravel = (chosenTravel != nil)
                viewModel.chosenTravel = chosenTravel
            } label: {
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
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Button {
                                
                            } label: {
                                if chosenTravel != travel {
                                    Circle()
                                        .fill(.black)
                                        .opacity(0.25)
                                        .frame(width: 19, height: 19)
                                        .overlay(
                                            Circle()
                                                .strokeBorder(.white, lineWidth: 1.0)
                                        )
                                } else {
                                    ZStack {
                                        Circle()
                                            .fill(Color(.mainPink))
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(.white, lineWidth: 1.0)
                                            )
                                        Image("circleLabelCheck")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                            // Doris : 국기 들어갈자리
                            
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
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        
                        Spacer()
                        
                        // Doris : 날짜 표시
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 0) {
                                Text(dateGapHandler.convertBeforeShowing(date: travel.startDate ?? Date()), formatter: PreviousTravelViewModel.dateFormatter)
                                
                                Text("~")
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
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 110, height: 80)
                        .foregroundStyle(.gray100)
                        .opacity(chosenTravel == travel ? 0.0 : 0.4)
                }
                .frame(width: 110, height: 80)
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
                            
                        }
                        self.flagImageDict[travel.id ?? UUID()] = flagImageNames
                        self.defaultImg[travel.id ?? UUID()] = countryDefaultImg
                    }
                }
            }
            Text(travel.name ?? "제목 미정")
                .foregroundStyle(chosenTravel == travel ? Color.black : Color.gray300)
                .font(.subhead1)
                .lineLimit(1)
        }
//        .onChange(of: chosenTravel) { _, newChosenTravel in
//            if newChosenTravel != travel {
//                chosenTravel = nil
//            }
//        }
    }
}

// #Preview {
//     TravelButtonView()
// }
