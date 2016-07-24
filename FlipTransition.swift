//
//  FlipTransition.swift
//  WEME
//
//  Created by liewli on 3/3/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class FlipTransitionAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    var presenting:Bool = true
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()!
        if presenting {
            containerView.addSubview(toVC.view)
        }
        
        var transform = CATransform3DIdentity
        transform.m34 = -0.002
        containerView.layer.sublayerTransform = transform
        
        let initialFrame = transitionContext.initialFrameForViewController(fromVC)
        fromVC.view.frame = initialFrame
        toVC.view.frame = initialFrame
        
        let factor:CGFloat = self.presenting ? 1.0 : -1.0
        toVC.view.layer.transform = CATransform3DMakeRotation(factor*(CGFloat(-M_PI_2)), 0, 1.0, 0)
        
        UIView.animateKeyframesWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewKeyframeAnimationOptions.CalculationModeLinear, animations: { () -> Void in
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                    fromVC.view.layer.transform = CATransform3DMakeRotation(factor*CGFloat(M_PI_2), 0, 1.0, 0)
                })
            
                UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                    toVC.view.layer.transform = CATransform3DMakeRotation(0, 0, 1.0, 0)
                })
            }) { (finished) -> Void in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
        
    }
    
}
