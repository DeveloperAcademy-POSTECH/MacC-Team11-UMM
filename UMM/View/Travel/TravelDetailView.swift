//
//  TravelDetailView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/26.
//

import SwiftUI

struct TravelDetailView: View {
    var body: some View {
        ZStack {
            Rectangle()
              .foregroundColor(.clear)
              .background(
                LinearGradient(
                  stops: [
                    Gradient.Stop(color: .black.opacity(0), location: 0.00),
                    Gradient.Stop(color: .black.opacity(0.75), location: 1.00)
                  ],
                  startPoint: UnitPoint(x: 0.5, y: 0),
                  endPoint: UnitPoint(x: 0.5, y: 1)
                )
              )
              .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Spacer()
                // 1. 여행중 + Day 3
                dayCounter
                
                // 2. 여행 제목 (ex) 니코랑 여행)
                travelTitle
                
                // 3. 여행 국가
                travelCountry
                
                // 4. 시작일 + 종료일
                dateBox
                
                // 5. 힘께하는 사람
                participantGroup
                Spacer()
                
                // 6. 버튼
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    NavigationLink(destination: AddTravelView(), label: {
                        Image(systemName: "pencil")
                            .frame(width: 20, height: 20)
                    })
                    
                    NavigationLink(destination: SettingView(), label: {
                        Image(systemName: "xmark_white")
                            .frame(width: 20, height: 20)
                    })
                }
            }
        }
    }
    
    private var dayCounter: some View {
        HStack {
            HStack(alignment: .center, spacing: 10) {
                Text("여행 중")
                    .font(
                        Font.custom("Pretendard", size: 14)
                            .weight(.medium)
                    )
                    .foregroundColor(Color.mainPink)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(.white)
            .cornerRadius(5)
            
            Text("❌DAY 3❌")
                .font(.subhead2_1)
                .foregroundStyle(Color.white)
        }
    }
    
    private var travelTitle: some View {
        Text("여행 제목")
            .font(.display3)
            .foregroundStyle(Color.white)
    }
    
    private var travelCountry: some View {
        VStack(alignment: .leading) {
            Text("여행 국가")
                .font(.subhead1)
                .foregroundStyle(Color.white)
            
            HStack {
                Text("❌ 여행 국가 개수대로 국기랑 국가명 쌓기 ❌")
            }
        }
    }
    
    private var dateBox: some View {
        VStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 326, height: 0.5)
                .background(.white)
            
            HStack {
                VStack {
                    Text("시작일")
                        .font(.subhead1)
                        .foregroundStyle(Color.white)
                    Text("시작 date")
                        .font(.body4)
                        .foregroundStyle(Color.white)
                }
                
                Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1, height: 49)
                .background(.white)
                
                VStack {
                    Text("종료일")
                        .font(.subhead1)
                        .foregroundStyle(Color.white)
                    Text("종료 date")
                        .font(.body4)
                        .foregroundStyle(Color.white)
                }
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 326, height: 0.5)
                .background(.white)
        }
    }
    
    private var participantGroup: some View {
        VStack {
            Text("함께하는 사람")
                .font(.subhead1)
            
            HStack {
                HStack(alignment: .center, spacing: 8) {
                    Text("me")
                      .font(
                        Font.custom("Pretendard", size: 16)
                          .weight(.medium)
                      )
                      .foregroundColor(Color.gray200)
                    
                    Text("나")
                      .font(
                        Font.custom("Pretendard", size: 16)
                          .weight(.medium)
                      )
                      .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.25))
                .cornerRadius(18.07692)
                
                Text("me 나 는 디폴트, 옆으로 참여자 추가되도록 ")
            }
        }
    }
}

#Preview {
    TravelDetailView()
}
