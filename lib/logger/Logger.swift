//
//  Logger.swift
//
//  Created by wookyoung on 13/11/2016.
//  Copyright © 2016 wookyoung. All rights reserved.
//

import Foundation

let ansi_escape = "\u{001b}["
let ansi_red    = ansi_escape + "fg215,50,50;"
let ansi_green  = ansi_escape + "fg0,155,0;"
let ansi_blue   = ansi_escape + "fg52,91,151;"
let ansi_reset  = ansi_escape + ";"

public class Logger {
    
    public class func info(_ args: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        let filename = (file as NSString).lastPathComponent
        let length = args.count
        let use_ansi = true
        
        if use_ansi {
            print(ansi_blue, terminator: "")
        }
        
        print("\(filename) #\(line) ", terminator: "")
        
        if use_ansi {
            print(ansi_green, terminator: "")
        }
        
        print("\(function) ", terminator: "")
        
        if use_ansi {
            print(ansi_reset, terminator: "")
        }
        
        for (index, x) in args.enumerated() {
            print(x, terminator: length==index+1 ? "" : " ")
        }
        print(terminator: "\n")
    }

}
