//
//  InterimRecordView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/04.
//

import SwiftUI

struct InterimRecordView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPage = 0
    @State private var defaultTravel: [Travel]?
    @State private var defaultExpense: [Expense]?
    
    @Binding var defaultTravelCnt: Int
    
    @ObservedObject private var viewModel = InterimRecordViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            titleHeader
            
            defaultExpenseView
            
            DefaultTravelTabView(viewModel: viewModel)
            
            LargeButtonUnactive(title: "확인", action: {
                
            })
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            DispatchQueue.main.async {
                viewModel.fetchTravel()
                viewModel.fetchExpense()
                self.defaultExpense = viewModel.filterDefaultExpense(selectedTravelName: "Default")
            }
        }
    }
    
    private var titleHeader: some View {
        HStack {
            Text("어떤 여행의 지출인가요?")
                .font(.display2)
                .padding(.leading, 20)
            
            Spacer()
        }
        .padding(.top, 28)
    }
    
    private var defaultExpenseView: some View {
        ZStack(alignment: .center) {
            ScrollView(.init()) {
                TabView(selection: $currentPage) {
                    ForEach(0..<defaultTravelCnt, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 350, height: 157)
                                .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .cornerRadius(10)
                            
                            VStack {
                                Text(defaultExpense?[index].info ?? "")
                                    .font(.subhead3_2)
                                    .foregroundStyle(Color.black)
                                
                                HStack {
                                    Group {
                                        Text("\(viewModel.formatAmount(amount: defaultExpense?[index].payAmount))")
                                        +
                                        Text(" 원") // Doris
                                    }
                                    .font(.display2)
                                    .foregroundStyle(Color.black)
                                    
                                    HStack(alignment: .center, spacing: 12) {
                                        Text("\(PaymentMethod.titleFor(rawValue: Int(defaultExpense?[index].paymentMethod ?? -1)))")
                                            .font(.custom(FontsManager.Pretendard.regular, size: 16))
                                            .foregroundStyle(Color.black)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .frame(height: 24, alignment: .center)
                                    .background(Color(0xE0E0E0))
                                    
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color(0xBFBFBF), lineWidth: 1)
                                        
                                    )
                                }
                                
                                Group {
                                    Text(dateFormatterWithDay.string(from: defaultExpense?[index].payDate ?? Date()))
                                    +
                                    Text(" ")
                                    +
                                    Text(dateFormatterWithHourMiniute(date: defaultExpense?[index].payDate ?? Date()))
                                }
                                .font(.caption2)
                                .foregroundStyle(Color.gray400)
                                
                                HStack {
                                    if let flagString = CountryInfoModel.shared.countryResult[Int((defaultExpense?[index].country) ?? -1 )]?.flagString {
                                        Image(flagString)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 17, height: 17)
                                            .shadow(color: .black.opacity(0.25), radius: 0.94444, x: 0, y: 0)
                                    } else {
                                        Image("DefaultFlag")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 17, height: 17)
                                            .shadow(color: .black.opacity(0.25), radius: 0.94444, x: 0, y: 0)
                                    }
                                    
                                    Text(CountryInfoModel.shared.countryResult[Int((defaultExpense?[index].country) ?? -1 )]?.koreanNm ?? "Unknown")
                                        .font(.custom(FontsManager.Pretendard.medium, size: 14))
                                        .foregroundStyle(Color.gray400)
                                }
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                
                            }
                        }
                    }
                }
                .frame(width: 350, height: 157 + 46)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .frame(width: 350, height: 157 + 46)
            .foregroundStyle(Color.red)
            
            HStack(spacing: 6) {
                ForEach(0..<defaultTravelCnt, id: \.self) { index in
                    Capsule()
                        .fill(currentPage == index ? Color.black : Color.gray200)
                        .frame(width: 5, height: 5)
                }
            }
            .offset(y: 100)
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
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .imageScale(.large)
                .foregroundColor(Color.black)
        }
    }
}

struct DefaultTravelTabView: View {
    
    @State private var currentDefaultTab: Int = 0
    @ObservedObject var viewModel: InterimRecordViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: self.$currentDefaultTab) {
                ProceedingView(viewModel: viewModel)
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(0)
                
                PastView(viewModel: viewModel)
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(1)
                
                OncomingView(viewModel: viewModel)
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(2)
            }
            .padding(.top, 12)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Divider()
                .frame(height: 1)
                .padding(.top, 55)
            
            DefaultTabBarView(currentDefaultTab: self.$currentDefaultTab)
        }
    }
}

struct DefaultTabBarView: View {
    @Binding var currentDefaultTab: Int
    @Namespace var namespace
    
