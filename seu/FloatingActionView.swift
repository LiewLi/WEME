//
//  FloatingActionView.swift
//  牵手东大
//
//  Created by liewli on 11/21/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

protocol FloatingActionViewDelegate {
    func didTapFloatingAction(action:FloatingActionView)
}

class FloatingActionView:UIView {
    
    let internalRatio: CGFloat = 0.75
    
    var responsible = true
    var imageView = UIImageView()
    
    var delegate:FloatingActionViewDelegate?
    
    var hideWhileScrolling = true {
        didSet {
            if hideWhileScrolling && bgScroller != nil {
                bgScroller?.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
            }
            else {
                bgScroller?.removeObserver(self, forKeyPath: "contentOffset")
            }
        }
    }
    var bgScroller:UIScrollView?
    var lastOffset:CGPoint?
    
    private var originalColor: UIColor
    
    override var frame: CGRect {
        didSet {
            resizeSubviews()
        }
    }

    func showMenuDuringScroll(shouldShow:Bool) {
        if hideWhileScrolling {
            if (!shouldShow) {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.transform = CGAffineTransformMakeTranslation(0, 6*self.radius)
                    }, completion: nil)
            }
            else {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.transform = CGAffineTransformIdentity
                    }, completion: nil)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let scroll = bgScroller,
            let offset = lastOffset {
                let diff = scroll.contentOffset.y - offset.y
                if abs(diff) > 15 {
                    if scroll.contentOffset.y > 0 {
                        showMenuDuringScroll(offset.y > scroll.contentOffset.y)
                        lastOffset = scroll.contentOffset
                    }
                    else {
                        showMenuDuringScroll(true)
                    }
                }
        }
    }
    
    
    func setup(image: UIImage, tintColor: UIColor = UIColor.whiteColor()) {
        imageView.image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        imageView.tintColor = tintColor
        setupView(imageView)
    }
    
    func setupView(view: UIView) {
        userInteractionEnabled = true
        addSubview(view)
        resizeSubviews()
    }
    
    private func resizeSubviews() {
        let size = CGSize(width: frame.width * 0.5, height: frame.height * 0.5)
        imageView.frame = CGRect(x: frame.width - frame.width * internalRatio, y: frame.height - frame.height * internalRatio, width: size.width, height: size.height)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if responsible {
            originalColor = color
            color = originalColor.white(0.5)
            setNeedsDisplay()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if responsible {
            color = originalColor
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        color = originalColor
        delegate?.didTapFloatingAction(self)
    }
    
    
    var radius: CGFloat {
        didSet {
            self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
            setup()
        }
    }
    var color: UIColor = UIColor.redColor() {
        didSet {
            setup()
        }
    }
    
    override  var center: CGPoint {
        didSet {
            self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
            setup()
        }
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor, icon: UIImage, scrollview:UIScrollView?) {
        bgScroller = scrollview
        lastOffset = scrollview?.contentOffset
        self.originalColor = color
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        self.radius = radius
        self.color = color
        super.init(frame: frame)
        setup()
        self.layer.addSublayer(circleLayer)
        self.opaque = false
        setup(icon)
    }
    
    init(center: CGPoint, radius: CGFloat, color: UIColor, view: UIView, scrollview:UIScrollView?) {
        self.originalColor = color
        bgScroller = scrollview
        lastOffset = scrollview?.contentOffset
        let frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        self.radius = radius
        self.color = color
        super.init(frame: frame)
        setup()
        self.layer.addSublayer(circleLayer)
        self.opaque = false
        setupView(view)
    }
    
    init(icon: UIImage, scrollview:UIScrollView?) {
        self.radius = 0
        bgScroller = scrollview
        lastOffset = scrollview?.contentOffset
        self.originalColor = UIColor.clearColor()
        super.init(frame: CGRectZero)
        setup()
        self.layer.addSublayer(circleLayer)
        self.opaque = false
        setup(icon)
    }
    
    let circleLayer = CAShapeLayer()
    

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.frame = CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
        drawCircle()
    }
    
    func drawCircle() {
        let bezierPath = UIBezierPath(ovalInRect: CGRect(origin: CGPointZero, size: CGSize(width: radius * 2, height: radius * 2)))
        draw(bezierPath)
    }
    
    func draw(path: UIBezierPath) -> CAShapeLayer {
        circleLayer.lineWidth = 3.0
        circleLayer.fillColor = self.color.CGColor
        circleLayer.path = path.CGPath
        circleLayer.appendShadow()
        return circleLayer
    }
//    
//    func circlePoint(rad: CGFloat) -> CGPoint {
//        return CGMath.circlePoint(center, radius: radius, rad: rad)
//    }
    
     override func drawRect(rect: CGRect) {
        drawCircle()
    }

}
