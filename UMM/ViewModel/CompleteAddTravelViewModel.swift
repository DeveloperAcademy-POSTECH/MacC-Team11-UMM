//
//  CompleteAddTravelViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/18.
//

import Foundation
import CoreData

class CompleteAddTravelViewModel: ObservableObject {
    let viewContext = PersistenceController.shared.container.viewContext
    
    @Published var travelID = UUID()
}
