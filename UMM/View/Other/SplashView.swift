//
//  SplashView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/10.
//

import SwiftUI

struct SplashView: View {
    
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            MainView()
        } else {
            ZStack {
                
                Rectangle()
                    .overlay(LinearGradient(
                        stops: [
                            Gradient.Stop(color: .mainPink, location: 0.00),
                            Gradient.Stop(color: .mainOrange, location: 1.00)
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    ))
                    .ignoresSafeArea()
                
                LottieView(name: "Splash", animationSpeed: 1.2)
                    .frame(width: 260, height: 260)
                    .padding(.bottom, 60)
                    .ignoresSafeArea()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
