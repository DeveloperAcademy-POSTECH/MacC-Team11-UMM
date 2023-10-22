//
//  TravelChoiceModalSharable.swift
//  UMM
//
//  Created by Wonil Lee on 10/22/23.
//

import Foundation

protocol TravelChoiceModalUsable {
    var chosenTravel: Travel? { get }
    var travelArray: [Travel] { get }
    func setChosenTravel(as travel: Travel)
}
