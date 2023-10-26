//
//  TravelChoiceModal.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct TravelChoiceModal: View {
    @ObservedObject private var expenseViewModel = ExpenseViewModel()
    @ObservedObject private var redrawer = Redrawer()
    var viewModel: TravelChoiceModalUsable
    
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            VStack {
                Spacer()
                    .frame(height: 32)
                titleView
                Spacer()
                    .frame(height: 24)
                travelScrollView
            }
        }
    }
    
    let sortRule: (Travel, Travel) -> Bool = {
        if $0.name != "Default" && $1.name == "Default" {
            return false
        } else if $0.name == "Default" && $1.name != "Default" {
            return true
        }
        
        return ($0.lastUpdate ?? Date.distantPast) > ($1.lastUpdate ?? Date.distantPast)
    }
    
    private var titleView: some View {
        HStack {
            Spacer()
                .frame(width: 20)
            Text("여행 선택")
                .foregroundStyle(.black)
                .font(.display1)
            Spacer()
        }
    }
    
    private var travelScrollView: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .top, spacing: 0) {
                Spacer()
                    .frame(width: 20)
                ForEach(viewModel.travelArray.sorted(by: sortRule)) { travel in
                    TravelSquareView(travel: travel, chosenTravel: viewModel.chosenTravel)
                        .onTapGesture {
                            viewModel.setChosenTravel(as: travel)
                            redrawer.redraw()
                        }
                    Spacer()
                        .frame(width: 10)
                }
                Spacer()
                    .frame(width: 10)
            }
        }
    }
}

struct TravelSquareView: View {
    let travel: Travel
    let chosenTravel: Travel?
    let now = Date()
    
    var body: some View {
        VStack(spacing: 6) { // ^^^
            if let chosenTravel {
                Group {
                    if let name = travel.name, name == "Default" {
                        ZStack {
                            // 뷰 크기 조정용 히든 뷰
                            VStack(spacing: 0) {
                                Text("00.00.00 ~\n00.00.00")
                                    .lineSpacing(2)
                                    .font(.caption2)
                            }
                            .padding(.top, 41)
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                            .padding(.trailing, 31)
                            .hidden()
                            
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(.gray300, lineWidth: 1)
                                .layoutPriority(-1)
                            
                            VStack(spacing: 0) {
                                Spacer()
                                HStack(spacing: 0) {
                                    Spacer()
                                    Text("임시 기록")
                                        .foregroundStyle(.gray400)
                                        .font(.subhead1)
                                    Spacer()
                                        .frame(width: 11)
                                }
                                Spacer()
                                    .frame(height: 10)
                            }
                            .layoutPriority(-1)
                            
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: 10)
                                HStack(spacing: 0) {
                                    Spacer()
                                        .frame(width: 10)
                                    CircleLabelView(travel: travel, chosenTravel: chosenTravel)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .layoutPriority(-1)
                        }
                    } else {
                        ZStack {
                            Image("travelChoiceExample")
                                .resizable()
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .layoutPriority(-1)
                            
                            ZStack {
                                // 뷰 크기 조정용 히든 뷰
                                VStack(spacing: 0) {
                                    Text("00.00.00 ~\n00.00.00")
                                        .lineSpacing(2)
                                        .font(.caption2)
                                }
                                .hidden()
                                
                                if let startDate = travel.startDate {
                                    if let endDate = travel.endDate {
                                        Text(startDate.toString(dateFormat: "YY.MM.dd") + " " + "~" + "\n" + endDate.toString(dateFormat: "YY.MM.dd"))
                                            .foregroundStyle(.white)
                                            .lineSpacing(2)
                                            .font(.caption2)
                                            .opacity(0.75)
                                    } else {
                                        Text(startDate.toString(dateFormat: "YY.MM.dd") + " " + "~" + "\n" + "미정")
                                            .foregroundStyle(.white)
                                            .lineSpacing(2)
                                            .font(.caption2)
                                            .opacity(0.75)
                                    }
                                }
                            }
                            .padding(.top, 41)
                            .padding(.bottom, 8)
                            .padding(.leading, 8)
                            .padding(.trailing, 31)
                            
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: 10)
                                HStack(spacing: 0) {
                                    Spacer()
                                        .frame(width: 10)
                                    CircleLabelView(travel: travel, chosenTravel: chosenTravel)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .layoutPriority(-1)
                        }
                    }
                }
                .opacity(travel.id == chosenTravel.id ? 1 : 0.6)
                
                Text(travel.name != "Default" ? travel.name ?? "-" : " ")
                    .lineLimit(3)
                    .foregroundStyle(.black)
                    .font(.subhead1)
                    .opacity(travel.id == chosenTravel.id ? 1 : 0.6)
                    .padding(.horizontal, 10)
                    .layoutPriority(-1)
                
                Group {
                    if travel.name == "Default" {
                        EmptyView()
                    } else {
                        if travel.startDate ?? Date.distantPast < now && travel.endDate ?? Date.distantFuture > now {
                            ZStack {
                                Capsule()
                                    .strokeBorder(.mainPink, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("여행 중")
                                    .foregroundStyle(.mainPink)
                                    .font(.caption1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                            
                        } else if travel.startDate ?? Date.distantPast > now {
                            ZStack {
                                Capsule()
                                    .strokeBorder(.black, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("다가오는 여행")
                                    .foregroundStyle(.black)
                                    .font(.caption1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                        } else {
                            ZStack {
                                Capsule()
                                    .strokeBorder(.gray300, lineWidth: 1.0)
                                    .layoutPriority(-1)
                                
                                Text("지난 여행")
                                    .foregroundStyle(.gray300)
                                    .font(.caption1)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                            }
                        }
                    }
                } // 일자와 시분초의 문제 해결하기 ^^^
            }
        }
    }
}

struct CircleLabelView: View {
    let travel: Travel
    let chosenTravel: Travel
    
    var body: some View {
        if travel.id == chosenTravel.id {
            ZStack {
                Circle()
                    .fill(Color(.mainPink))
                    .frame(width: 20, height: 20)
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
    TravelChoiceModal(viewModel: ManualRecordViewModel())
}
