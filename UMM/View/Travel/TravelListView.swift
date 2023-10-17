//
//  TravelListView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct TravelListView: View {

    @State var month: Date
    @State var currentTravel = findCurrentTravel()

    var body: some View {
        NavigationStack {
            NavigationLink(destination: AddTravelView(), label: {
                Text("currentTravel: \(currentTravel!)")
                Text("+")
            })
        }
        .onAppear {
            currentTravel = findCurrentTravel()
        }
    }
}

#Preview {
    TravelListView(month: Date())
}
