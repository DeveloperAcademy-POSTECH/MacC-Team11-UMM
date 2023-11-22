//
//  ExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI
import Combine

struct ExpenseView: View {
    @State var selectedTab = 0
    @Namespace var namespace
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    let exchangeRateHandler = ExchangeRateHandler.shared
    @EnvironmentObject var mainVM: MainViewModel
    private var travelStream: Set<AnyCancellable> = []
    let isSE3 = abs(UIScreen.main.bounds.width - 375.0) < 2.0 && abs(UIScreen.main.bounds.height - 667.0) < 2.0
    
    var body: some View {
        NavigationStack {
            Group {
                if isSE3 {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Spacer()
                            .frame(height: 35)
                        
                        travelChoiceView
                            .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 36)
                        
                        tabViewButton
                        
                        Spacer()
                            .frame(height: 20)
                        
                        TabView(selection: $selectedTab) {
                            TodayExpenseView(selectedTab: $selectedTab, namespace: namespace)
                                .tag(0)
                                .contentShape(Rectangle())
                                .gesture(DragGesture().onChanged({_ in}))
                                .simultaneousGesture(TapGesture())
                            
                            AllExpenseView(selectedTab: $selectedTab, namespace: namespace)
                                .tag(1)
                                .contentShape(Rectangle())
                                .gesture(DragGesture().onChanged({_ in}))
                                .simultaneousGesture(TapGesture())
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        Spacer()
                    }
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Spacer()
                            .frame(height: 80)
                        
                        travelChoiceView
                            .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 36)
                        
                        tabViewButton
                        
                        Spacer()
                            .frame(height: 40)
                        
                        TabView(selection: $selectedTab) {
                            TodayExpenseView(selectedTab: $selectedTab, namespace: namespace)
                                .tag(0)
                                .contentShape(Rectangle())
                                .gesture(DragGesture().onChanged({_ in}))
                                .simultaneousGesture(TapGesture())
                            
                            AllExpenseView(selectedTab: $selectedTab, namespace: namespace)
                                .tag(1)
                                .contentShape(Rectangle())
                                .gesture(DragGesture().onChanged({_ in}))
                                .simultaneousGesture(TapGesture())
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                        Spacer()
                    }
                }
            }
            .ignoresSafeArea()
            .sheet(isPresented: $expenseViewModel.travelChoiceHalfModalIsShown) {
                TravelChoiceInExpenseModal(selectedTravel: $mainVM.selectedTravelInExpense, selectedCountry: $expenseViewModel.selectedCountry)
                    .presentationDetents([.height(289 - 34)])
            }
        }
    }
    
    private var settingViewButton: some View {
        NavigationLink {
            SettingView()
        } label: {
            HStack {
                Spacer()
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color.gray300)
            }
            .ignoresSafeArea(.all)
            .padding(.leading, 3)
            .padding(.top, 3)
        }
    }
    
    private var todayExpenseHeader: some View {
        HStack(spacing: 0) {
            Text("가계부")
                .font(.display2_fixed)
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private var travelChoiceView: some View {
        return HStack(alignment: .center, spacing: 10) {
            Spacer()
            Button {
                expenseViewModel.travelChoiceHalfModalIsShown = true
            } label: {
                VStack(spacing: 0) {
                    ZStack {
                        Capsule()
                            .foregroundStyle(.white)
                            .layoutPriority(-1)
                        
                        Capsule()
                            .strokeBorder(.mainPink, lineWidth: 1.0)
                            .layoutPriority(-1)
                        
                        HStack(spacing: 12) {
                            Text(mainVM.selectedTravelInExpense?.name != tempTravelName ? mainVM.selectedTravelInExpense?.name ?? "-" : "-")
                                .lineLimit(1)
                                .font(.subhead2_2_fixed)
                                .foregroundStyle(.black)
                            Image("recordTravelChoiceDownChevron")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                        .padding(.vertical, 6)
                        .padding(.leading, 16)
                        .padding(.trailing, 12)
                    }
                }
            }
            Text("가계부")
                .font(.display1_fixed)
                .foregroundStyle(.black)
            Spacer()
        }
    }
    
    private var tabViewButton: some View {
        HStack(spacing: 0) {
            ForEach((TabbedItems.allCases.indices), id: \.self) { index in
                ZStack {
                    ExpenseTabBarItem(selectedTab: $selectedTab, namespace: namespace, title: TabbedItems.allCases[index].title, tab: TabbedItems.allCases[index].rawValue)
                        .padding(.leading, index == 0 ? 39 : 20)
                        .padding(.trailing, index == 0 ? 20 : 39)
                    Divider()
                        .frame(height: 2)
                        .padding(.top, 31) // figma: ???
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 0)
    }
}

struct ExpenseTabBarItem: View {
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    
    var title: String
    var tab: Int
    
    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 0) {
                Text(title)
                    .font(.subhead3_1_fixed)
                    .foregroundStyle(selectedTab == tab ? .black : .gray300)
                    .frame(minWidth: 0, maxWidth: .infinity) // 이 부분 추가
                ZStack {
                    if selectedTab == tab {
                        Color.black
                            .matchedGeometryEffect(id: "underline", in: namespace.self)
                            .frame(height: 2)
                            .padding(.top, 11)
                    } else {
                        Color.clear
                            .frame(height: 2)
                            .padding(.top, 11)
                    }
                }
            }
            .animation(.spring(), value: selectedTab)
        }
        .buttonStyle(.plain)
    }
}

enum TabbedItems: Int, CaseIterable {
    case todayExpense
    case allExpense
    
    var title: String {
        switch self {
        case .todayExpense:
            return "일별 지출"
        case .allExpense:
            return "전체 지출"
        }
    }
}

// #Preview {
//    ExpenseView()
// }
