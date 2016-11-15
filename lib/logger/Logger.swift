//
//  Logger.swift
//  Base
//
//  Created by wookyoung on 13/11/2016.
//  Copyright © 2016 wookyoung. All rights reserved.
//

import Foundation

let ansi_escape = "\u{001b}["
let ansi_red    = ansi_escape + "fg215,50,50;"
let ansi_brown  = ansi_escape + "fg150,113,63;"
let ansi_green  = ansi_escape + "fg0,155,0;"
let ansi_blue   = ansi_escape + "fg52,91,141;"
let ansi_reset  = ansi_escape + ";"

public class Logger {
    public class func info(_ args: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        
        print(ansi_blue, terminator: "")
        print("\(filename) #\(line) ", terminator: "")
        print(ansi_brown, terminator: "")
        print("\(function) ", terminator: "")
        print(ansi_reset, terminator: "")

        let length = args.count
        for (index, x) in args.enumerated() {
            print(x, terminator: length==index+1 ? "" : " ")
        }
        print(terminator: "\n")
    }
}
