// from https://github.com/apple/swift-corelibs-xctest/blob/master/Sources/XCTest/Public/XCTAssert.swift


import Foundation
import UIKit

private enum _XCTAssertion {
    case equal
    case equalWithAccuracy
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
    case notEqual
    case notEqualWithAccuracy
    case `nil`
    case notNil
    case `true`
    case `false`
    case fail
    case throwsError
    
    var name: String? {
        switch(self) {
        case .equal: return "equal"
        case .equalWithAccuracy: return "XCTAssertEqualWithAccuracy"
        case .greaterThan: return "XCTAssertGreaterThan"
        case .greaterThanOrEqual: return "XCTAssertGreaterThanOrEqual"
        case .lessThan: return "XCTAssertLessThan"
        case .lessThanOrEqual: return "XCTAssertLessThanOrEqual"
        case .notEqual: return "XCTAssertNotEqual"
        case .notEqualWithAccuracy: return "XCTAssertNotEqualWithAccuracy"
        case .nil: return "XCTAssertNil"
        case .notNil: return "XCTAssertNotNil"
        case .true: return "XCTAssertTrue"
        case .false: return "XCTAssertFalse"
        case .throwsError: return "XCTAssertThrowsError"
        case .fail: return nil
        }
    }
}

private enum _XCTAssertionResult {
    case success
    case expectedFailure(String?)
    case unexpectedFailure(Error)
    
    var expected: Bool {
        switch (self) {
        case .unexpectedFailure(_):
            return false
        default:
            return true
        }
    }
    
    func failureDescription(_ assertion: _XCTAssertion) -> String {
        let explanation: String
        switch (self) {
        case .success:
            explanation = "passed"
        case .expectedFailure(let details?):
            explanation = "\(ansi_red)Failed:\(ansi_reset) \(details)"
        case .expectedFailure(_):
            explanation = "Failed"
        case .unexpectedFailure(let error):
            explanation = "threw error \"\(error)\""
        }
        
        //        if let _ = assertion.name {
        //            return "\(explanation)"
        //        } else {
        return explanation
        //        }
    }
}

internal func XCTPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    print(items, separator: separator, terminator: terminator)
    fflush(stdout)
}

struct XCTFailure {
    var message: String
    var failureDescription: String
    var expected: Bool
    var file: String
    var function: String
    var line: Int
    
    func emit(_ method: String) {
        XCTPrint("\(file):\(line): \(expected ? "" : "unexpected ")error: \(method) : \(failureDescription) - \(message)")
    }
}

internal typealias TimeInterval = Double
internal struct XCTRun {
    var duration: TimeInterval
    var method: String
    var passed: Bool
    var failures: [XCTFailure]
    var unexpectedFailures: [XCTFailure] {
        get { return failures.filter({ failure -> Bool in failure.expected == false }) }
    }
}


func print_dot() {
    print(".", terminator: "")
}

func print_ln() {
    print("")
}


internal var XCTFailureHandler: ((XCTFailure) -> Void)?
internal var XCTAllRuns = [XCTRun]()


class Assertion {
    fileprivate func _XCTEvaluateAssertion(_ assertion: _XCTAssertion, message: String = "", file: String = #file, function: String = #function, line: Int = #line, expression: () throws -> _XCTAssertionResult) {
        let result: _XCTAssertionResult
        do {
            result = try expression()
        } catch {
            result = .unexpectedFailure(error)
        }
        
        switch result {
        case .success:
            print_dot()
            UnitTest.result.passed += 1
            return
            
        default:
            print_ln()
            Logger.info(result.failureDescription(assertion), file: file, function: function, line: line)
            UnitTest.result.failed += 1
            if let handler = XCTFailureHandler {
                handler(XCTFailure(message: message, failureDescription: result.failureDescription(assertion), expected: result.expected, file: file, function: function, line: line))
            }
        }
    }
    
