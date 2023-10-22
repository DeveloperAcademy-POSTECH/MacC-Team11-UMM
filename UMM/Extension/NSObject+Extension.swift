//
//  NSObject+Extension.swift
//  UMM
//
//  Created by 김태현 on 10/20/23.
//

import Foundation
import SwiftUI
extension NSObject {
  func accessibilityDescendant(passing test: (Any) -> Bool) -> Any? {

    if test(self) { return self }

    for child in accessibilityElements ?? [] {
      if test(child) { return child }
      if let child = child as? NSObject, let answer = child.accessibilityDescendant(passing: test) {
        return answer
      }
    }

    for subview in (self as? UIView)?.subviews ?? [] {
      if test(subview) { return subview }
      if let answer = subview.accessibilityDescendant(passing: test) {
        return answer
      }
    }

    return nil
  }
    
    func accessibilityDescendant(identifiedAs id: String) -> Any? {
      return accessibilityDescendant {
        // For reasons unknown, I cannot cast a UIView to a UIAccessibilityIdentification at runtime.
        return ($0 as? UIView)?.accessibilityIdentifier == id
        || ($0 as? UIAccessibilityIdentification)?.accessibilityIdentifier == id
      }
    }
    
    func buttonAccessibilityDescendant() -> Any? {
      return accessibilityDescendant { ($0 as? NSObject)?.accessibilityTraits == .button }
    }
}
