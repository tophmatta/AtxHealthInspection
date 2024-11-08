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

extension Date {
    func toReadable() -> String {
        return self.formatted(date: .numeric, time: .omitted)
    }
}

extension Binding {
    func isNotNil<T: Sendable>() -> Binding<Bool> where Value == T? {
        .init(get: {
            wrappedValue != nil
        }, set: { _ in
            wrappedValue = nil
        })
    }
}

extension Binding where Value: Collection, Value: Sendable {
    func isNotEmpty() -> Binding<Bool> {
        Binding<Bool>(
            get: {
                !self.wrappedValue.isEmpty
            },
            set: { newValue in
                // This set block is required, but we don't need to do anything with newValue
                if !newValue {
                    self.wrappedValue = [] as! Value
                }
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}

extension Collection where Element == Report {
    func filterOldDuplicates() -> [Report] {
        var seen = Set<Report>()
        
        let filterNewest = self.sorted { $0.date > $1.date }.filter { report in
            if seen.contains(report) {
                return false
            } else {
                seen.insert(report)
                return true
            }
        }
        
        return filterNewest
    }
}
