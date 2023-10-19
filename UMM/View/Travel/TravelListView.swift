//
//  TravelListView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct TravelListView: View {

    @State var month: Date

    var body: some View {
        NavigationStack {
            VStack {
                titleHeader
                
                nowTravelingView
                
                tempTravelView
                
                travelTabView
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        NavigationLink(destination: AddTravelView(), label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.gray300)
                        })
                        
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
    
    private var titleHeader: some View {
        VStack {
            
            HStack {
                Text("여행 관리")
                    .font(.display2)
                    .padding(.leading, 20)
                
                Spacer()
            }
        
            HStack {
                Text("진행 중인 여행")
                    .padding(.leading, 20)
                    .font(.subhead3_1)
                Spacer()
            }
        }
    }
    
    private var nowTravelingView: some View {
        // 가로스크롤뷰
        Rectangle()
          .foregroundColor(.clear)
          .frame(width: 350, height: 137)
          .background(
            ZStack {
                Color.gray100
                Text("현재 진행 중인 여행이 없어요")
                    .font(.body2)
                    .foregroundStyle(Color(0xA6A6A6))
            }
          )
          .cornerRadius(10)
    }
    
    private var tempTravelView: some View {
        Text("")
    }
    
    private var travelTabView: some View {
        Text("")
    }
}

#Preview {
    TravelListView(month: Date())
}
