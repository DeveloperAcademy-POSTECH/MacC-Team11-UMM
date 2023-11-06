//
//  InterimOncomingView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/06.
//

import SwiftUI

struct InterimOncomingView: View {
    
    @State private var currentPage = 0
    @State private var oncomingCnt = 0
    @State var oncomingTravel: [Travel]? {
        didSet {
            oncomingCnt = Int(oncomingTravel?.count ?? 0)
        }
    }
    @State var chosenTravel: Travel?
    @State var flagImageDict: [UUID: [String]] = [:]
    @State var savedExpenses: [Expense]? = []
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    @Binding var isSelectedTravel: Bool
    
    var body: some View {
        ZStack {
            if oncomingCnt == 0 {
                
                Text("다가오는 여행이 없습니다.") // Doris
                
            } else if oncomingCnt <= 6 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<oncomingCnt, id: \.self) { index in
                                VStack {
                                    Button {
                                        chosenTravel = oncomingTravel?[index]
                                        isSelectedTravel = true
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
                                            
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Button {
                                                        chosenTravel = oncomingTravel?[index]
                                                    } label: {
                                                        if chosenTravel != oncomingTravel?[index] {
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
                                                    
                                                    HStack {
                                                        Spacer()
                                                        
                                                        ForEach(flagImageDict[oncomingTravel?[index].id ?? UUID()] ?? [], id: \.self) { imageName in
                                                            Image(imageName)
                                                                .resizable()
                                                                .frame(width: 24, height: 24)
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.top, 8)
                                                
                                                Spacer()
                                                
                                                // Doris : 날짜 표시
                                                VStack(alignment: .leading, spacing: 0) {
                                                    HStack {
                                                        Text(oncomingTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                        
                                                        Text("~")
                                                    }
                                                    .font(.caption2)
                                                    .foregroundStyle(Color.white.opacity(0.75))
                                                    
                                                    Text(oncomingTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                        .font(.caption2)
                                                        .foregroundStyle(Color.white.opacity(0.75))
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.bottom, 8)
                                            }
                                                                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(width: 110, height: 80)
                                                .foregroundStyle(.gray100)
                                                .opacity(chosenTravel == oncomingTravel?[index] ? 0.0 : 0.3)
                                        }
                                        .frame(width: 110, height: 80)
                                        .onAppear {
                                            
                                            self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: oncomingTravel?[index].id ?? UUID())
                                            
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
                                                self.flagImageDict[oncomingTravel?[index].id ?? UUID()] = flagImageNames
                                            }
                                        }
                                    }
                                    Text(oncomingTravel?[index].name ?? "제목 미정")
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
                            ForEach(0 ..< (oncomingCnt+5)/6, id: \.self) { page in
                                VStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                        ForEach((page * 6) ..< min((page+1) * 6, oncomingCnt), id: \.self) { index in
                                            VStack {
                                                Button {
                                                    chosenTravel = oncomingTravel?[index]
                                                    isSelectedTravel = true
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
                                                        
                                                        VStack(alignment: .leading) {
                                                            HStack {
                                                                Button {
                                                                    chosenTravel = oncomingTravel?[index]
                                                                } label: {
                                                                    if chosenTravel != oncomingTravel?[index] {
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
                                                                
                                                                HStack {
                                                                    Spacer()
                                                                    
                                                                    ForEach(flagImageDict[oncomingTravel?[index].id ?? UUID()] ?? [], id: \.self) { imageName in
                                                                        Image(imageName)
                                                                            .resizable()
                                                                            .frame(width: 24, height: 24)
                                                                    }
                                                                }
                                                            }
                                                            .padding(.horizontal, 8)
                                                            .padding(.top, 8)
                                                            
                                                            Spacer()
                                                            
                                                            // Doris : 날짜 표시
                                                            VStack(alignment: .leading, spacing: 0) {
                                                                HStack {
                                                                    Text(oncomingTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                                    
                                                                    Text("~")
                                                                }
                                                                .font(.caption2)
                                                                .foregroundStyle(Color.white.opacity(0.75))
                                                                
                                                                Text(oncomingTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                                    .font(.caption2)
                                                                    .foregroundStyle(Color.white.opacity(0.75))
                                                            }
                                                            .padding(.horizontal, 8)
                                                            .padding(.bottom, 8)
                                                        }
                                                                                                        
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .frame(width: 110, height: 80)
                                                            .foregroundStyle(.gray100)
                                                            .opacity(chosenTravel == oncomingTravel?[index] ? 0.0 : 0.3)
                                                    }
                                                    .frame(width: 110, height: 80)
                                                    .onAppear {
                                                        
                                                        self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: oncomingTravel?[index].id ?? UUID())
                                                        
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
                                                            self.flagImageDict[oncomingTravel?[index].id ?? UUID()] = flagImageNames
                                                        }
                                                    }
                                                }
                                                
                                                Text(oncomingTravel?[index].name ?? "제목 미정")
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
                        ForEach(0..<(oncomingCnt+5)/6, id: \.self) { index in
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