//
//  InterimProceedingView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/06.
//

import SwiftUI

struct InterimProceedingView: View {
    
    @State private var isModalPresented = false
    @State private var currentPage = 0
    @State var proceedingCnt = 0
    @State var nowTravel: [Travel]? {
        didSet {
            proceedingCnt = Int(nowTravel?.count ?? 0)
        }
    }
    @State var chosenTravel: Travel?
    @State var flagImageDict: [UUID: [String]] = [:]
    @State var savedExpenses: [Expense]? = []
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    var body: some View {
        ZStack {
            if proceedingCnt == 0 {
                
                NewTravelButton {
                    isModalPresented.toggle()
                }
                .sheet(isPresented: $isModalPresented) {
                    FullCalendarModal()
                }
                
            } else if proceedingCnt <= 5 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<proceedingCnt+1, id: \.self) { index in
                            if index == 0 {
                                
                                NewTravelButton {
                                    isModalPresented.toggle()
                                }
                                .sheet(isPresented: $isModalPresented) {
                                    FullCalendarModal()
                                }
                                
                            } else {
                                VStack {
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
                                        
                                        VStack {
                                            HStack {
                                                Button {
                                                    chosenTravel = nowTravel?[index-1]
                                                } label: {
                                                    if chosenTravel != nowTravel?[index-1] {
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
                                                    
                                                    ForEach(flagImageDict[nowTravel?[index-1].id ?? UUID()] ?? [], id: \.self) { imageName in
                                                        Image(imageName)
                                                            .resizable()
                                                            .frame(width: 24, height: 24)
                                                    }
                                                }
                                            }
                                            .padding(16)
                                            
                                            Spacer()
                                            
                                            // Doris : 날짜 표시
                                            HStack {
                                                Text(nowTravel?[index-1].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                
                                                Text("~")
                                            }
                                            .font(.caption2)
                                            .foregroundStyle(Color.white.opacity(0.75))
                                            
                                            Text(nowTravel?[index-1].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                .font(.caption2)
                                                .foregroundStyle(Color.white.opacity(0.75))
                                        }
                                    }
                                    .onAppear {
                                        
                                        self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: nowTravel?[index-1].id ?? UUID())
                                        
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
                                            self.flagImageDict[nowTravel?[index-1].id ?? UUID()] = flagImageNames
                                        }
                                    }
                                    
                                    Text(nowTravel?[index-1].name ?? "제목 미정")
                                        .font(.subhead1)
                                        .lineLimit(1)
                                }
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
                              ForEach(0 ..< (proceedingCnt+6)/6, id: \.self) { page in
                                  VStack {
                                      LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                          ForEach((page * 6) ..< min((page+1) * 6, proceedingCnt+1), id: \.self) { index in
                                              
                                              if index == 0 {
                                                  
                                                  NewTravelButton {
                                                      isModalPresented.toggle()
                                                  }
                                                  .sheet(isPresented: $isModalPresented) {
                                                      FullCalendarModal()
                                                  }
                                                  
                                              } else {
                                                  VStack {
                                                      Button {
                                                          
                                                          chosenTravel = nowTravel?[index]
                                                          
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
                                                      Text(nowTravel?[index-1].name ?? "제목 미정")
                                                          .font(.subhead1)
                                                          .lineLimit(1)
                                                  }
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
                          ForEach(0..<(proceedingCnt+6)/6, id: \.self) { index in
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
                viewModel.fetchNowTravel()
                viewModel.fetchSavedExpense()
                self.nowTravel = viewModel.filterTravelByDate(todayDate: Date())
                print("proceedingCnt : ", proceedingCnt )
            }
        }
    }

}

// #Preview {
//     InterimProceedingView()
// }
