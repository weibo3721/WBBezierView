//
//  ViewController.swift
//  WBBezierView
//
//  Created by weibo on 16/5/19.
//  Copyright © 2016年 weibo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.yellowColor()
        
        let bezierView = WBBezierView(frame: UIScreen.mainScreen().bounds)
        bezierView.backgroundColor = UIColor.clearColor()
        bezierView.startPoint = CGPoint(x: 200, y: 200)
        bezierView.endPoint = CGPoint(x: 200, y: 200)
        bezierView.setNeedsDisplay()
        view.addSubview(bezierView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