    var tabBarOptions: [String] = ["진행 중", "지난", "다가오는"]
    var body: some View {
        HStack {
            ForEach(Array(zip(self.tabBarOptions.indices,
                              self.tabBarOptions)),
                    id: \.0,
                    content: { index, name in
                DefaultTabBarItem(currentDefaultTab: self.$currentDefaultTab,
                           namespace: namespace.self,
                           tabBarItemName: name,
                           tab: index)
            })
        }
        .padding(.horizontal, 20)
        .padding(.top, 30) // Doris
        .background(Color.clear)
        .frame(height: 39)
//        .background(Color.red)
        .ignoresSafeArea(.all)
    }
}

struct DefaultTabBarItem: View {
    
    @Binding var currentDefaultTab: Int
    
    let namespace: Namespace.ID
    let tabBarItemName: String
    var tab: Int
    
    var body: some View {
        Button {
            self.currentDefaultTab = tab
        } label: {
            
            HStack {
                if currentDefaultTab == tab {
                    VStack {
                        
                        Spacer()
                        
                        Text(tabBarItemName)
                            .font(.subhead3_1)
                        
                        Color.black
                            .frame(width: 116, height: 2)
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
                        
                        Color.clear.frame(width: 116, height: 2)
                    }
                }
            }
            .animation(.spring(), value: self.currentDefaultTab)
        }
        .buttonStyle(.plain)
    }
}

struct ProceedingView: View {
    
