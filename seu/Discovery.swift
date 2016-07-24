//
//  discovery.swift
//  WEME
//
//  Created by liewli on 1/29/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class DiscoverVC:UIViewController {
    
    var timer:NSTimer!
    var recommendPeople = [PersonModel]()
    
    var animator:UIDynamicAnimator!
    var gravity:UIGravityBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
       // addBubble()
        addRaindrop()
        fetchRecommendPeople()

    }
    
    func setup() {
        let back = UIImageView(image: UIImage(named: "discover_back"))
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)
        back.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.bottom.equalTo(snp_bottomLayoutGuideTop)
        }
        
        animator = UIDynamicAnimator(referenceView: view)
        gravity = UIGravityBehavior()
        gravity.gravityDirection = CGVectorMake(0, 0.02)
        animator.addBehavior(gravity)
    }
    
    func addBubble() {
        let colors  = [UIColor(red: 173/255.0, green: 213/255.0, blue: 225/255.0, alpha: 0.2),
                       UIColor(red: 167/255.0, green: 215/255.0, blue: 227/255.0, alpha: 0.4),
                        UIColor(red: 133/255.0, green: 194/255.0, blue: 195/255.0, alpha: 0.8)
                        ]
        let face = BubbleFaceView(center: CGPointMake(80, 100), radius: 50, colors: colors, faceImg: UIImage(named: "face")!, contentViewRotation: nil)
        view.addSubview(face)
        
        let colors1 = [
            UIColor.colorFromRGB(0xDC9FB4).alpha(0.2),
            UIColor.colorFromRGB(0xE87A90).alpha(0.4),
            UIColor.colorFromRGB(0xF596AA).alpha(0.6),
        ]
        let face1 = BubbleFaceView(center: CGPointMake(200, 300), radius: 100, colors: colors1, faceImg: UIImage(named: "face")!, contentViewRotation: nil)
        view.addSubview(face1)
        
        let colors2 = [
            UIColor.colorFromRGB(0xE1A679).alpha(0.2),
            UIColor.colorFromRGB(0xE79460).alpha(0.4),
            UIColor.colorFromRGB(0xE98B2A).alpha(0.8),
        ]
        
        let face2 = BubbleFaceView(center: CGPointMake(240, 100), radius: 80, colors: colors2, faceImg: UIImage(named: "face")!, contentViewRotation: nil)
        view.addSubview(face2)
        
        
        let bubble = BubbleView(center: CGPointMake(50, 300), radius: 40, colors: colors2, contentView: nil, contentViewRotation: nil)
        view.addSubview(bubble)


    }
    var raindrops = [RaindropView]()
    
    func fetchRecommendPeople() {
        if let t = token {
            request(.POST, GET_RECOMMENDED_FRIENDS_URL, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    
                    do {
                        let people = try MTLJSONAdapter.modelsOfClass(PersonModel.self, fromJSONArray: json["result"].arrayObject) as? [PersonModel]
                        if let t = people where t.count > 0 {
                            S.recommendPeople = t
                            S.refresh()
                        }
                    }
                    catch {
                        print(error)
                    }
                }
                })
        }
    }

    
    //var centerPoints:[CGPoint]!
    
    var SIZE:CGFloat {
        return SCREEN_WIDTH / CGFloat(cols)
    }
    
    var rows:Int {
        return Int(SCREEN_HEIGHT / SIZE) - 1
    }
    
    var cols:Int {
        return 4
    }
    
    func getCenter(row:Int, col:Int) ->CGPoint {
        return CGPointMake(CGFloat(col) * SIZE + SIZE/2, CGFloat(row) * SIZE + SIZE/2)
    }
    
    func addRaindrop() {
        
//        let face = UIImage(named: "face")
//        let faceRaindrop = RaindropFaceView(center: CGPointMake(240, 200), radius: 80, img: face)
//        view.addSubview(faceRaindrop)
//        
//        let faceRaindrop1 = RaindropFaceView(center: CGPointMake(100, 100), radius: 60, img: face)
//        view.addSubview(faceRaindrop1)
//        
//        let faceRaindrop2 = RaindropFaceView(center: CGPointMake(50, 350), radius: 40, img: face)
//        view.addSubview(faceRaindrop2)
//        
//        let faceRaindrop3 = RaindropFaceView(center: CGPointMake(250, 400), radius: 50, img: face)
//        view.addSubview(faceRaindrop3)
//        
//        raindrops = [faceRaindrop, faceRaindrop1, faceRaindrop2, faceRaindrop3]
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "time:", userInfo: nil, repeats: true)
        timer.fire()
        //refresh()
        //fetchRecommendPeople()
    }
    
    func generateCenterPoints(cnt:Int)->[CGPoint] {
//        var indexs = [(Int, Int)]()
//        for r in 0..<rows {
//            for c in 0..<cols {
//                indexs.append((r, c))
//            }
//        }
        
        var indexs = [Int]()
        for r in 0..<rows {
            indexs.append(r)
        }
        
       // let cp = min(indexs.count, cnt)
        var points = [CGPoint]()
        for c in 0..<cols {
            let idx = random() % indexs.count
            //let rc = indexs[idx]
            points.append(getCenter(indexs[idx], col: c))
            indexs.removeAtIndex(idx)
            
        }
        
        //print(points)
        return points
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black

    }
    
    func refresh() {
        guard cols <= recommendPeople.count else {
            return
        }
//        raindrops.removeAll()
        let ps = generateCenterPoints(cols)
//        let pp = ps.sort { (p1, p2) -> Bool in
//            return p1.y > p2.y
//        }
        for (idx, p) in ps.enumerate() {
            let face = RaindropFaceView(center: CGPointMake(p.x, -SIZE - p.y*4*SIZE / SCREEN_HEIGHT), radius: SIZE/2-4, people:recommendPeople[idx])
            view.addSubview(face)
//            raindrops.append(face)
            gravity.addItem(face)
            gravity.action = {
                [weak gravity, weak self] in
                if let g = gravity, S = self {
                    for item in g.items as! [UIView] {
                        if item.center.y > SCREEN_HEIGHT + S.SIZE {
                            g.removeItem(item)
                            item.removeFromSuperview()
                        }
                    }
                }
            }
            face.delegate = self
            
        }
        
//        CATransaction.begin()
//        let rains = raindrops
//        CATransaction.setCompletionBlock { () -> Void in
//            for r in rains {
//                r.removeFromSuperview()
//            }
//        }
//        for (idx, p) in ps.enumerate() {
//            let s = CGPointMake(p.x, -SCREEN_HEIGHT+p.y)
//            let t = (SCREEN_HEIGHT - p.y) * 16 / (SCREEN_HEIGHT) + 10
//            let e = CGPointMake(p.x, SCREEN_HEIGHT + (SCREEN_HEIGHT - p.y))
//            let face = raindrops[idx]
//            //let face = RaindropFaceView(center: p, radius: SIZE/2-4, img: UIImage(named: "face"))
//            //raindrops.append(face)
//            //view.addSubview(face)
//            let group = CAAnimationGroup()
//            group.duration = Double(t)
//            group.removedOnCompletion = false
//            group.fillMode = kCAFillModeForwards
//            group.repeatCount = 1.0
//            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//            
//            let translate = CABasicAnimation(keyPath: "position")
//            translate.fromValue = NSValue(CGPoint: s)
//            translate.toValue = NSValue(CGPoint: e)
//            translate.duration = Double(t)
//            
////            let scale = CAKeyframeAnimation(keyPath: "transform.scale.x")
////            scale.values = [1.0, 0.6, 0.5, 0.8, 1.0]
////            scale.keyTimes = [0.0, 0.3, 0.6, 0.9, 1.0]
////            scale.duration = Double(t)
////            scale.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
////            
////            
////            let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
////            scaleY.values = [1.0, 0.5, 0.6,  0.9, 1.0]
////            scaleY.keyTimes = [0.0, 0.3, 0.6, 0.9, 1.0]
////            scaleY.duration = Double(t)
////            scaleY.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
//            group.animations = [translate]//, scale, scaleY]
//            face.layer.addAnimation(group, forKey: "animationGroup")
//
//        }
//        CATransaction.commit()
    }
    
    func time(sender:AnyObject) {
        //print("timer")
        //dismiss()
        fetchRecommendPeople()
    }
    
    deinit {
        timer.invalidate()
    }
    
    func dismiss() {
        let rains = raindrops
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            for r in rains {
                r.removeFromSuperview()
            }
        }
        for r in raindrops {
           // r.layer.removeAllAnimations()
            let c = r.center
            let e = CGPointMake(c.x, SCREEN_HEIGHT + r.radius * 4)
            
            let t = (SCREEN_HEIGHT - c.y) * 3 / SCREEN_HEIGHT
            
            let group = CAAnimationGroup()
            group.duration = Double(t)
            group.removedOnCompletion = false
            group.fillMode = kCAFillModeForwards
            group.repeatCount = 1.0
            group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            let translate = CABasicAnimation(keyPath: "position")
            translate.toValue = NSValue(CGPoint: e)
            
            let scale = CAKeyframeAnimation(keyPath: "transform.scale.x")
            scale.values = [1.0, 0.8, 0.6, 0.5]
            scale.keyTimes = [0.0, 0.3, 0.6, 0.8]
            scale.duration = Double(t)
            scale.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
            
            
            let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
            scaleY.values = [1.0, 0.8, 0.7, 0.6]
            scaleY.keyTimes = [0.0, 0.3, 0.6, 0.8]
            scaleY.duration = Double(t)
            scaleY.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
            
            group.animations = [translate, scale, scaleY]
            
            r.layer.addAnimation(group, forKey: "animationGroup")
        }
        CATransaction.commit()
    }
    
}

