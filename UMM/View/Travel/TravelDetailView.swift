//
//  TravelDetailView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/26.
//

import SwiftUI

struct TravelDetailView: View {
    
    @EnvironmentObject var mainVM: MainViewModel
    @State var travelName: String
    @State var startDate: Date
    @State var endDate: Date
    @State var dayCnt: Int
    @State var participantCnt: Int
    @State var participantArr: [String]
    @State var flagImageArr: [String] = []
    
    var body: some View {
        NavigationStack {
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
                
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    // 1. 여행중 + Day 3
                    dayCounter
                    
                    // 3. 여행 국가
                    travelCountry
                    
                    // 4. 시작일 + 종료일
                    dateBox
                    
                    // 5. 힘께하는 사람
                    participantGroup
                    
                    Spacer()
                    
                    // 6. 버튼
                    HStack {
                        MediumButtonUnactive(title: "가계부 보기", action: {
                            // 선택값 초기화
                            mainVM.navigationToExpenseView()
                        })
                        
                        MediumButtonActive(title: "지출 기록하기", action: {
                            mainVM.navigationToRecordView()
                            
                        })
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            
                        } label: {
                            Image("pencil")
                                .frame(width: 20, height: 20)
                        }
                        
                        Button {
                            NavigationUtil.popToRootView()
                        } label: {
                            Image("xmark_white")
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden()
    }
    
    private var dayCounter: some View {
        VStack(alignment: .leading) {
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
                
                Group {
                    Text("DAY ")
                    +
                    Text("\(dayCnt)")
                }
                .font(.subhead2_1)
                .foregroundStyle(Color.white)
            }
            
            Text("\(travelName)")
                .font(.display3)
                .foregroundStyle(Color.white)
                
        }
        .padding(.horizontal, 20)
    }
    
    private var travelCountry: some View {
        VStack(alignment: .leading) {
            Text("여행 국가")
                .font(.subhead1)
                .foregroundStyle(Color.white)
            
            HStack {
                ForEach(flagImageArr, id: \.self) { imgString in
                    Image(imgString)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var dateBox: some View {
        VStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 40, height: 0.5)
                .background(.white)
            
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text("시작일")
                        .font(.subhead1)
                        .foregroundStyle(Color.white)
                        .padding(.bottom, 8)
                    Text(startDate, formatter: TravelDetailViewModel.dateFormatter)
                        .font(.body4)
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
                
                Rectangle()
                .foregroundColor(.clear)
                .frame(width: 1, height: 49)
                .background(.white)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("종료일")
                        .font(.subhead1)
                        .foregroundStyle(Color.white)
                        .padding(.bottom, 8)
                    Text(endDate, formatter: TravelDetailViewModel.dateFormatter)
                        .font(.body4)
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
            }
            .padding(.vertical, 22)
            .frame(width: UIScreen.main.bounds.width - 40)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 40, height: 0.5)
                .background(.white)
        }
        .padding(.horizontal, 20)
    }
    
    private var participantGroup: some View {
        VStack(alignment: .leading) {
            Text("함께하는 사람")
                .font(.subhead1)
                .foregroundStyle(Color.white)
            
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
                
                ForEach(0..<participantCnt, id: \.self) { index in
                    HStack(alignment: .center, spacing: 10) {
                        Text("\(participantArr[index])")
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
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// #Preview {
//     TravelDetailView()
// }
