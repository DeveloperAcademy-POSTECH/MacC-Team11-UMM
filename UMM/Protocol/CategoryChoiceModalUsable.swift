//
//  CategoryChoiceModalUsable.swift
//  UMM
//
//  Created by Wonil Lee on 10/22/23.
//

import Foundation

protocol CategoryChoiceModalUsable {
    var category: ExpenseInfoCategory { get }
    func setCategory(as category: ExpenseInfoCategory)
}
