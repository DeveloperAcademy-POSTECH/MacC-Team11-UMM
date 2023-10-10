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
            NavigationLink(destination: AddTravelView(month: month), label: {
                Text("임의버튼")
            })
        }
    }
}

#Preview {
    TravelListView(month: Date())
}
