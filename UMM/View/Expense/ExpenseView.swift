//
//  ExpenseView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct ExpenseView: View {
    @State var selectedTab = 0
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                TodayExpenseView(selectedTab: $selectedTab)
                    .tag(0)
                AllExpenseView(selectedTab: $selectedTab)
                    .tag(1)
            }
            .border(.red)
        }
    }
}

func customTabItem(title: String, isActive: Bool) -> some View {
    HStack(spacing: 10) {
        Spacer()
        Text(title)
            .font(.subhead3_1)
            .foregroundStyle(.black)
        Spacer()
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

#Preview {
   ExpenseView()
}
