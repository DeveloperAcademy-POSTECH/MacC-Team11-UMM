//
//  NewView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/23.
//

import SwiftUI

struct NewView: View {
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Button {
                print("GOod")
            } label: {
                Text("GOOD BUTTON")
            }
        }
    }
}

#Preview {
    NewView()
}
