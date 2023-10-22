//
//  ExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct ExpenseView: View {
    @State var selectedTab = 0
    @Namespace var namespace
    @ObservedObject var expenseViewModel = ExpenseViewModel()
    @ObservedObject var dummyRecordViewModel = DummyRecordViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                travelChoiceView
                
                todayExpenseHeader
                
                Spacer()
                
                TabView(selection: $selectedTab) {
                    TodayExpenseView(selectedTab: $selectedTab, namespace: namespace)
                        .tag(0)
                    AllExpenseView(selectedTab: $selectedTab, namespace: namespace)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .onAppear {
                expenseViewModel.fetchExpense()
                dummyRecordViewModel.fetchDummyTravel()
                expenseViewModel.selectedTravel = findCurrentTravel()
                
                expenseViewModel.filteredExpenses = expenseViewModel.getFilteredExpenses()
                expenseViewModel.groupedExpenses = Dictionary(grouping: expenseViewModel.filteredExpenses, by: { $0.country })
            }
            .sheet(isPresented: $expenseViewModel.travelChoiceHalfModalIsShown) {
                TravelChoiceModalBinding(selectedTravel: $expenseViewModel.selectedTravel)
                    .presentationDetents([.height(289 - 34)])
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Spacer()
                        
                        NavigationLink(destination: SettingView(), label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.gray300)
                        })
                    }
                }
            }
        }
    }
    
    private var todayExpenseHeader: some View {
        HStack(spacing: 0) {
            Text("지출 관리")
                .font(.display2)
                .padding(.top, 12)
            Spacer()
        }
        .padding(.leading, 20)
    }
    
    private var travelChoiceView: some View {
        Button {
            expenseViewModel.travelChoiceHalfModalIsShown = true
            print("expenseViewModel.travelChoiceHalfModalIsShown = true")
        } label: {
            ZStack {
                Capsule()
                    .foregroundStyle(.white)
                    .layoutPriority(-1)
                
                Capsule()
                    .strokeBorder(.mainPink, lineWidth: 1.0)
                    .layoutPriority(-1)
                
                HStack(spacing: 12) {
                    Text(expenseViewModel.selectedTravel?.name != "Default" ? expenseViewModel.selectedTravel?.name ?? "-" : "-")
                        .font(.subhead2_2)
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
            .padding(.leading, 20)
        }
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
                    .font(.subhead3_1)
                    .foregroundStyle(selectedTab == tab ? .black : .gray300)

                ZStack {
                    Divider()
                        .frame(height: 2)
                        .padding(.top, 11)
                    if selectedTab == tab {
                        Color.black
                            .matchedGeometryEffect(id: "underline", in: namespace.self)
                            .frame(height: 2)
                            .padding(.top, 11)
                            .padding(.horizontal)
                    } else {
                        Color.clear
                            .frame(height: 2)
                            .padding(.top, 11)
                            .padding(.horizontal)
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
