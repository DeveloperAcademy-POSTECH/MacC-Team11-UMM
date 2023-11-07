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
    
    // 몇번째 지출인지
    @State var selectedTravelIndex = 0
    
    @State var isSelectedTravel = false
    @Binding var defaultTravelCnt: Int
    
    @ObservedObject private var viewModel = InterimRecordViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            titleHeader
            
            defaultExpenseView
            
            DefaultTravelTabView(viewModel: viewModel, isSelectedTravel: $isSelectedTravel)
            
            if !isSelectedTravel {
                LargeButtonUnactive(title: "확인", action: {
                    
                })
                .disabled(true)
                
            } else {
                LargeButtonActive(title: "확인", action: {
                    viewModel.chosenExpense = defaultExpense?[selectedTravelIndex]
                    NavigationUtil.popToRootView()
                })
            }
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
        .onDisappear {
            // ViewModel의 Save함수가 실행됨
            DispatchQueue.main.async {
                viewModel.update()
//                print("xxxxxx : chose Expense", defaultExpense?[selectedTravelIndex])
//                print("xxxxxx", viewModel.chosenExpense?.travel?.name)
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
                                    Text(" ")
                                    +
                                    Text((CountryInfoModel.shared.countryResult[Int(((defaultExpense?[index].country) ?? -1))]?.relatedCurrencyArray[0]) ?? "-")
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
                }
                .onChange(of: currentPage) { _, newValue in
                    selectedTravelIndex = newValue
                }
            }
            .frame(width: 350, height: 157 + 46)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: 350, height: 157 + 46)
            
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
    
    @ObservedObject var viewModel: InterimRecordViewModel
    
    @State private var currentDefaultTab: Int = 0
    @Binding var isSelectedTravel: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: self.$currentDefaultTab) {
                InterimProceedingView(viewModel: viewModel, isSelectedTravel: $isSelectedTravel)
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(0)
                
                InterimPastView(viewModel: viewModel, isSelectedTravel: $isSelectedTravel)
                    .gesture(DragGesture().onChanged { _ in
                        // PreviousTravelView에서 DragGesture가 시작될 때의 동작
                    })
                    .tag(1)
                
                InterimOncomingView(viewModel: viewModel, isSelectedTravel: $isSelectedTravel)
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

struct NewTravelButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            self.action()
        } label: {
            VStack {
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
                
                Text("새로운 여행")
                    .font(.subhead1)
                    .opacity(0)
            }
        }
    }
}

struct CheckLabelView: View {
    let travel: Travel
    let chosenTravel: Travel
    
    var body: some View {
        if travel.id == chosenTravel.id {
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
        } else {
            Circle()
                .fill(.black)
                .opacity(0.25)
                .frame(width: 19, height: 19)
                .overlay(
                    Circle()
                        .strokeBorder(.white, lineWidth: 1.0)
                )
        }
    }
}

// #Preview {
//     InterimRecordView()
// }
