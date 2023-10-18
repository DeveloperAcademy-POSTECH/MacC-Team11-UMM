//
//  CompleteAddTravelView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/17.
//

import SwiftUI

struct CompleteAddTravelView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("여행 생성 완료 !")
                .font(.display2)
            
            Spacer()
            
            travelSquareView
            
            Spacer()
            
            HStack {
                MediumButtonUnactive(title: "홈으로 가기", action: {
                    // 선택값 초기화
                    NavigationUtil.popToRootView()
                })
                
                MediumButtonActive(title: "기록하기", action: {
                    NavigationUtil.popToRootView()
                })
            }
        }
        .navigationTitle("새로운 여행 생성")
        .navigationBarBackButtonHidden(true)
    }
    
    private var travelSquareView: some View {
        VStack {
            Text("dsf")
        }
    }
}

#Preview {
    CompleteAddTravelView()
}
