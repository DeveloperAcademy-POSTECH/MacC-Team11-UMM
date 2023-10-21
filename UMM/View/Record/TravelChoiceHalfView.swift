//
//  TravelChoiceHalfView.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct TravelChoiceHalfView: View {
    @ObservedObject var viewModel: RecordViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 15)
            titleView
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    Spacer()
                        .frame(width: 18)
                    ForEach(viewModel.travelArray.sorted(by: sortRule)) { travel in
                        TravelSquareView(travel: travel, chosenTravel: viewModel.chosenTravel)
                            .onTapGesture {
                                viewModel.chosenTravel = travel
                            }
                        Spacer()
                            .frame(width: 11)
                    }
                    Spacer()
                        .frame(width: 7)
                }
            }
        }
    }
    
    let sortRule: (Travel, Travel) -> Bool = {
        if $0.name != "Default" && $1.name == "Default" {
            return false
        } else if $0.name == "Default" && $1.name != "Default" {
            return true
        }
        
        return ($0.lastUpdate ?? Date.distantPast) < ($1.lastUpdate ?? Date.distantPast)
    }
    
    private var titleView: some View {
        HStack {
            Spacer()
                .frame(width: 2)
            Text("여행 선택")
            Spacer()
        }
    }
}

struct TravelSquareView: View {
    let travel: Travel
    let chosenTravel: Travel?
    let now = Date()
    
    var body: some View {
        VStack(spacing: 10) { // ^^^
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.brown)
                    .layoutPriority(-1)
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 7)
                    HStack(spacing: 0) {
                        Spacer()
                        CircleLabelView(travel: travel, chosenTravel: chosenTravel)
                        Spacer()
                            .frame(width: 7)
                    }
                    Spacer()
                }
                .layoutPriority(-1)
                
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 8)
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 53 + 3)
                        ZStack {
                            VStack(spacing: 0) {
                                Text("00.00.00 ~\n00.00.00")
                                    .lineSpacing(4)
                                    .font(.callout)
                            }
                            .hidden()
                            
                            if let startDate = travel.startDate, let endDate = travel.endDate {
                                VStack {
                                    Text(startDate.toString(dateFormat: "YY.MM.dd") + " " + "~" + "\n" + endDate.toString(dateFormat: "YY.MM.dd"))
                                        .lineSpacing(4)
                                        .font(.callout)
                                }
                            }
                        }
                        Spacer()
                            .frame(height: 6 + 4)
                    }
                    Spacer()
                        .frame(width: 14)
                }
            }
            Text(travel.name ?? "-")
            Group {
                if travel.startDate ?? Date.distantPast < now && travel.endDate ?? Date.distantFuture > now {
                    Text("여행 중")
                } else if travel.startDate ?? Date.distantPast > now {
                    Text("다가오는 여행")
                } else {
                    Text("지난 여행")
                }
            }
        }
    }
}

struct CircleLabelView: View {
    let travel: Travel
    let chosenTravel: Travel?
    
    var body: some View {
        if let chosenTravel, travel.id == chosenTravel.id {
            ZStack {
                Circle()
                    .fill(Color(0x7b61ff)) // 색상 디자인 시스템 형식으로 고치기 ^^^
                    .frame(width: 19, height: 19)
                    .overlay(
                        Circle()
                            .strokeBorder(.white, lineWidth: 1.0)
                    )
                Image("circleLabelCheck")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            }
        } else {
            Circle()
                .fill(.black)
                .opacity(0.25)
                .frame(width: 19, height: 19)
                .overlay(
                    Circle()
                        .strokeBorder(.white, lineWidth: 1.0)
                )
        }
    }
}

#Preview {
    TravelChoiceHalfView(viewModel: RecordViewModel())
}
