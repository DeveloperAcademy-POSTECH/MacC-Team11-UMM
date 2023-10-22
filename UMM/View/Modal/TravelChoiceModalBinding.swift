//
//  TravelChoiceModalBinding.swift
//  UMM
//
//  Created by Wonil Lee on 10/16/23.
//

import SwiftUI

struct TravelChoiceModalBinding: View {
    @ObservedObject private var redrawer = Redrawer()
    
    @Binding var selectedTravel: Travel?
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
    
    init(selectedTravel: Binding<Travel?>) {
        _selectedTravel = selectedTravel
        travelArray = []
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
                    TravelSquareView(travel: travel, chosenTravel: selectedTravel)
                        .onTapGesture {
                            selectedTravel = travel
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

// #Preview {
//     TravelChoiceModalBinding(viewModel: ManualRecordViewModel())
// }