    /// This function emits a test failure if the general Bool expression passed
    /// to it evaluates to false.
    ///
    /// - Requires: This and all other XCTAssert* functions must be called from
    ///   within a test method, as indicated by `XCTestCaseProvider.allTests`.
    ///   Assertion failures that occur outside of a test method will *not* be
    ///   reported as failures.
    ///
    /// - Parameter expression: A boolean test. If it evaluates to false, the
    ///   assertion fails and emits a test failure.
    /// - Parameter message: An optional message to use in the failure if the
    ///   assertion fails. If no message is supplied a default message is used.
    /// - Parameter file: The file name to use in the error message if the assertion
    ///   fails. Default is the file containing the call to this function. It is
    ///   rare to provide this parameter when calling this function.
    /// - Parameter line: The line number to use in the error message if the
    ///   assertion fails. Default is the line number of the call to this function
    ///   in the calling file. It is rare to provide this parameter when calling
    ///   this function.
    ///
    /// - Note: It is rare to provide the `file` and `line` parameters when calling
    ///   this function, although you may consider doing so when creating your own
    ///   assertion functions. For example, consider the following custom assertion:
    ///
    ///   ```
    ///   // AssertEmpty.swift
    ///
    ///   func AssertEmpty<T>(elements: [T]) {
    ///       XCTAssertEqual(elements.count, 0, "Array is not empty")
    ///   }
    ///   ```
    ///
    ///  Calling this assertion will cause XCTest to report the failure occured
    ///  in the file where `AssertEmpty()` is defined, and on the line where
    ///  `XCTAssertEqual` is called from within that function:
    ///
    ///  ```
    ///  // MyFile.swift
    ///
    ///  AssertEmpty([1, 2, 3]) // Emits "AssertEmpty.swift:3: error: ..."
    ///  ```
    ///
    ///  To have XCTest properly report the file and line where the assertion
    ///  failed, you may specify the file and line yourself:
    ///
    ///  ```
    ///  // AssertEmpty.swift
    ///
    ///  func AssertEmpty<T>(elements: [T], file: String = #file, line: Int = #line) {
    ///      XCTAssertEqual(elements.count, 0, "Array is not empty", file: file, function: function, line: line)
    ///  }
    ///  ```
    ///
    ///  Now calling failures in `AssertEmpty` will be reported in the file and on
    ///  the line that the assert function is *called*, not where it is defined.
    func XCTAssert(_ expression: @autoclosure () throws -> Bool, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        XCTAssertTrue(expression, message, file: file, function: function, line: line)
    }
    
