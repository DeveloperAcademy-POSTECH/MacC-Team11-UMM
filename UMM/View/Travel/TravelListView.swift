//
//  TravelListView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/10.
//

import SwiftUI

struct TravelListView: View {

    @State var month: Date

    var body: some View {
        NavigationStack {
            NavigationLink(destination: AddTravelView(), label: {
                
                VStack {
                    Text("+")
                }
                
            })
        }
    }
}

#Preview {
    TravelListView(month: Date())
}
