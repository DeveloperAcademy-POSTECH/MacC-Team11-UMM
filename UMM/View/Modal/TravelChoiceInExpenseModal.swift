//
//  TravelChoiceInExpenseModal.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct TravelChoiceInExpenseModal: View {
    @Binding var selectedTravel: Travel?
    @State private var travelArray = [Travel]()
    @Binding var selectedCountry: Int64
    @State private var flagNameArrayDict: [UUID: [String]] = [:]
    @State private var defaultImageStringDict: [UUID: String] = [:]
    
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
        .onAppear {
            do {
                try travelArray = PersistenceController.shared.container.viewContext.fetch(Travel.fetchRequest()).sorted(by: sortRule)
            } catch {
                print("error fetching travelArray: \(error.localizedDescription)")
            }
            updateFlagNameArrayDictAndDefaultImageStringDict()
        }
    }
    
    let sortRule: (Travel, Travel) -> Bool = {
        let nowDate = Date()
        
        if $0.name != "Default" && $1.name == "Default" {
            return false
        } else if $0.name == "Default" && $1.name != "Default" {
            return true
        }
        
        let s0 = $0.startDate ?? Date.distantPast
        let e0 = $0.endDate ?? Date.distantFuture
        let s1 = $1.startDate ?? Date.distantPast
        let e1 = $1.endDate ?? Date.distantFuture
        
        enum TravelTimeState: Int {
            case current
            case past
            case coming
        }
        
        var state0 = TravelTimeState.current
        var state1 = TravelTimeState.current
        
        if s0 <= nowDate && nowDate <= e0 {
            state0 = .current
        } else if s0 > nowDate {
            state0 = .coming
        } else {
            state0 = .past
        }
        
        if s1 <= nowDate && nowDate <= e1 {
            state1 = .current
        } else if s1 > nowDate {
            state1 = .coming
        } else {
            state1 = .past
        }
        
        if state0 != state1 {
            return state0.rawValue < state1.rawValue
        } else { // 같은 상태의 두 여행
            if state0 == .current { // 진행 중 여행
                return s0 >= s1 // 시작일이 최신인 여행 먼저
            } else if state0 == .past { // 지난 여행
                return e0 >= e1 // 종료일이 최신인 여행 먼저
            } else { // 다가오는 여행
                return s0 <= s1 // 시작일이 과거인(가까운) 여행 먼저
            }
        }
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
                ForEach(travelArray.sorted(by: sortRule).filter { $0.name ?? "" != "Default" }, id: \.self) { travel in // 임시 기록("Default") 제외
                    HStack(spacing: 0) {
                        TravelBlockView(travel: travel, chosenTravel: selectedTravel, flagNameArray: flagNameArrayDict[travel.id ?? UUID()] ?? [], defaultImageString: defaultImageStringDict[travel.id ?? UUID()] ?? "DefaultImage")
                            .onTapGesture {
                                if let selectedId = selectedTravel?.id, let travelId = travel.id, selectedId != travelId {
                                    selectedTravel = travel
                                    selectedTravel = selectedTravel
                                    selectedCountry = Int64(-2)
                                }
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
    
    private func updateFlagNameArrayDictAndDefaultImageStringDict() {
        for travel in travelArray {
            let expenseArray = travel.expenseArray!.allObjects as? [Expense]
            var countryArray: [Int] = []
            var countryWeightedArray: [(Int, Int)] = [] // (국가 키, 등장 횟수)
            if let expenseArray {
                for expense in expenseArray {
                    if !countryArray.contains(Int(expense.country)) {
                        countryArray.append(Int(expense.country))
                        countryWeightedArray.append((Int(expense.country), 1))
                    } else {
                        let index = countryWeightedArray.firstIndex { $0.0 == Int(expense.country) }
                        if let index {
                            countryWeightedArray[index].1 += 1
                        }
                    }
                }
            }
            countryWeightedArray.sort { tuple0, tuple1 in
                if tuple0.1 > tuple1.1 { // 등장 횟수의 내림차순으로 정렬
                    return true
                } else if tuple0.1 < tuple1.1 {
                    return false
                } else {
                    return tuple0.0 < tuple1.0 // 등장 횟수 같으면 키 순서로 정렬
                }
            }
            if countryWeightedArray.count > 0 {
                countryWeightedArray = [(Int, Int)](countryWeightedArray[0..<min(countryWeightedArray.count, 4)])
            }
            
            if let travelId = travel.id {
                flagNameArrayDict[travelId] = countryWeightedArray.map { $0.0 }.map { CountryInfoModel.shared.countryResult[$0]?.flagString ?? "DefaultFlag" }
                
                defaultImageStringDict[travelId] = CountryInfoModel.shared.countryResult[countryWeightedArray.first?.0 ?? -1]?.defaultImageString ?? "DefaultImage"
            }
        }
    }
}

// #Preview {
//     TravelChoiceInExpenseModal(viewModel: ManualRecordViewModel())
// }
