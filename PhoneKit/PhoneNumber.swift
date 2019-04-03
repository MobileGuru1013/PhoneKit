//
//  PhoneNumber.swift
//  PhoneKit
//
//  Created by Bruce Colby on 6/19/18.
//  Copyright © 2018 Bruce Colby. All rights reserved.
//

import Foundation

public enum PhoneNumberDirection {
    case forward
    case backward
}

public enum PhoneNumber {
    case numbers
    case elegant
    case custom(String)
    
    private var numbers: [String] {
        return "0000000000".toArray // [0,0,0,0,0,0,0,0,0,0]
    }
    
    private var elegant: [String] {
        return "(000) 000-0000".toArray // [(,0,0,0,), ,0,0,0,-,0,0,0,0]
    }
    
    public func format(text: String, direction: PhoneNumberDirection = .forward) -> String {
        switch self {
        case .numbers:
            let format = numbers
            return formatter(format: format, text: text, direction: direction)
        case .elegant:
            let format = elegant
            return formatter(format: format, text: text, direction: direction)
        case .custom(let format):
            return formatter(format: format.toArray, text: text, direction: direction)
        }
    }
    
    public func validate(text: String) -> Bool {
        let digits = raw(text: text).toArray
        let count = digits.count
        
        // TODO: Add support for country codes
        // This protects against a user entering a phone number, such as 140-123-4567.
        // A phone number cannot start with a 1, as that is reserved as a country code.
        if (digits.count > 0 && digits.first == "1") {
            return false
        }
        
        switch self {
        case .numbers:
            return count == numbers.digitsOnly.count
        case .elegant:
            return count == elegant.digitsOnly.count
        case .custom(let format):
            return count == format.toArray.digitsOnly.count
        }
    }
    
    public func raw(text: String) -> String  {
        return text.toArray.filter { $0.isNumeric }.joined()
    }
    
    /// Formats a phone number.
    private func formatter(format: [String], text: String, direction: PhoneNumberDirection) -> String {
        var digits = text.toArray.filter { $0.isNumeric }
        
        return format.enumerated().map { (offset: Int, element: String) -> String in
            if element.isNumeric {
                return digits.count > 0 ? digits.removeFirst() : ""
            }
            
            return element
            }.trimPhoneNumber(direction: direction)
            .joined()
        
    }
}

fileprivate extension String {
    /// Coverts a string to an array of string characters.
    var toArray: [String] {
        return Array(self).map { "\($0)" }
    }
    
    /// Returns true if string is numeric.
    var isNumeric: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }
    
    /// Returns true if the string is empty or contains only whitespace.
    var isDrained: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

fileprivate extension ArraySlice where Element == String {
    /// Converts an ArraySlice<String> to a [String].
    var toStringArray: [String] {
        return self.map { "\($0)" }
    }
}

fileprivate extension Array where Element == String {
    var digitsOnly: [String] {
        return self.filter { $0.isNumeric }
    }
    
    
    /// Trims array until there is at least one digit, i.e., '(216)' becomes (216.
    func trimPhoneNumber(direction: PhoneNumberDirection) -> [String] {
        return self.trimUntilDigit(array: self, prevArray: self, direction: direction)
    }
    
    /// Recursive function that trims array until there are no elements left or it finds a digit.
    func trimUntilDigit(array: [String], prevArray: [String], direction: PhoneNumberDirection) -> [String] {
        if array.count == 0 {
            return [String]()
        }
        
        if let last = array.last {
            if last.isDrained || !last.isNumeric {
                return trimUntilDigit(array: array[0..<array.count-1].toStringArray, prevArray: array, direction: direction)
            }
        }
        
        
        // Purpose of checking the direction is to ensure user can delete data
        // For example, if user is entering text, we consider the direciton to be forward,
        // if user is deleting text, we consider the direction to be backward.
        //
        // By returning the array in the forward direction, when the user enters 216,
        // the user will see (216) instead of (216 in the textfield, which is visually more appealing.
        //
        // By returning the array in the backward direction, when the user deletes (216) - 8,
        // the user will see (216, instead of (216) -.
        switch direction {
        case .forward:
            return prevArray
        case .backward:
            return array
        }
    }
}
