//
//  InterimRecordView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/04.
//

import SwiftUI

struct InterimRecordView: View {
    
    @State private var currentPage = 0
    @State private var defaultTravel: [Travel]?
    @State private var defaultExpense: [Expense]?
    
    @Binding var defaultTravelCnt: Int
    
    @ObservedObject private var viewModel = InterimRecordViewModel()
    
    var body: some View {
        VStack {
            titleHeader
            
            defaultExpenseView
            
            DefaultTravelTabView()
            
            LargeButtonUnactive(title: "확인", action: {
                
            })
        }
        .toolbar(.hidden, for: .tabBar)
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
}

struct DefaultTravelTabView: View {
    
    @State private var currentDefaultTab: Int = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: self.$currentDefaultTab) {
                ProceedingView()
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(0)
                
                PastView()
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(1)
                
                OncomingView()
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(2)
            }
            .padding(.top, 12)
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Divider()
                .frame(height: 1)
                .padding(.top, 36)
            
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
        .background(Color.clear)
        .frame(height: 30)
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
            .animation(.spring(), value: self.currentDefaultTab)
        }
        .buttonStyle(.plain)
    }
}

struct ProceedingView: View {
    var body: some View {
        ZStack {
            Text("진행 중")
        }
        .onAppear {
            print("ProceedingView : OnAppear")
        }
    }
}

struct PastView: View {
    var body: some View {
        ZStack {
            Text("지난")
        }
        .onAppear {
            print("PastView : OnAppear")
        }
    }
}

struct OncomingView: View {
    var body: some View {
        ZStack {
            Text("다가오는")
        }
        .onAppear {
            print("OncomingView : OnAppear")
        }
    }
}

// #Preview {
//     InterimRecordView()
// }
