//
//  TravelChoiceInRecordModal.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct TravelChoiceInRecordModal: View {    
    @Binding var chosenTravel: Travel?
    var travelArray: [Travel]
    
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
    
    init(chosenTravel: Binding<Travel?>) {
        _chosenTravel = chosenTravel
        travelArray = [Travel]()
        do {
            try travelArray = PersistenceController.shared.container.viewContext.fetch(Travel.fetchRequest()).sorted(by: sortRule)
        } catch {
            print("error fetching travelArray: \(error.localizedDescription)")
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
                ForEach(travelArray.sorted(by: sortRule)) { travel in
                    HStack(spacing: 0) {
                        TravelBlockView(travel: travel, chosenTravel: chosenTravel)
                            .onTapGesture {
                                chosenTravel = travel
                            }
                        Spacer()
                            .frame(width: 10)
                    }
                }
                Spacer()
                    .frame(width: 10)
            }
        }
    }
}

struct TravelBlockView: View {
    let travel: Travel
    let chosenTravel: Travel?
    let now = Date()
    
    var body: some View {
        VStack(spacing: 0) { // ^^^
            if let chosenTravel {
                Group {
                    if let name = travel.name, name == "Default" {
                        ZStack {
                            Group {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(.white)
                                    .layoutPriority(-1)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.gray300, lineWidth: 1)
                                    .layoutPriority(-1)
                                
                                // 뷰 크기 조정용 히든 뷰
                                Text("00.00.00 ~\n00.00.00")
                                    .lineSpacing(2)
                                    .font(.caption2)
                                .padding(.top, 41) // figma: 41
                                .padding(.bottom, 8) // figma: 8
                                .padding(.leading, 8) // figma: 8
                                .padding(.trailing, 41) // figma: 31
                                .hidden()
                                
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
                            }
                            .opacity(travel.id == chosenTravel.id ? 1 : 0.6)
                            
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: 10)
                                HStack(spacing: 0) {
                                    Spacer()
                                        .frame(width: 10)
                                    CheckStickerView(travel: travel, chosenTravel: chosenTravel)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .layoutPriority(-1)
                        }
                    } else {
                        ZStack {
                            Group {
                                ZStack {
                                    Image("travelChoiceExample")
                                        .resizable()
                                        .scaledToFill()
                                    LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                                }
                                .layoutPriority(-1)
                                
                                ZStack {
                                    // 뷰 크기 조정용 히든 뷰
                                    Text("00.00.00 ~\n00.00.00")
                                        .padding(.top, 41) // figma: 41
                                        .padding(.bottom, 8) // figma: 8
                                        .padding(.leading, 8) // figma: 8
                                        .padding(.trailing, 41) // figma: 31
                                        .lineSpacing(2)
                                        .font(.caption2)
                                    .hidden()
                                    
                                    Group {
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
                                    .padding(.top, 41) // figma: 41
                                    .padding(.bottom, 8) // figma: 8
                                    .padding(.leading, 8) // figma: 8
                                    .padding(.trailing, 41) // figma: 31
                                }
                            }
                            .opacity(travel.id == chosenTravel.id ? 1 : 0.6)
                            
                            VStack(spacing: 0) {
                                Spacer()
                                    .frame(height: 10)
                                HStack(spacing: 0) {
                                    Spacer()
                                        .frame(width: 10)
                                    CheckStickerView(travel: travel, chosenTravel: chosenTravel)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .layoutPriority(-1)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Spacer()
                    .frame(height: 6)
                
                Text(travel.name != "Default" ? travel.name ?? "-" : " ")
                    .lineLimit(3)
                    .foregroundStyle(.black)
                    .font(.subhead1)
                    .opacity(travel.id == chosenTravel.id ? 1 : 0.6)
                    .padding(.horizontal, 10)
                    .layoutPriority(-1)
                
                Spacer()
                    .frame(height: 2) // 눈으로 보기에 비슷하게 적당히 수정했음
                
                Group {
                    if travel.name == "Default" {
                        EmptyView()
                    } else {
                        if travel.startDate ?? Date.distantPast < now && travel.endDate ?? Date.distantFuture > now {
                            Text("여행 중")
                                .foregroundStyle(.mainPink)
                                .font(.caption1)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                        } else if travel.startDate ?? Date.distantPast > now {
                            Text("다가오는 여행")
                                .foregroundStyle(.black)
                                .font(.caption1)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                        } else {
                            Text("지난 여행")
                                .foregroundStyle(.gray300)
                                .font(.caption1)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                        }
                    }
                } // 일자와 시분초의 문제 해결하기 ^^^
            }
        }
    }
}

struct CheckStickerView: View {
    let travel: Travel
    let chosenTravel: Travel
    
    var body: some View {
        ZStack {
            Circle()
                .fill(travel.id == chosenTravel.id ? Color(.mainPink) : .black)
                .frame(width: 20, height: 20)
                .opacity(travel.id == chosenTravel.id ? 1.0 : 0.25)
                .overlay(
                    Circle()
                        .strokeBorder(.white, lineWidth: 1.0)
                )
            if travel.id == chosenTravel.id {
                Image("circleLabelCheck")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            }
        }
    }
}

#Preview {
    TravelChoiceInRecordModal(chosenTravel: .constant(Travel()))
}
