//
//  ContentView.swift
//  UMM
//
//  Created by Wonil Lee on 10/5/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Text("RoundedRectangle")
                .frame(height: 50)
                .font(.system(size: 19))
//                .padding()
                .border(.purple)
                .background(Color(.yellow))
                .frame(height: 100)
                
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


