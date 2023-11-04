//
//  InterimRecordView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/04.
//

import SwiftUI

struct InterimRecordView: View {
    
    @State private var currentTab: Int = 0
    
    var body: some View {
        VStack {
            titleHeader
            
            defaultExpenseView
            
            DefaultTabBarView(currentDefaultTab: $currentTab)
            
            LargeButtonUnactive(title: "확인", action: {
                
            })
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
        ZStack {
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 350, height: 157)
              .background(Color(red: 0.96, green: 0.96, blue: 0.96))
              .cornerRadius(10)
        }
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

#Preview {
    InterimRecordView()
}