    func equal<T: Equatable>(_ expression1: @autoclosure () throws -> T?, _ expression2: @autoclosure () throws -> T?, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2)")
            }
        }
    }

    func equal<T: Equatable>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T: Equatable>(_ expression1: @autoclosure () throws -> ArraySlice<T>, _ expression2: @autoclosure () throws -> ArraySlice<T>, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T: Equatable>(_ expression1: @autoclosure () throws -> ContiguousArray<T>, _ expression2: @autoclosure () throws -> ContiguousArray<T>, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T: Equatable>(_ expression1: @autoclosure () throws -> [T], _ expression2: @autoclosure () throws -> [T], _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func equal<T, U: Equatable>(_ expression1: @autoclosure () throws -> [T: U], _ expression2: @autoclosure () throws -> [T: U], _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2)")
            }
        }
    }
    
    func XCTAssertEqualWithAccuracy<T: FloatingPoint>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, accuracy: T, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equalWithAccuracy, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if abs(value1.distance(to: value2)) <= abs(accuracy.distance(to: T(0))) {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2) +/- (\"\(accuracy)\")")
            }
        }
    }
    
    func XCTAssertFalse(_ expression: @autoclosure () throws -> Bool, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.false, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if Bool(value) {
                return .success
            } else {
                return .expectedFailure(nil)
            }
        }
    }
    
    func XCTAssertGreaterThan<T: Comparable>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.greaterThan, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 > value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is not greater than \(value2)")
            }
        }
    }
    
    func XCTAssertGreaterThanOrEqual<T: Comparable>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.greaterThanOrEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 >= value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is less than \(value2)")
            }
        }
    }
    
    func XCTAssertLessThan<T: Comparable>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.lessThan, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 < value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is not less than \(value2)")
            }
        }
    }
    
    func XCTAssertLessThanOrEqual<T: Comparable>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.lessThanOrEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 <= value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is greater than \(value2)")
            }
        }
    }
    
    func XCTAssertNil(_ expression: @autoclosure () throws -> Any?, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.nil, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if value == nil {
                return .success
            } else {
                return .expectedFailure("\"\(value!)\"")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(_ expression1: @autoclosure () throws -> T?, _ expression2: @autoclosure () throws -> T?, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.notEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(_ expression1: @autoclosure () throws -> ContiguousArray<T>, _ expression2: @autoclosure () throws -> ContiguousArray<T>, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.notEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(_ expression1: @autoclosure () throws -> ArraySlice<T>, _ expression2: @autoclosure () throws -> ArraySlice<T>, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.notEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T: Equatable>(_ expression1: @autoclosure () throws -> [T], _ expression2: @autoclosure () throws -> [T], _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.notEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqual<T, U: Equatable>(_ expression1: @autoclosure () throws -> [T: U], _ expression2: @autoclosure () throws -> [T: U], _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.notEqual, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 != value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) is equal to \(value2)")
            }
        }
    }
    
    func XCTAssertNotEqualWithAccuracy<T: FloatingPoint>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, _ accuracy: T, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.notEqualWithAccuracy, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if abs(value1.distance(to: value2)) > abs(accuracy.distance(to: T(0))) {
                return .success
            } else {
                return .expectedFailure("\(value1) is equal to \(value2) +/- (\"\(accuracy)\")")
            }
        }
    }
    
    func XCTAssertNotNil(_ expression: @autoclosure () throws -> Any?, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.nil, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if value != nil {
                return .success
            } else {
                return .expectedFailure(nil)
            }
        }
    }
    
    func True(_ expression: @autoclosure () throws -> Bool, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.true, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if Bool(value) {
                return .success
            } else {
                return .expectedFailure(String(value))
            }
        }
    }
    
    func XCTAssertTrue(_ expression: @autoclosure () throws -> Bool, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.true, message: message, file: file, function: function, line: line) {
            let value = try expression()
            if Bool(value) {
                return .success
            } else {
                return .expectedFailure(nil)
            }
        }
    }
    
    func XCTFail(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.fail, message: message, file: file, function: function, line: line) {
            return .expectedFailure(nil)
        }
    }
    
    func XCTAssertThrowsError<T>(_ expression: @autoclosure () throws -> T, _ message: String = "", file: String = #file, function: String = #function, line: Int = #line, _ errorHandler: (_ error: Error) -> Void = { _ in }) {
        _XCTEvaluateAssertion(.throwsError, message: message, file: file, function: function, line: line) {
            var caughtErrorOptional: Error?
            do {
                _ = try expression()
            } catch {
                caughtErrorOptional = error
            }
            
            if let caughtError = caughtErrorOptional {
                errorHandler(caughtError)
                return .success
            } else {
                return .expectedFailure("did not throw error")
            }
        }
    }
}

extension Assertion {
    // (Int, Int)
    func equal(_ expression1: (Int,Int), _ expression2: (CGFloat, CGFloat), _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let a = (CGFloat(expression1.0), CGFloat(expression1.1))
            let b = expression2
            if a.0 == b.0 && a.1 == b.1 {
                return .success
            } else {
                return .expectedFailure("\(a) != \(b)")
            }
        }
    }
    
    func equal(_ expression1: (CGFloat,CGFloat), _ expression2: (CGFloat, CGFloat), _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let a = expression1
            let b = expression2
            if a.0 == b.0 && a.1 == b.1 {
                return .success
            } else {
                return .expectedFailure("\(a) != \(b)")
            }
        }
    }
}

func ==(lhs: NSRange, rhs: NSRange) -> Bool {
    return lhs.location == rhs.location && lhs.length == rhs.length
}

extension Assertion {
    // NSRange
    func equal(_ expression1: @autoclosure () throws -> NSRange, _ expression2: @autoclosure () throws -> NSRange, _ message:  String = "", file: String = #file, function: String = #function, line: Int = #line) {
        _XCTEvaluateAssertion(.equal, message: message, file: file, function: function, line: line) {
            let (value1, value2) = (try expression1(), try expression2())
            if value1 == value2 {
                return .success
            } else {
                return .expectedFailure("\(value1) != \(value2)")
            }
        }
    }
}

let Assert = Assertion()
