//
//  NavigationTransition.swift
//  WEME
//
//  Created by liewli on 2/25/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class NavigationPushAnimator:NSObject, UIViewControllerAnimatedTransitioning{
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        containerView?.addSubview(toVC.view)
        containerView?.backgroundColor = UIColor.blackColor()
        toVC.view.transform = CGAffineTransformMakeTranslation(toVC.view.bounds.size.width, 0)
        toVC.view.alpha = 0
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
                fromVC.view.transform = CGAffineTransformMakeScale(0.9, 0.9)
                toVC.view.transform = CGAffineTransformIdentity
                toVC.view.alpha = 1.0
            }) { (finished) -> Void in
                fromVC.view.transform = CGAffineTransformIdentity
                transitionContext.completeTransition(!(transitionContext.transitionWasCancelled()))
        }
    }
}

class NavigationPopAnimator:NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        containerView?.insertSubview(toVC.view, belowSubview: fromVC.view)
        toVC.view.transform = CGAffineTransformMakeScale(0.9, 0.9)
        //toVC.view.transform = CGAffineTransformMakeTranslation(toVC.view.bounds.size.width, 0)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            fromVC.view.transform = CGAffineTransformMakeTranslation(fromVC.view.bounds.size.width, 0)
            //fromVC.view.transform = CGAffineTransformScale(fromVC.view.transform, 0.8, 0.8)
            toVC.view.transform = CGAffineTransformIdentity
            //toVC.view.transform = CGAffineTransformIdentity
            }) { (finished) -> Void in
                fromVC.view.transform = CGAffineTransformIdentity
                transitionContext.completeTransition(!(transitionContext.transitionWasCancelled()))
        }

    }
}