    @State private var currentPage = 0
    @State var proceedingCnt = 0
    @State var nowTravel: [Travel]? {
        didSet {
            proceedingCnt = Int(nowTravel?.count ?? 0)
        }
    }
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    var body: some View {
        ZStack {
            if proceedingCnt == 0 {
                Button {
                    
                } label: {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 110, height: 80)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                            )
                        
                        VStack {
                            Image("manualRecordParticipantAdd")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                
                            Text("새로운 여행")
                                .font(.subhead1)
                                .foregroundStyle(Color.gray300)
                        }
                    }
                }
            } else if proceedingCnt <= 5 {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                        ForEach(0..<proceedingCnt+1, id: \.self) { index in
                            if index == 0 {
                                Button {
                                    
                                } label: {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 110, height: 80)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                                            )
                                        
                                        VStack {
                                            Image("manualRecordParticipantAdd")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 16, height: 16)
                                            
                                            Text("새로운 여행")
                                                .font(.subhead1)
                                                .foregroundStyle(Color.gray300)
                                        }
                                    }
                                }
                            } else {
                                VStack {
                                    Button {
                                        
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
                                            
                                            //                                            VStack(alignment: .leading) {
                                            //                                                HStack {
                                            //                                                    Spacer()
                                            //
                                            //                                                    ForEach(flagImageDict[nowTravel?[index].id ?? UUID()] ?? [], id: \.self) { imageName in
                                            //                                                        Image(imageName)
                                            //                                                            .resizable()
                                            //                                                            .frame(width: 24, height: 24)
                                            //                                                    }
                                            //                                                }
                                            //                                                .padding(16)
                                            //
                                            //                                                Spacer()
                                            //
                                            //                                                HStack {
                                            //                                                    Text(nowTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                            //
                                            //                                                    Text("~")
                                            //                                                }
                                            //                                                .font(.caption2)
                                            //                                                .foregroundStyle(Color.white.opacity(0.75))
                                            //
                                            //                                                Text(nowTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                            //                                                    .font(.caption2)
                                            //                                                    .foregroundStyle(Color.white.opacity(0.75))
                                            //                                            }
                                        }
                                        //                                        .onAppear {
                                        //
                                        //                                            self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: previousTravel?[index].id ?? UUID())
                                        //
                                        //                                            if let savedExpenses = savedExpenses {
                                        //                                                let countryValues: [Int64] = savedExpenses.map { expense in
                                        //                                                    return viewModel.getCountryForExpense(expense)
                                        //                                                }
                                        //                                                let uniqueCountryValues = Array(Set(countryValues))
                                        //
                                        //                                                var flagImageNames: [String] = []
                                        //                                                for countryValue in uniqueCountryValues {
                                        //
                                        //                                                    if let flagString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.flagString {
                                        //                                                        flagImageNames.append(flagString)
                                        //                                                    } else {
                                        //                                                        flagImageNames.append("DefaultFlag")
                                        //                                                    }
                                        //                                                }
                                        //                                                self.flagImageDict[previousTravel?[index].id ?? UUID()] = flagImageNames
                                        //                                            }
                                        //                                        }
                                    }
//                                    Text(nowTravel?[index].name ?? "제목 미정")
//                                        .font(.subhead1)
//                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
//                    
                    Spacer()
                }
            } else {
                ZStack {
                      ScrollView(.init()) {
                          TabView(selection: $currentPage) {
                              ForEach(0 ..< (proceedingCnt+5)/6, id: \.self) { page in
                                  VStack {
                                      LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) {
                                          ForEach((page * 6) ..< min((page+1) * 6, proceedingCnt+1), id: \.self) { index in
                                              
                                              if index == 0 {
                                                  Button {
                                                      
                                                  } label: {
                                                      ZStack {
                                                          Rectangle()
                                                              .foregroundColor(.clear)
                                                              .frame(width: 110, height: 80)
                                                              .cornerRadius(10)
                                                              .overlay(
                                                                  RoundedRectangle(cornerRadius: 10)
                                                                      .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                                                              )
                                                          
                                                          VStack {
                                                              Image("manualRecordParticipantAdd")
                                                                  .resizable()
                                                                  .scaledToFit()
                                                                  .frame(width: 16, height: 16)
                                                              
                                                              Text("새로운 여행")
                                                                  .font(.subhead1)
                                                                  .foregroundStyle(Color.gray300)
                                                          }
                                                      }
                                                  }
                                              } else {
                                                  VStack {
                                                      Button {
                                                          
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
                                                              
                                                              //                                                          VStack(alignment: .leading) {
                                                              //
                                                              //                                                              HStack {
                                                              //                                                                  Spacer()
                                                              //
                                                              //                                                                  ForEach(flagImageDict[previousTravel?[index].id ?? UUID()] ?? [], id: \.self) { imageName in
                                                              //                                                                      Image(imageName)
                                                              //                                                                          .resizable()
                                                              //                                                                          .frame(width: 24, height: 24)
                                                              //                                                                  }
                                                              //                                                              }
                                                              //                                                              .padding(16)
                                                              //
                                                              //                                                              Spacer()
                                                              //
                                                              //                                                              HStack {
                                                              //                                                                  Text(previousTravel?[index].startDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                              //
                                                              //                                                                  Text("~")
                                                              //                                                              }
                                                              //                                                              .font(.caption2)
                                                              //                                                              .foregroundStyle(Color.white.opacity(0.75))
                                                              //
                                                              //                                                              Text(previousTravel?[index].endDate ?? Date(), formatter: PreviousTravelViewModel.dateFormatter)
                                                              //                                                                  .font(.caption2)
                                                              //                                                                  .foregroundStyle(Color.white.opacity(0.75))
                                                              //                                                          }
                                                              
                                                          }
                                                          //                                                      .onAppear {
                                                          //                                                          self.savedExpenses = viewModel.filterExpensesByTravel(selectedTravelID: previousTravel?[index].id ?? UUID())
                                                          //
                                                          //                                                          if let savedExpenses = savedExpenses {
                                                          //                                                              let countryValues: [Int64] = savedExpenses.map { expense in
                                                          //                                                                  return viewModel.getCountryForExpense(expense)
                                                          //                                                              }
                                                          //                                                              let uniqueCountryValues = Array(Set(countryValues))
                                                          //
                                                          //                                                              var flagImageNames: [String] = []
                                                          //                                                              for countryValue in uniqueCountryValues {
                                                          //
                                                          //                                                                  if let flagString = CountryInfoModel.shared.countryResult[Int(countryValue)]?.flagString {
                                                          //                                                                      flagImageNames.append(flagString)
                                                          //                                                                  } else {
                                                          //                                                                      flagImageNames.append("DefaultFlag")
                                                          //                                                                  }
                                                          //                                                              }
                                                          //                                                              self.flagImageDict[previousTravel?[index].id ?? UUID()] = flagImageNames
                                                          //                                                          }
                                                          //                                                      }
                                                      }
                                                      //                                                  Text(previousTravel?[index].name ?? "제목 미정")
                                                      //                                                      .font(.subhead1)
                                                      //                                                      .lineLimit(1)
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
                          ForEach(0..<(proceedingCnt+5)/6, id: \.self) { index in
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
                self.nowTravel = viewModel.filterTravelByDate(todayDate: Date())
                print("proceedingCnt : ", proceedingCnt )
            }
        }
    }
}

struct PastView: View {
    
    @State private var pastCnt = 0
    @State var previousTravel: [Travel]? {
        didSet {
            pastCnt = Int(previousTravel?.count ?? 0)
        }
    }
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    var body: some View {
        ZStack {
            Text("지난")
        }
    }
}

struct OncomingView: View {
    
    @State private var oncomingCnt = 0
    @State var oncomingTravel: [Travel]? {
        didSet {
            oncomingCnt = Int(oncomingTravel?.count ?? 0)
        }
    }
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    var body: some View {
        ZStack {
            Text("다가오는 :")
        }
    }
}

// #Preview {
//     InterimRecordView()
// }
