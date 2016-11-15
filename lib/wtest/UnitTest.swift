//
//  UnitTest.swift
//  Test
//
//  Created by wookyoung on 1/29/16.
//  Copyright © 2016 factorcat. All rights reserved.
//

import Foundation

struct TestResult {
    var tests: Int
    var passed: Int
    var failed: Int
    var errors: Int
}

class UnitTest {
    static var result: TestResult = TestResult(tests: 0, passed: 0, failed: 0, errors: 0)

    class func methods(_ f: (String) -> Bool, type: AnyClass) -> [Selector] {
        var selectors = [Selector]()
        var count : UInt32 = 0
        let methods = class_copyMethodList(type, &count)!
        for i in 0..<count {
            let method = methods.advanced(by: Int(i)).pointee!
            let sel = method_getName(method)!
            let name = String(describing: sel)
            if f(name) {
                selectors.append(sel)
            }
        }
        return selectors
    }

    class func run(only: WTestCase.Type...) {
        _ = run(only: only)
    }

    class func run(only: [WTestCase.Type]) -> TestResult {
        let f = { (name: String) -> Bool in
            name.hasPrefix("test")
        }
        
        let started_at = Date()
        print("Started")
        if only.count > 0 {
            for c in only {
                switch c {
                case let klass as NSObject.Type:
                    let instance = klass.init()
                    for sel in methods(f, type: c) {
                        instance.perform(sel)
                    }
                }
                result.tests += 1
            }
        }
        let elapsed: Foundation.TimeInterval = -started_at.timeIntervalSinceNow
        print(String(format: "\nFinished in %.3g seconds.", elapsed))
        if result.failed > 0 {
            print(ansi_red)
        } else if result.passed > 0 {
            print(ansi_green)
        }
        print(String(format: "%d tests, %d assertions, %d failures, %d errors", result.tests, result.passed, result.failed, result.errors))
        if result.failed > 0 {
            print(ansi_reset)
        }
        return result
    }

}
