//
//  Extensions.swift
//  AtxHealthInspection
//
//  Created by Toph Matta on 7/5/24.
//

import SwiftUI
import CoreLocation

extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
}

extension Data {
    #if DEBUG
    func prettyPrint() {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) 
        else { return }
        print(prettyString)
    }
    #endif
}

extension String {
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    #if DEBUG
    func printUnicodeScalars() {
        for (index, scalar) in unicodeScalars.enumerated() {
            print("Character at index \(index): '\(scalar)' (Unicode: U+\(String(format:"%04X", scalar.value)))")
        }
    }
    #endif
}

extension CLLocationCoordinate2D {
    func isValid() -> Bool {
        return CLLocationCoordinate2DIsValid(self)
    }
}
