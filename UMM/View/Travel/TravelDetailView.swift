//
//  TravelDetailView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/26.
//

import SwiftUI
import CoreData

struct TravelDetailView: View {
    
    @EnvironmentObject var mainVM: MainViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var viewModel = TravelDetailViewModel()
    @State var selectedTravel: [Travel]?
    @State var travelID: UUID = UUID()
    @State var travelName: String
    @State var startDate: Date
    @State var endDate: Date
    @State var dayCnt: Int
    @State var participantCnt: Int
    @State var participantArr: [String]
    @State var flagImageArr: [String] = []
    @State var defaultImageString: String
    @State var koreanNM: [String]
    
    @State var isWarningOn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    // 1. 여행중 + Day 3
                    dayCounter
                    
                    // 2. 시작일 + 종료일
                    dateBox
                    
                    // 3. 여행 국가
                    travelCountry
                    
                    // 4. 힘께하는 사람
                    participantGroup
                    
                    Spacer()
                    
                    // 6. 버튼
                    HStack {
                        MediumButtonWhite(title: "가계부 보기", action: {
                            // 선택값 초기화
                            NavigationUtil.popToRootView()
                            mainVM.navigationToExpenseView()
                        })
                        
                        MediumButtonMain(title: "지출 기록하기", action: {
                            NavigationUtil.popToRootView()
                            mainVM.navigationToRecordView()
                            
                        })
                    }
                }
            }
            .background(
                Image(defaultImageString)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .black.opacity(0), location: 0.00),
                                Gradient.Stop(color: .black.opacity(0.75), location: 1.00)
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .blur(radius: 10)
            )
            .onAppear {
                viewModel.fetchTravel()
                //                travelID = mainVM.selectedTravel?.id ?? UUID()
                self.selectedTravel = viewModel.filterByID(selectedTravelID: travelID)
                
            }
            .onDisappear {
                print("TravelID : ", travelID)
                mainVM.selectedTravel = self.selectedTravel?.first
                travelID = mainVM.selectedTravel?.id ?? UUID()
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            // deleteItems에서 강제 언래핑을 사용하고 있으므로 혹시나모를 상황을 대비해 selectedTravel이 nil일 경우 임의의 Travel을 생성..?
//                            PersistenceController().deleteItems(viewContext, self.selectedTravel?.first)
                            isWarningOn = true
                        } label: {
                            Image(systemName: "trash")
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
                
                if Date() <= endDate {
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
                }
                
                Group {
                    Text("DAY ")
                    +
                    Text("\(dayCnt)")
                }
                .padding(.vertical, 7)
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
                
                ForEach(0..<koreanNM.count, id: \.self) { index in
                    
                    HStack {
                        Image(flagImageArr[index])
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text(koreanNM[index])
                            .font(.body2)
                            .foregroundStyle(Color.white)
                    }
                    .padding(.trailing, 18)
                    
                }
                
                Spacer()
            }
            .padding(.bottom, 20)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 40, height: 0.5)
                .background(.white)
        }
        .padding(.horizontal, 20)
    }
    
    private var dateBox: some View {
        VStack {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
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
                
                VStack(alignment: .leading, spacing: 0) {
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
            
            if participantCnt <= 1 {
                
                HStack(alignment: .center, spacing: 4) {
                    Text("me")
                        .font(.subhead2_1)
                        .foregroundColor(Color.gray200)
                    
                    Text("나")
                        .font(.subhead2_2)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .frame(height: 28, alignment: .center)
                .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                .cornerRadius(6)
                
            } else if participantCnt <= 4 {
                
                HStack {
                    HStack(alignment: .center, spacing: 4) {
                        Text("me")
                            .font(.subhead2_1)
                            .foregroundColor(Color.gray200)
                        
                        Text("나")
                            .font(.subhead2_2)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .frame(height: 28, alignment: .center)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(6)
                    
                    ForEach(2..<participantCnt, id: \.self) { index in
                        HStack(alignment: .center, spacing: 10) {
                            Text("\(participantArr[index])")
                                .font(.subhead2_2)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .cornerRadius(6)
                    }
                }
            } else {
                HStack {
                    HStack(alignment: .center, spacing: 4) {
                        Text("me")
                            .font(.subhead2_1)
                            .foregroundColor(Color.gray200)
                        
                        Text("나")
                            .font(.subhead2_2)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    //                    .frame(height: 28, alignment: .center)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(6)
                    
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 10) {
                            ForEach(1..<participantCnt, id: \.self) { index in
                                
                                    Text("\(participantArr[index])")
                                        .font(.subhead2_2)
                                        .foregroundColor(.white)
                                }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                            .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 20)
    }
}

// #Preview {
//     TravelDetailView()
// }
