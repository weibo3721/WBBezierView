//
//  WBBezierView.swift
//  WBBezierView
//
//  Created by weibo on 16/5/19.
//  Copyright © 2016年 weibo. All rights reserved.
//

import UIKit
import Foundation

enum WBBezierViewState {
    case Normal
    case Drag
    case EndWithNormal
    case EndWithDisappear
    case OutDrag
}

class WBBezierView: UIView{
    var radius:CGFloat = 10
    var startPoint = CGPointZero
    var endPoint = CGPointZero
    var color = UIColor.redColor()
    var maxDistance:CGFloat = 150
    var state = WBBezierViewState.Normal
    var _number = 1
    
    var number: Int {
        get {
            return _number
        }
        set {
            _number = newValue
            state = .Normal
            setNeedsDisplay()
        }
    }
    
    var label:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(12)
        label.textColor = UIColor.blackColor()
        label.textAlignment = .Center
        return label
    }()
    
    
    var length : CGFloat {
        return sqrt(pow((startPoint.y - endPoint.y),2) + pow((startPoint.x - endPoint.x),2))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let labelRadius = radius / sqrt(2)
        
        if state == .EndWithDisappear {
            label.hidden = true
        }
        else {
            label.hidden = false
        }
        
        if _number <= 0 {
            return
        }
        else {
            
        }
        
        color.set()
        if state == .EndWithDisappear {
            return
        }
        var nowPoint = CGPointZero
        if state == .Normal || state == .EndWithNormal || state == .EndWithDisappear  {
            nowPoint = startPoint
        }
        
        if state == .OutDrag || state == .Drag {
            nowPoint = endPoint
            
        }
        
        label.frame = CGRect(x: nowPoint.x - labelRadius, y: nowPoint.y - labelRadius, width: labelRadius * 2, height: labelRadius * 2)
        label.text = "\(number)"
        
        if state == .OutDrag || state == .Normal || state == .EndWithNormal || state == .EndWithDisappear {
            UIBezierPath(arcCenter: nowPoint, radius: radius, startAngle: CGFloat(0 * M_PI), endAngle: CGFloat(2 * M_PI), clockwise: true).fill()
            return
        }
        
        let persent = 1 - length / maxDistance * 0.6
        
        let slope = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x)
        let crossSlope = -1 / slope
        let crossArc = atan(crossSlope)
        let startClockwiseX = startPoint.x - cos(crossArc) * radius * persent
        let startClockwiseY = startPoint.y - sin(crossArc) * radius * persent
        let startNoClockwiseX = startPoint.x + cos(crossArc) * radius * persent
        let startNoClockwiseY = startPoint.y + sin(crossArc) * radius * persent
        
        let startPointClockwisePoint = CGPoint(x: startClockwiseX, y: startClockwiseY)
        let startPointNoClockwisePoint = CGPoint(x: startNoClockwiseX, y: startNoClockwiseY)
        
        let endClockwiseX = endPoint.x - cos(crossArc) * radius
        let endClockwiseY = endPoint.y - sin(crossArc) * radius
        let endNoClockwiseX = endPoint.x + cos(crossArc) * radius
        let endNoClockwiseY = endPoint.y + sin(crossArc) * radius
        
        let endPointClockwisePoint = CGPoint(x: endClockwiseX, y: endClockwiseY)
        let endPointNoClockwisePoint = CGPoint(x: endNoClockwiseX, y: endNoClockwiseY)
        
        //print(startPointClockwisePoint)
        //print(endPointClockwisePoint)
        //print(startPointNoClockwisePoint)
        //print(endPointNoClockwisePoint)
        
        let pointCenter = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        //print(pointCenter)
        
        
        let path1 = UIBezierPath()
        path1.moveToPoint(startPointClockwisePoint)
        path1.addQuadCurveToPoint(endPointClockwisePoint, controlPoint: pointCenter)
        path1.addLineToPoint(endPointNoClockwisePoint)
        path1.addQuadCurveToPoint(startPointNoClockwisePoint, controlPoint: pointCenter)
        path1.closePath()
        path1.lineCapStyle = .Round
        path1.lineJoinStyle = .Round
        path1.lineWidth = 1
        path1.fill()
        
        
        //crossArc + CGFloat(M_PI)
        let pathCircle1 = UIBezierPath(arcCenter: startPoint, radius: radius * persent, startAngle:  CGFloat(M_PI), endAngle:  CGFloat(3 * M_PI), clockwise: true)
        pathCircle1.fill()
        let pathCircle2 = UIBezierPath(arcCenter: endPoint, radius: radius, startAngle:  CGFloat(0 * M_PI), endAngle:  CGFloat(2 * M_PI), clockwise: true)
        pathCircle2.fill()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches, withEvent: event)
    }
    
    func handleTouches(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if state == .EndWithDisappear {
            return
        }
        if let first = touches.first {
            let end = first.locationInView(self)
            print("newEnd:\(end)")
            endPoint = end
            
            if length > maxDistance {
                self.state = .OutDrag
            }
            else {
                self.state = .Drag
            }
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let first = touches.first {
            let end = first.locationInView(self)
            if length > maxDistance {
                self.state = .EndWithDisappear
            }else {
                self.state = .EndWithNormal
                endPoint = end
                endAnimation(end)
            }
            setNeedsDisplay()
        }
    }
    
    func endAnimation(end:CGPoint) {
        self.frame.origin.x += end.x - self.startPoint.x
        self.frame.origin.y += end.y - self.startPoint.y
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 15, options: UIViewAnimationOptions.AllowAnimatedContent, animations: {
            self.frame.origin.x -= end.x - self.startPoint.x
            self.frame.origin.y -= end.y - self.startPoint.y
            }, completion: { _ in
                print("completion")
        })
    }
    
}