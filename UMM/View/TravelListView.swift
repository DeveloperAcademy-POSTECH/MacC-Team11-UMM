//
//  TravelListView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct TravelListView: View {

    @State var month: Date
    @ObservedObject var findCurrentTravelHandler = FindCurrentTravelHandler()


    var body: some View {
        NavigationStack {
            Text(findCurrentTravelHandler.currentTravel?.name ?? "no current Travel")
            NavigationLink(destination: AddTravelView(), label: {
                Text("+")
            })
        }
        .onAppear {
            print("####")
            print("MainView Appeared")
            findCurrentTravelHandler.findCurrentTravel()
        }
    }
}

#Preview {
    TravelListView(month: Date())
}
