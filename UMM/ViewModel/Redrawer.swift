//
//  Redrawer.swift
//  UMM
//
//  Created by Wonil Lee on 10/22/23.
//

import Foundation

class Redrawer: ObservableObject {
    @Published var dummy = true
    func redraw() {
        dummy.toggle()
    }
}
