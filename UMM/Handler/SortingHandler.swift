//
//  SortingHandler.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/09.
//

import Foundation

func sortExpenseByDate(expenseArr: [Expense]?) -> [Expense] {
    print("sortExpenseByDate")
    guard var expenses = expenseArr else {
        return []
    }
    
    expenses.sort { (expense1, expense2) -> Bool in
        return expense1.payDate! >= expense2.payDate!
    }
    
    return expenses
}

// func sortTravelByDate(dateArray: [Travel]?) -> [Travel] {
//     return
// }
