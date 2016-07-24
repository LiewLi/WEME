//
//  Find.swift
//  WEME
//
//  Created by liewli on 2/13/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class FindVC:UIViewController {
    
    var people:FindItemView!
    var food:FindItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        title = "寻觅"
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        view.addGestureRecognizer(tap)

        setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = false
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
     
//        for v in view.subviews {
//            v.layer.removeAllAnimations()
//            v.removeFromSuperview()
//        }
        
//        if let l = view.layer.sublayers where l.count > 0 {
//            for ll in l {
//                ll.removeFromSuperlayer()
//            }
//        }
        
        //setup()
    }

    
    func setup() {
        let back = UIImageView(image: UIImage(named: "find_background"))
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)
        back.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(view.snp_bottom)
            make.top.equalTo(view.snp_top)
        }
        let c = CGPointMake(view.center.x, view.center.y - 100)

        let earth = UIImageView(image: UIImage(named: "find_earth"))
        earth.frame = CGRectMake(c.x - 35, c.y - 35, 70, 70)
        view.addSubview(earth)
        
//        let earthRotation = CABasicAnimation(keyPath: "transform.rotation")
//        earthRotation.duration = 24.0
//        earthRotation.repeatCount = Float.infinity
//        earthRotation.removedOnCompletion = false
//        earthRotation.fromValue = NSNumber(float:0.0)
//        earthRotation.toValue = NSNumber(double: M_PI*2)
//        earth.layer.addAnimation(earthRotation, forKey: "earth")
//        
        
        
        let radius:CGFloat = 45.0
        let orbit = CAShapeLayer()
        let path = UIBezierPath(ovalInRect: CGRectMake(c.x - radius, c.y - radius, 2*radius, 2*radius))
        orbit.path = path.CGPath
        orbit.strokeColor = UIColor.whiteColor().alpha(0.5).CGColor
        orbit.lineWidth = 2.0
        orbit.fillColor = UIColor.clearColor().CGColor
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = 14.0
        strokeAnimation.fromValue = NSNumber(float: 0.0)
        strokeAnimation.toValue = NSNumber(float: 1.0)
        strokeAnimation.repeatCount = 1 //Float.infinity
        strokeAnimation.removedOnCompletion = false
        orbit.addAnimation(strokeAnimation, forKey: "orbit")
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = 14.0
        opacityAnimation.fromValue = NSNumber(float: 0.2)
        opacityAnimation.toValue = NSNumber(float: 1.0)
        opacityAnimation.repeatCount = 1 //Float.infinity
        opacityAnimation.removedOnCompletion = false
        orbit.addAnimation(opacityAnimation, forKey: "orbit_opacity")
        
        let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
        lineWidthAnimation.duration = 14.0
        lineWidthAnimation.fromValue = NSNumber(float: 0.0)
        lineWidthAnimation.toValue = NSNumber(float: 2.0)
        lineWidthAnimation.repeatCount = 1//Float.infinity
        lineWidthAnimation.removedOnCompletion = false
        orbit.addAnimation(lineWidthAnimation, forKey: "orbit_linewidth")
        view.layer.addSublayer(orbit)
        
        let planePosistion = CGPointMake(c.x + radius, c.y)
        let plane = UIImageView(image: UIImage(named: "find_plane")?.imageWithRenderingMode(.AlwaysTemplate))
        plane.tintColor = UIColor.whiteColor().alpha(0.8)
        plane.frame = CGRectMake(planePosistion.x - 20, planePosistion.y - 20, 40, 40)
        view.addSubview(plane)
        
        let group = CAAnimationGroup()
        group.duration = 14.0
        group.repeatCount = Float.infinity
        group.removedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.duration = 14.0
        rotationAnimation.fromValue = NSNumber(float: 0.0)
        rotationAnimation.toValue = NSNumber(float: Float(M_PI*2))
        
        let pathAnimation = CAKeyframeAnimation(keyPath: "position")
        pathAnimation.duration = 14.0
        pathAnimation.calculationMode = kCAAnimationPaced
        pathAnimation.path = UIBezierPath(ovalInRect: CGRectMake(c.x-radius, c.y-radius, 2*radius, 2*radius)).CGPath
        group.animations = [rotationAnimation, pathAnimation]
        
        plane.layer.addAnimation(group, forKey: "plane")
        
        let ovalAxisA:CGFloat = (SCREEN_WIDTH) / 2
        let ovalAxisB:CGFloat = ovalAxisA / 2 - 10
        
        let peopleOrbit = CAShapeLayer()
        var peoplePath = UIBezierPath(ovalInRect: CGRectMake(c.x-ovalAxisA, c.y-ovalAxisB, 2*ovalAxisA, 2*ovalAxisB)).CGPath
        peoplePath = rotatePath(peoplePath, angle: CGFloat(M_PI/4))
        peopleOrbit.path = peoplePath
        peopleOrbit.fillColor = UIColor.clearColor().CGColor
        peopleOrbit.strokeColor = UIColor.whiteColor().alpha(0.6).CGColor
        peopleOrbit.lineWidth = 2.0
        view.layer.addSublayer(peopleOrbit)
        
        let foodOrbit = CAShapeLayer()
        var foodPath = UIBezierPath(ovalInRect: CGRectMake(c.x-ovalAxisA, c.y-ovalAxisB, 2*ovalAxisA, 2*ovalAxisB)).CGPath
        foodPath = rotatePath(foodPath, angle: CGFloat(-M_PI/4))
        foodOrbit.path = foodPath
        foodOrbit.fillColor = UIColor.clearColor().CGColor
        foodOrbit.strokeColor = UIColor.whiteColor().alpha(0.6).CGColor
        foodOrbit.lineWidth = 2.0
        view.layer.addSublayer(foodOrbit)
        
        foodOrbit.addAnimation(strokeAnimation, forKey: "orbit")
        foodOrbit.addAnimation(opacityAnimation, forKey: "opacity")
        foodOrbit.addAnimation(lineWidthAnimation, forKey: "linewidth")

        
        peopleOrbit.addAnimation(strokeAnimation, forKey: "orbit")
        peopleOrbit.addAnimation(opacityAnimation, forKey: "opacity")
        peopleOrbit.addAnimation(lineWidthAnimation, forKey: "linewidth")
        
        people = FindItemView(frame:  CGRectMake(c.x+ovalAxisA*cos(CGFloat(M_PI/4))-50, c.y+ovalAxisB*sin(CGFloat(M_PI/4))-60, 100, 120))//UIImageView(image: UIImage(named: "find_people"))
        people.icon.image = UIImage(named:"find_people_male")
        people.titleLabel.text = "觅友"
        view.addSubview(people)
        
        let peopleGroup = CAAnimationGroup()
        peopleGroup.duration = 14.0
        peopleGroup.repeatCount = Float.infinity
        peopleGroup.removedOnCompletion = false
        
        let peoplePathAnimation = CAKeyframeAnimation(keyPath: "position")
        peoplePathAnimation.duration = 14.0
        peoplePathAnimation.calculationMode = kCAAnimationPaced
        peoplePathAnimation.path = peoplePath

        let peopleScaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        peopleScaleAnimation.duration = 14.0
        peopleScaleAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        peopleScaleAnimation.values = [0.8, 1.0, 0.8, 0.6, 0.8]
        peopleGroup.animations = [peoplePathAnimation, peopleScaleAnimation]
        
        people.layer.addAnimation(peopleGroup, forKey: "people")
        
    

        food = FindItemView(frame:  CGRectMake(c.x+ovalAxisA*cos(CGFloat(-M_PI/4))-50, c.y+ovalAxisB*sin(CGFloat(-M_PI/4))-60, 100, 120))//UIImageView(image: UIImage(named: "find_food"))
        food.icon.image = UIImage(named: "find_food")
        food.titleLabel.text = "觅食"
        view.addSubview(food)
        
        let foodGroup = CAAnimationGroup()
        foodGroup.duration = 14.0
        foodGroup.repeatCount = Float.infinity
        foodGroup.removedOnCompletion = false
        
        let foodPathAnimation = CAKeyframeAnimation(keyPath: "position")
        foodPathAnimation.duration = 14.0
        foodPathAnimation.calculationMode = kCAAnimationPaced
        foodPathAnimation.path = foodPath
        
        let foodScaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        foodScaleAnimation.duration = 14.0
        foodScaleAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        foodScaleAnimation.values = [0.8, 1.0, 0.8, 0.6, 0.8]

        
        foodGroup.animations = [foodPathAnimation, foodScaleAnimation]
        
        food.layer.addAnimation(foodGroup, forKey: "food")
        
        changeAvatar()
        
    }
    
    func changeAvatar() {
        ProfileCache.sharedCache.loadProfileWithCompletionBlock({ [weak self](info) -> Void in
            if let p = info , S = self{
                if p.gender == "男" {
                    S.people.icon.image = UIImage(named: "find_people_female")
                }
                else {
                    S.people.icon.image = UIImage(named: "find_people_male")
                }
            }
        })

    }
    
    func rotatePath(path:CGPathRef, angle:CGFloat) -> CGPathRef {
        let box = CGPathGetPathBoundingBox(path)
        let center = CGPointMake(CGRectGetMidX(box), CGRectGetMidY(box))
        var transform = CGAffineTransformIdentity
        transform = CGAffineTransformTranslate(transform, center.x, center.y)
        transform = CGAffineTransformRotate(transform, angle)
        transform = CGAffineTransformTranslate(transform, -center.x, -center.y)
        return CGPathCreateCopyByTransformingPath(path, &transform)!
    }
    
    func tap(sender:UITapGestureRecognizer) {
       let loc = sender.locationInView(view)
       
        if let p = people.layer.presentationLayer() as? CALayer {
            if CGRectContainsPoint(p.frame, loc) {
                let vc = CardPeopleVC()
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        
        if let p = food.layer.presentationLayer() as? CALayer {
            if CGRectContainsPoint(p.frame, loc) {
                let vc = CardFoodVC()
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
    }

}

class FindItemView:UIView {
    var icon:UIImageView!
    var titleLabel:UILabel!
    
    func initialize() {
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(icon)
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.whiteColor().alpha(0.5)
        addSubview(titleLabel)
        
        icon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.top.equalTo(snp_top)
            make.right.equalTo(snp_right)
            make.width.equalTo(icon.snp_height)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(icon.snp_bottom).offset(-2)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
