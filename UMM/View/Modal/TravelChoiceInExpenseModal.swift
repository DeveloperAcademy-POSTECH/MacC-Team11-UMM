//
//  TravelChoiceInExpenseModal.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct TravelChoiceInExpenseModal: View {
    @Binding var selectedTravel: Travel?
    private var travelArray: [Travel]
    @Binding var selectedCountry: Int64
    @State private var flagNameArrayDict: [UUID: [String]] = [:]
    
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
            updateFlagNameArrayDict()
        }
    }
    
    init(selectedTravel: Binding<Travel?>, selectedCountry: Binding<Int64>) {
        _selectedTravel = selectedTravel
        travelArray = [Travel]()
        _selectedCountry = selectedCountry
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
                ForEach(travelArray.sorted(by: sortRule).filter { $0.name ?? "" != "Default" }, id: \.self) { travel in // 임시 기록("Default") 제외
                    HStack(spacing: 0) {
                        TravelBlockView(travel: travel, chosenTravel: selectedTravel, flagNameArray: flagNameArrayDict[travel.id ?? UUID()] ?? [])
                            .onTapGesture {
                                if let selectedId = selectedTravel?.id, let travelId = travel.id, selectedId != travelId {
                                    selectedTravel = travel
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
    
    private func updateFlagNameArrayDict() {
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
            }
        }
    }
}

// #Preview {
//     TravelChoiceInExpenseModal(viewModel: ManualRecordViewModel())
// }
