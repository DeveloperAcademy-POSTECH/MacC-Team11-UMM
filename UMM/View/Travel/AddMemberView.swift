//
//  AddMemberView.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/14.
//

import SwiftUI

struct AddMemberView: View {
    var body: some View {
        VStack {
            
            Text("AddMemberView")
            
            NavigationLink(destination: CompleteAddTravelView()) {
                NextButtonActive(title: "다음", action: {
                    
                })
                .disabled(true)
            }
            
        }
    }
}

#Preview {
    AddMemberView()
}
