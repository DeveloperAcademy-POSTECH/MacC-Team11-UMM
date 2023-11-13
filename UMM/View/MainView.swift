//
//  MainView.swift
//  UMM
//
//  Created by 김태현 on 10/11/23.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var viewModel = MainViewModel.shared
    @State private var selectedTab = 0
    let exchangeRateHandler = ExchangeRateHandler.shared
    
    var body: some View {
        TabView(selection: $viewModel.selection) {
            
            TravelListView(month: Date())
                .tabItem {
                    VStack {
                        if viewModel.selection == 0 {
                            Image("tabitem1_active")
                        } else {
                            Image("tabitem1_unactive")
                        }
                        Text("여행 관리")
                            .font(.caption1)
                    }
                }
                .tag(0)
            
            RecordView()
                .tabItem {
                    VStack {
                        if viewModel.selection == 1 {
                            Image("tabitem2_active")
                        } else {
                            Image("tabitem2_unactive")
                        }
                        Text("지출 기록")
                            .font(.caption1)
                        
                    }
                }
                .tag(1)
            
            ExpenseView()
                .tabItem {
                    VStack {
                        if viewModel.selection == 2 {
                            Image("tabitem3_active")
                        } else {
                            Image("tabitem3_unactive")
                        }
                        Text("가계부")
                            .font(.caption1)
                    }
                }
                .tag(2)
        }
        
        .onAppear {
            UITabBar.appearance().backgroundColor = .white
            let loadedData = exchangeRateHandler.loadExchangeRatesFromUserDefaults()
            if loadedData == nil || !exchangeRateHandler.isSameDate(loadedData?.time_last_update_unix) {
                print("exchangeRate API 실행 !!")
                exchangeRateHandler.fetchAndSaveExchangeRates()
            }
            
            DateGapHandler.shared.requestAuthorization()
        }
        .accentColor(Color.mainPink)
        .environmentObject(viewModel)
        
    }
}

#Preview {
    MainView()
}
