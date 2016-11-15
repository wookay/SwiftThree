//
//  XCTest.swift
//  Test
//
//  Created by wookyoung on 2/22/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation

import XCTest
typealias WTestCase = XCTestCase

class AssertBase {
    
    func equal<T: Equatable>(_ expression1: T?, _ expression2: T?, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message)
    }
    
    func equal<T: Equatable>(_ expression1: T, _ expression2: T, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message)
    }
    
    func equal<T: Equatable>(_ expression1: [T], _ expression2: [T], _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message)
    }
    
    func equal<T: Equatable>(_ expression1: ArraySlice<T>, _ expression2: ArraySlice<T>, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(expression1, expression2, message)
    }
    
    func True(_ expression: Bool, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertTrue(expression, message)
    }
    
    // (Int, Int)
    func equal(_ expression1: (Int,Int), _ expression2: (CGFloat, CGFloat), _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        let a = (CGFloat(expression1.0), CGFloat(expression1.1))
        XCTAssertTrue(a == expression2)
    }
    
    func equal(_ expression1: (CGFloat,CGFloat), _ expression2: (CGFloat, CGFloat), _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(String(describing: expression1), String(describing: expression2), message)
    }
    
    // NSRange
    func equal(_ expression1: NSRange, _ expression2: NSRange, _ message: String = "", file: StaticString = #file, function: String = #function, line: UInt = #line) {
        XCTAssertEqual(String(describing: expression1), String(describing: expression2), message)
    }
}

let Assert = AssertBase()
