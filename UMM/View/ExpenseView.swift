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
        VStack {
            Text("ExpenseView")
            ZStack {
                HStack {
                    ForEach((TabbedItems.allCases), id: \.self) {item in
                        Button {
                            selectedTab = item.rawValue
                        } label: {
                            customTabItem(title: item.title, isActive: (selectedTab == item.rawValue))
                        }
                    }
                }
            }
            Spacer()
            TabView(selection: $selectedTab) {
                TodayExpenseView()
                    .tag(0)
                AllExpenseView()
                    .tag(1)
            }
        }
    }
}

private func customTabItem(title: String, isActive: Bool) -> some View {
    HStack(spacing: 10) {
        Spacer()
        Text(title)
            .font(.system(size: 14))
            .foregroundStyle(isActive ? .black : .gray)
        Spacer()
    }
    .frame(width: 80, height: 40)
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
