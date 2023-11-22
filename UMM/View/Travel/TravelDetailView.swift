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
    @State var endDate: Date?
    @State var dayCnt: Int
    @State var participantCnt: Int
    @State var participantArr: [String]
    @State var flagImageArr: [String] = []
    @State var defaultImageString: String
    @State var blurImageString: String
    @State var koreanNM: [String]
    
    @State var isWarningOn = false
    
    let dateGapHandler = DateGapHandler.shared
    
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
                            mainVM.selectedTravel = self.selectedTravel?.first
                            travelID = mainVM.selectedTravel?.id ?? UUID()
                            NavigationUtil.popToRootView()
                            mainVM.navigationToExpenseView()
                        })
                        
                        MediumButtonMain(title: "지출 기록하기", action: {
                            mainVM.selectedTravel = self.selectedTravel?.first
                            travelID = mainVM.selectedTravel?.id ?? UUID()
                            NavigationUtil.popToRootView()
                            mainVM.navigationToRecordView()
                        })
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .background(
                Image(blurImageString)
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
            )
            .onAppear {
                print("participantCnt \(participantArr.count)")
                viewModel.fetchTravel()
                self.selectedTravel = viewModel.filterByID(selectedTravelID: travelID)
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button {
                            isWarningOn = true
                        } label: {
                            Image("trashCan")
                                .padding(.trailing, 10)
                        }
                        
                        Button {
                            NavigationUtil.popToRootView()
                        } label: {
                            Image("xmark_white")
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 5)
                        }
                    }
                }
            }
            .alert(isPresented: $isWarningOn) {
                Alert(title: Text("여행 삭제하기"), 
                      message: Text("현재 선택한 여행방에 저장된 지출 기록 및 관련 데이터를 모두 삭제할까요?"),
                      primaryButton: .destructive(Text("삭제하기"), action: {
                    
                    let idToBeDeleted = self.selectedTravel?.first?.id
                    PersistenceController().deleteItems(object: self.selectedTravel?.first)
                    
                    if let idToBeDeleted {
                        if let selectedId = mainVM.selectedTravel?.id, let selectedInExpenseId = mainVM.selectedTravelInExpense?.id {
                            if idToBeDeleted == selectedId || idToBeDeleted == selectedInExpenseId {
                                mainVM.selectedTravelInExpense = findInitialTravelInExpense()
                                mainVM.selectedTravel = findCurrentTravel() // defaultTravel이면 selectedTravelInExpense를 업데이트하지 않는다.
                            }
                        }
                    }
                    NavigationUtil.popToRootView()
                }), secondaryButton: .cancel(Text("취소")))
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden()
    }
    
    private var dayCounter: some View {
        VStack(alignment: .leading) {
            HStack {
                if Date() <= endDate ?? Date.distantFuture && startDate <= Date() {
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
                        Text("\(dayCnt+1)")
                    }
                    .padding(.vertical, 7)
                    .font(.subhead2_1)
                    .foregroundStyle(Color.white)
                }
            }
            
            Text("\(travelName)")
                .font(.display3)
                .foregroundStyle(Color.white)
                
        }
        .padding(.horizontal, 32)
    }
    
    private var travelCountry: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("여행 국가")
                .font(.subhead1)
                .foregroundStyle(Color.white)
            
            if koreanNM.count > 0 {
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
                .padding(.vertical, 20)
            } else {
                HStack {
                    Text("소비 기록을 남기면 자동으로 채워져요.")
                        .font(.body2)
                        .foregroundStyle(Color.gray200)
                        .frame(height: 24)
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 64, height: 0.5)
                .background(.white)
        }
        .padding(.horizontal, 32)
    }
    
    private var dateBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("시작일")
                        .font(.subhead1)
                        .foregroundStyle(Color.white)
                        .padding(.bottom, 8)
                    
                    ZStack(alignment: .leading) {
                        Text("00.00.00 (수)")
                            .font(.body4)
                            .hidden()
                        
                        Text(dateGapHandler.convertBeforeShowing(date: startDate), formatter: TravelDetailViewModel.dateFormatter)
                            .font(.body4)
                            .foregroundStyle(Color.white)
                    }
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
                    
                    if let endDate = endDate {
                        ZStack(alignment: .leading) {
                            Text("00.00.00 (수)")
                                .font(.body4)
                                .hidden()
                            
                            Text(dateGapHandler.convertBeforeShowing(date: endDate), formatter: TravelDetailViewModel.dateFormatter)
                                .font(.body4)
                                .foregroundStyle(Color.white)
                        }
                    } else {
                        ZStack(alignment: .leading) {
                            Text("00.00.00 (수)")
                                .font(.body4)
                                .hidden()
                            
                            Text("미정")
                                .font(.body4)
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 22)
            .frame(width: UIScreen.main.bounds.width - 64)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 64, height: 0.5)
                .background(.white)
        }
        .padding(.horizontal, 32)
    }
    
    private var participantGroup: some View {
        VStack(alignment: .leading) {
            Text("함께하는 사람")
                .font(.subhead1)
                .foregroundStyle(Color.white)
                .padding(.bottom, 5)
            
            if participantCnt < 1 {
                
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
                
            } else if participantCnt <= 3 {
                
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
                    
                    ForEach(1..<participantCnt+1, id: \.self) { index in
                        HStack(alignment: .center, spacing: 10) {
                            Text("\(participantArr[index-1])")
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
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .cornerRadius(6)
                    
                    HStack {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center, spacing: 10) {
                            ForEach(1..<participantCnt+1, id: \.self) { index in
                                
                                    Text("\(participantArr[index-1])")
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
        .padding(.horizontal, 32)
    }
}

// #Preview {
//     TravelDetailView()
// }
