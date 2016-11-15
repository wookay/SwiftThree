//
//  ViewController.swift
//  SwiftThree
//
//  Created by wookyoung on 15/11/2016.
//  Copyright © 2016 wookyoung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    func injected() {
        Logger.info("ctrl =")
        self.view.backgroundColor = UIColor.green
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UnitTest.run(only: SwiftThreeTests.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
