/*
 * QRCodeReader.swift
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

/// Overlay over the camera view to display the area (a square) where to scan the code.
protocol ReaderOverlayViewDelegate:class {
    func didUpdateROI(roi:CGRect)
}
final class ReaderOverlayView: UIView {
  weak var delegate:ReaderOverlayViewDelegate?
  private var overlay: CAShapeLayer = {
    var overlay = CAShapeLayer()
    overlay.backgroundColor = UIColor.clearColor().CGColor
    overlay.fillColor       = UIColor.clearColor().CGColor
    overlay.strokeColor     = UIColor.whiteColor().CGColor
    overlay.lineWidth       = 1
   // overlay.lineDashPattern = [7.0, 7.0]
    overlay.lineDashPhase   = 0

    return overlay
    }()
    
    var topleftLayer:CAShapeLayer = {
        var overlay = CAShapeLayer()
        overlay.backgroundColor = UIColor.clearColor().CGColor
        overlay.fillColor       = UIColor.clearColor().CGColor
        overlay.strokeColor     = ICON_THEME_COLOR.CGColor
        overlay.lineWidth       = 2
        return overlay
    }()
    
    var bottomleftLayer:CAShapeLayer = {
        var overlay = CAShapeLayer()
        overlay.backgroundColor = UIColor.clearColor().CGColor
        overlay.fillColor       = UIColor.clearColor().CGColor
        overlay.strokeColor     = ICON_THEME_COLOR.CGColor
        overlay.lineWidth       = 2
        return overlay
    }()

    var bottomrightLayer:CAShapeLayer = {
        var overlay = CAShapeLayer()
        overlay.backgroundColor = UIColor.clearColor().CGColor
        overlay.fillColor       = UIColor.clearColor().CGColor
        overlay.strokeColor     = ICON_THEME_COLOR.CGColor
        overlay.lineWidth       = 2
        return overlay
    }()

    var toprightLayer:CAShapeLayer = {
        var overlay = CAShapeLayer()
        overlay.backgroundColor = UIColor.clearColor().CGColor
        overlay.fillColor       = UIColor.clearColor().CGColor
        overlay.strokeColor     = ICON_THEME_COLOR.CGColor
        overlay.lineWidth       = 2
        return overlay
    }()

    
    private var fillLayer:CAShapeLayer = {
        var fill = CAShapeLayer()
        fill.fillRule = kCAFillRuleEvenOdd
        fill.fillColor = UIColor.blackColor().CGColor
        fill.opacity = 0.6
        return fill
    }()
    
    private var lineLayer:CAGradientLayer = {
        var gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 0, 100, 20)
        gradientLayer.colors = [ICON_THEME_COLOR.alpha(0.8).CGColor, UIColor.clearColor().CGColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x:0.5, y:0.8)
        return gradientLayer
    }()

    
    func pinCorner(rect:CGRect) {
        let len:CGFloat = 40.0
        let tl = CGPointMake(rect.origin.x, rect.origin.y)
        let tlp = UIBezierPath()
        tlp.moveToPoint(CGPointMake(tl.x, tl.y+len))
        tlp.addLineToPoint(CGPointMake(tl.x, tl.y))
        tlp.addLineToPoint(CGPointMake(tl.x+len, tl.y))
        topleftLayer.path = tlp.CGPath
        
        let tr = CGPointMake(rect.origin.x + rect.width, rect.origin.y)
        let trp = UIBezierPath()
        trp.moveToPoint(CGPointMake(tr.x - len, tr.y))
        trp.addLineToPoint(CGPointMake(tr.x, tr.y))
        trp.addLineToPoint(CGPointMake(tr.x, tr.y + len))
        toprightLayer.path = trp.CGPath

        
        let br = CGPointMake(rect.origin.x + rect.width, rect.origin.y + rect.height)
        let brp = UIBezierPath()
        brp.moveToPoint(CGPointMake(br.x, br.y-len))
        brp.addLineToPoint(CGPointMake(br.x, br.y))
        brp.addLineToPoint(CGPointMake(br.x-len, br.y ))
        bottomrightLayer.path = brp.CGPath
        
        
        
        let bl = CGPointMake(rect.origin.x , rect.origin.y + rect.height)
        let blp = UIBezierPath()
        blp.moveToPoint(CGPointMake(bl.x + len, bl.y))
        blp.addLineToPoint(CGPointMake(bl.x, bl.y))
        blp.addLineToPoint(CGPointMake(bl.x, bl.y - len))
        bottomleftLayer.path = blp.CGPath


    }
    
    func commoninit() {
        layer.addSublayer(overlay)
        layer.addSublayer(fillLayer)
        layer.addSublayer(lineLayer)
        layer.addSublayer(topleftLayer)
        layer.addSublayer(toprightLayer)
        layer.addSublayer(bottomleftLayer)
        layer.addSublayer(bottomrightLayer)
    }
  init() {
    super.init(frame: CGRectZero)  // Workaround for init in iOS SDK 8.3
    commoninit()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commoninit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commoninit()
  }

  override func drawRect(rect: CGRect) {
    var innerRect = CGRectInset(rect, 50, 50)
    let minSize   = min(innerRect.width, innerRect.height)

    if innerRect.width != minSize {
      innerRect.origin.x   += (innerRect.width - minSize) / 2
      innerRect.size.width = minSize
    }
    else if innerRect.height != minSize {
      innerRect.origin.y    += (innerRect.height - minSize) / 2
      innerRect.size.height = minSize
    }

    let offsetRect = CGRectOffset(innerRect, 0, 15)
    
    let outer = UIBezierPath(roundedRect: rect, cornerRadius: 0)
    let inner = UIBezierPath(roundedRect: offsetRect, cornerRadius: 0)
    outer.appendPath(inner)
    outer.usesEvenOddFillRule = true
    delegate?.didUpdateROI(offsetRect)
    fillLayer.path = outer.CGPath
    overlay.path  = inner.CGPath
    
    lineLayer.frame = CGRectMake(offsetRect.origin.x, offsetRect.origin.y-10, offsetRect.size.width, 20)
    lineLayer.removeAllAnimations()
    let animation = CABasicAnimation(keyPath: "position")
    animation.toValue = NSValue(CGPoint: CGPointMake(CGRectGetMidX(offsetRect), CGRectGetMaxY(offsetRect)-10))
    animation.duration = 4
    animation.repeatCount = Float.infinity
    animation.removedOnCompletion = false
    animation.fillMode = kCAFillModeForwards
    lineLayer.addAnimation(animation, forKey: "position")
    pinCorner(offsetRect)
    
  }
}