extension DiscoverVC: RaindropFaceDelegate {
    func didTapPeople(people: PersonModel) {
        let vc = InfoVC()
        vc.id = people.ID
        navigationController?.pushViewController(vc, animated: true)
    }
}

protocol RaindropFaceDelegate:class {
    func didTapPeople(people:PersonModel)
}
class RaindropFaceView:RaindropView {
    weak var delegate:RaindropFaceDelegate?
    var people:PersonModel
    init(center: CGPoint, radius: CGFloat, people p: PersonModel) {
        people = p
        let imgView = UIImageView()
        imgView.sd_setImageWithURL(thumbnailAvatarURLForID(people.ID), placeholderImage: UIImage(named: "avatar"))
        super.init(center: center, radius: radius, contentView: imgView)
         setupUI()
    }
    
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        addGestureRecognizer(tap)
    }
    
    func tap(sender:AnyObject) {
        delegate?.didTapPeople(people)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class RaindropView:UIView {
    var contentView:UIView?
    var radius:CGFloat
    
    init (center:CGPoint, radius:CGFloat, contentView:UIView?) {
        let rect = CGRectMake(center.x-radius, center.y-radius, 2*radius, 2*radius)
        self.radius = radius
        self.contentView = contentView
        super.init(frame: rect)
        setup()
    }
    
    func setup() {
        let raindrop = UIImageView(image: UIImage(named: "raindrop"))
        raindrop.translatesAutoresizingMaskIntoConstraints = false
        addSubview(raindrop)
        raindrop.layer.zPosition = 10
        raindrop.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        
        if let v = contentView {
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            v.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(snp_left)
                make.right.equalTo(snp_right)
                make.top.equalTo(snp_top)
                make.bottom.equalTo(snp_bottom)
            })
            v.layer.cornerRadius = radius
            v.layer.masksToBounds = true
        }
        
       // addWobbleAnimationsToLayer(layer)
        
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.colorFromRGB(0x141e3f).CGColor
        layer.shadowOffset = CGSizeMake(-2, 2)
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).CGPath
        
    }
    
    func addWobbleAnimationsToLayer(bubble : CALayer) {
//        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
//        pathAnimation.calculationMode = kCAAnimationPaced
//        pathAnimation.fillMode = kCAFillModeForwards
//        pathAnimation.removedOnCompletion = false
//        pathAnimation.repeatCount = Float.infinity
//        pathAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
//        pathAnimation.duration = 5.0
//        
//        let pathref = CGPathCreateMutable()
//        CGPathAddEllipseInRect(pathref, nil, CGRectInset(bubble.frame, bubble.bounds.width/2 - 1, bubble.bounds.height/2 - 1))
//        pathAnimation.path = pathref
//        
//        bubble.addAnimation(pathAnimation, forKey: "circleAnimatin")
        
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1.0
        scaleX.values = [1.0, 1.05, 1.0]
        scaleX.keyTimes = [0.0, 0.5, 1.0]
        scaleX.repeatCount = Float.infinity
        scaleX.fillMode = kCAFillModeForwards
        scaleX.removedOnCompletion = false
        scaleX.autoreverses = true
        scaleX.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        bubble.addAnimation(scaleX, forKey: "scaleXTransformation")
        
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.duration = 1.5
        scaleY.values = [1.0, 1.05, 1.0]
        scaleY.keyTimes = [0.0, 0.5, 1.0]
        scaleY.repeatCount = Float.infinity
        scaleY.fillMode = kCAFillModeForwards
        scaleY.autoreverses = true
        scaleY.removedOnCompletion = false
        scaleY.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        bubble.addAnimation(scaleY, forKey: "scaleYTransformation")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class BubbleFaceView:BubbleView {
    var imgView:UIImageView
    
    init(center:CGPoint, radius r:CGFloat, colors c:[UIColor], faceImg:UIImage, contentViewRotation angle:CGFloat?) {
        imgView = UIImageView(image: faceImg)
        let rect = CGRectMake(0.2*r, 0.2*r, 1.6*r, 1.6*r)
        imgView.frame = rect
        imgView.layer.cornerRadius = 0.8*r
        imgView.layer.masksToBounds = true
        super.init(center: center, radius: r, colors: c, contentView: imgView, contentViewRotation: CGFloat(M_PI/6))
        
        //setupFace()
    }
    
    
    func setupFace() {
        let p = imgView.layer
        
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1.0
        scaleX.values = [1.0, 1.05, 1.0]
        scaleX.keyTimes = [0.0, 0.5, 1.0]
        scaleX.repeatCount = Float.infinity
        scaleX.fillMode = kCAFillModeForwards
        scaleX.removedOnCompletion = false
        scaleX.autoreverses = true
        scaleX.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        p.addAnimation(scaleX, forKey: "scaleXTransformation")
        
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.duration = 1.5
        scaleY.values = [1.0, 1.05, 1.0]
        scaleY.keyTimes = [0.0, 0.5, 1.0]
        scaleY.repeatCount = Float.infinity
        scaleY.fillMode = kCAFillModeForwards
        scaleY.autoreverses = true
        scaleY.removedOnCompletion = false
        scaleY.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        p.addAnimation(scaleY, forKey: "scaleYTransformation")

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}

class BubbleView:UIView {
    var radius:CGFloat
    var colors:[UIColor]
    var contentView:UIView?
    var contentRotation:CGFloat?
    
    func addWobbleAnimationsToLayer(bubble : CALayer) {
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.fillMode = kCAFillModeForwards
        pathAnimation.removedOnCompletion = false
        pathAnimation.repeatCount = Float.infinity
        pathAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
        pathAnimation.duration = 5.0
        
        let pathref = CGPathCreateMutable()
        CGPathAddEllipseInRect(pathref, nil, CGRectInset(bubble.frame, bubble.bounds.width/2 - bubble.bounds.width * 0.02, bubble.bounds.height/2 - bubble.bounds.height * 0.02))
        pathAnimation.path = pathref
        
        bubble.addAnimation(pathAnimation, forKey: "circleAnimatin")
        
        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.duration = 1.0
        scaleX.values = [1.0, 1.05, 1.0]
        scaleX.keyTimes = [0.0, 0.5, 1.0]
        scaleX.repeatCount = Float.infinity
        scaleX.fillMode = kCAFillModeForwards
        scaleX.removedOnCompletion = false
        scaleX.autoreverses = true
        scaleX.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        bubble.addAnimation(scaleX, forKey: "scaleXTransformation")
        
        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.duration = 1.5
        scaleY.values = [1.0, 1.05, 1.0]
        scaleY.keyTimes = [0.0, 0.5, 1.0]
        scaleY.repeatCount = Float.infinity
        scaleY.fillMode = kCAFillModeForwards
        scaleY.autoreverses = true
        scaleY.removedOnCompletion = false
        scaleY.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        
        bubble.addAnimation(scaleY, forKey: "scaleYTransformation")

    }
    
    func addBobToBubble(bubble:CALayer) {
        let bob = CAShapeLayer()
        // bob.backgroundColor = UIColor.whiteColor().alpha(0.8).CGColor
        bubble.addSublayer(bob)
        bob.fillColor = UIColor.whiteColor().alpha(0.8).CGColor
        let path = UIBezierPath()
        let radius = self.radius
        let center = CGPointMake(bubble.bounds.width / 2.0, bubble.bounds.height / 2.0)
        let startAngle = CGFloat(M_PI  +  M_PI / 5.0)
        let endAngle = CGFloat(M_PI * 5 / 4.0 + M_PI / 6.0)
        let startPoint = CGPointMake(center.x + 0.7 * radius * cos(startAngle), center.y + 0.7 * radius * sin(startAngle))
        path.moveToPoint(startPoint)
        
        path.addArcWithCenter(center, radius: 0.7*radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        let p1 = CGPointMake(center.x + 0.8 * radius * cos(endAngle), center.y + 0.8 * radius * sin(endAngle))
        
        let cp1 = CGPointMake(center.x + 0.75 * radius * cos(endAngle + CGFloat(M_PI / 30)), center.y + 0.75 * radius * sin(endAngle + CGFloat(M_PI / 30)))
        
        path.addQuadCurveToPoint(p1, controlPoint: cp1)
        
        //let p2 = CGPointMake(center.x + 0.8 * radius * cos(startAngle), center.y + 0.8 * radius * sin(startAngle))
        
        path.addArcWithCenter(center, radius: 0.8*radius, startAngle: endAngle, endAngle: startAngle, clockwise: false)
        
        let cp2 = CGPointMake(center.x + 0.75 * radius * cos(startAngle - CGFloat(M_PI / 30)), center.y + 0.75 * radius * sin(startAngle - CGFloat(M_PI / 30)))
        
        path.addQuadCurveToPoint(startPoint, controlPoint: cp2)
        
        bob.path = path.CGPath
        
    }

    
    func setup() {
        backgroundColor = UIColor.clearColor()
        let gradLocations:[CGFloat] = [0.0, 0.6, 1.0]
        let alphas:[CGFloat] = [0.2, 0.6, 0.8]
        var gradColors = [CGFloat]()
        for (idx, c) in colors.enumerate() {
           gradColors.appendContentsOf([c.red, c.green, c.blue, alphas[idx]])
        }
        
        let bubble = RadialGradientLayer(gradientColors: gradColors, gradientLocations: gradLocations)
        bubble.frame = bounds
        bubble.cornerRadius = radius
        bubble.masksToBounds = true
        addWobbleAnimationsToLayer(layer)
        addBobToBubble(bubble)
        layer.addSublayer(bubble)
        
//        layer.shadowOpacity = 0.6
//        layer.shadowRadius = 2
//        layer.shadowColor = UIColor.colorFromRGB(0x141e3f).CGColor
//        layer.shadowOffset = CGSizeMake(2, 2)
//        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).CGPath
//
//        
        if let v = contentView {
            let p = v.layer
            if let angle = contentRotation {
                p.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
            }
            p.zPosition = 0
            bubble.zPosition = 10
            layer.addSublayer(p)
        }

    }
    
    init(center:CGPoint, radius r:CGFloat, colors c:[UIColor], contentView v:UIView?, contentViewRotation angle:CGFloat?) {
        assert(r > 0 && c.count == 3)
        radius = r
        colors = c
        contentView = v
        contentRotation = angle
        let rect = CGRectMake(center.x - radius, center.y - radius, 2*radius, 2*radius)
        super.init(frame: rect)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class RadialGradientLayer :CALayer {
    
    var gradColors:[CGFloat]
    var gradLocations:[CGFloat]
    
    init(gradientColors:[CGFloat], gradientLocations:[CGFloat]) {
        assert(gradientColors.count * 4 == gradientLocations.count)
        gradColors = gradientColors
        gradLocations = gradientLocations
        super.init()
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawInContext(ctx: CGContext) {
        let gradLocationNum = gradLocations.count
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradientCreateWithColorComponents(colorSpaceRef, gradColors, gradLocations, gradLocationNum)
        
        let center = CGPointMake(bounds.width/2.0, bounds.height/2)
        let radius = min(bounds.width, bounds.height)/2.0
        CGContextDrawRadialGradient(ctx, gradient, center, 0, center, radius*0.9, CGGradientDrawingOptions.DrawsAfterEndLocation)
        
    }
}
