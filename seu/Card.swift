//
//  Card.swift
//  WE
//
//  Created by liewli on 12/21/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

enum CardState {
    case Empty
    case NoneEmpty
    case Animating
    case Flipped
}

class CardVC:UIViewController {
    var actionLeft:UIButton!
    var midView:UIView!
    var actionRight:UIButton!
    
    var topView:UIView!
    
    var cardText = "点击此处 抽取卡片"
    
    private var cardView:UIView!
    
    private var backView:UIImageView!
    
    private var deckView:UIImageView!
    
    private var visualView:UIVisualEffectView!
    
    private var hostView:UIView!
    
    private var drawCardLabel:UILabel!
    
    private var state:CardState = .Empty
    
    private var currentCard:CardContentView? {
        didSet {
            currentCard?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        configUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.hidden = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        navigationController?.navigationBar.hidden = false
    }
    
    func setupUI() {
//        
//        let bottomEdge = UIScreenEdgePanGestureRecognizer(target: self, action: "tapDeck:")
//        bottomEdge.edges = .Bottom
//        view.addGestureRecognizer(bottomEdge)
        
        backView = UIImageView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backView)
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        let blurEffect = UIBlurEffect(style: .Light)
        visualView = UIVisualEffectView(effect: blurEffect)
        visualView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualView)
        visualView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        hostView = UIView()
        hostView.translatesAutoresizingMaskIntoConstraints = false
        hostView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        visualView.contentView.addSubview(hostView)
        hostView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(visualView.contentView.snp_left)
            make.right.equalTo(visualView.contentView.snp_right)
            make.top.equalTo(visualView.contentView.snp_top)
            make.bottom.equalTo(visualView.contentView.snp_bottom)
        }
        
        
        midView = UIView()
        midView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(midView)
        midView.backgroundColor = UIColor.clearColor()
       
        
        actionLeft = UIButton(type: .System)
        actionLeft.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(actionLeft)
        actionLeft.setImage(UIImage(named: "card_back")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        actionLeft.addTarget(self, action: "tapLeft:", forControlEvents: .TouchUpInside)
        actionLeft.tintColor = UIColor.whiteColor()
        actionLeft.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(midView.snp_centerY)
            make.centerX.equalTo(hostView.snp_centerX).multipliedBy(0.2)
            make.height.width.equalTo(24)
        }
        
        actionRight = UIButton(type: .System)
        actionRight.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(actionRight)
        actionRight.setImage(UIImage(named: "card_more")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        actionRight.addTarget(self, action: "tapRight:", forControlEvents: .TouchUpInside)
        actionRight.tintColor = UIColor.whiteColor()
        actionRight.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(midView.snp_centerY)
            make.centerX.equalTo(hostView.snp_centerX).multipliedBy(1.8)
            make.height.width.equalTo(24)
        }
        
        midView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(actionLeft.snp_right)
            make.right.equalTo(actionRight.snp_left)
            make.height.equalTo(24)
            make.top.equalTo(hostView.snp_topMargin).offset(10)
        }
        
        deckView = UIImageView()
        deckView.translatesAutoresizingMaskIntoConstraints  = false
        deckView.backgroundColor = UIColor.whiteColor()
        deckView.userInteractionEnabled = true
        deckView.layer.borderWidth = 10
        deckView.layer.borderColor = UIColor.whiteColor().CGColor
        //deckView.contentMode = .ScaleToFill
       // deckView.image = UIImage(named: "spade")
        let tap = UITapGestureRecognizer(target: self, action: "tapDeck:")
        deckView.addGestureRecognizer(tap)
        hostView.addSubview(deckView)
        
        
        cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor.clearColor()
        hostView.addSubview(cardView)
       // cardView.layer.cornerRadius = 5.0
       // cardView.layer.masksToBounds = true
        cardView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(hostView.snp_centerX)
            make.centerY.equalTo(hostView.snp_centerY)
            make.width.equalTo(hostView.snp_width).multipliedBy(0.7)
            make.height.equalTo(cardView.snp_width).offset(120)
        }
        
    
        deckView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(hostView.snp_centerX)
            make.width.equalTo(cardView.snp_width)
            make.height.equalTo(hostView.snp_height).multipliedBy(0.1)
            make.bottom.equalTo(hostView.snp_bottom).offset(10)
        }
        
        topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(topView)
        topView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(hostView.snp_left)
            make.right.equalTo(hostView.snp_right)
            make.top.equalTo(actionLeft.snp_bottom)
            make.bottom.equalTo(cardView.snp_top)
        }

        
        drawCardLabel = UILabel()
        drawCardLabel.translatesAutoresizingMaskIntoConstraints = false
        deckView.addSubview(drawCardLabel)
        drawCardLabel.textColor = THEME_COLOR_BACK
        drawCardLabel.backgroundColor = UIColor.whiteColor()//UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        drawCardLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        drawCardLabel.textAlignment = .Center
        drawCardLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(deckView.snp_left)
            make.right.equalTo(deckView.snp_right)
            make.top.equalTo(deckView.snp_top).offset(10)
        }
        let text = cardText
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttributes([NSForegroundColorAttributeName:UIColor.colorFromRGB(0x3c404a), NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)], range: NSMakeRange(2, 5))
        drawCardLabel.attributedText = attributedText
        
    }
    
    func tapLeft(sender:AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    func tapRight(sender:AnyObject) {
    }
    
    func tapDeck(sender:AnyObject) {
        switch state {
        case .Empty:
            state = .Animating
             let rect = CGRectMake(self.deckView.frame.origin.x, self.deckView.frame.origin.y, self.cardView.frame.size.width, self.cardView.frame.size.height)
             let rect1 = hostView.convertRect(rect, toView: cardView)
            let cardDefault1 = CardDefaultView(frame:rect1)
            cardDefault1.imgView.image = UIImage(named: "spade")
            self.cardView.addSubview(cardDefault1)
            
            UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: { () -> Void in
                cardDefault1.frame = CGRectMake(0, 0, self.cardView.frame.size
                    .width, self.cardView.frame.size.height)
                }, completion: { (finished) -> Void in
                   // self.refreshBackView(cardDefault1)
                    let card1 = self.nextCard()
                    card1.frame = self.cardView.bounds
                    self.currentCard = card1
                    UIView.transitionFromView(cardDefault1, toView: card1, duration: 0.6, options: .TransitionFlipFromBottom, completion: { (finished) -> Void in
                        //self.refreshBackView(card1)
                        self.state = .NoneEmpty
                    })

            })


        case .NoneEmpty, .Flipped:
            state  = .Animating
            let cardDefault = CardDefaultView(frame: cardView.bounds)
            cardDefault.imgView.image = UIImage(named: "spade")
            let card = cardView.subviews[0]
            UIView.transitionFromView(card, toView: cardDefault, duration: 0.8, options: [.TransitionFlipFromTop, .CurveEaseInOut]) { (finished) -> Void in
                //self.refreshBackView(cardDefault)
                let rect = CGRectMake(self.deckView.frame.origin.x, self.deckView.frame.origin.y, self.cardView.frame.size.width, self.cardView.frame.size.height)
                let rect1 = self.hostView.convertRect(rect, toView: self.cardView)
                let cardDefault1 = CardDefaultView(frame:rect1)
                cardDefault1.imgView.image = UIImage(named: "spade")
                self.cardView.addSubview(cardDefault1)
                
                let rect2 = CGRectMake(self.deckView.frame.origin.x, self.deckView.frame.origin.y + self.deckView.frame.size.height, self.cardView.frame.size.width, self.cardView.frame.size.height)
                let rect3 = self.hostView.convertRect(rect2, toView: self.cardView)

                UIView.animateWithDuration(1 , delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .CurveEaseIn, animations: { () -> Void in
                    cardDefault.frame = rect3
                    cardDefault1.frame = CGRectMake(0, 0, self.cardView.frame.size
                        .width, self.cardView.frame.size.height)
                    }, completion: { (finished) -> Void in
                        cardDefault.removeFromSuperview()
                        let card1 = self.nextCard()
                        card1.frame = self.cardView.bounds
                        self.currentCard = card1
                        UIView.transitionFromView(cardDefault1, toView: card1, duration: 0.6, options: [.TransitionFlipFromBottom, .CurveEaseInOut], completion: { (finished) -> Void in
                            //self.refreshBackView(card1)
                            self.state = .NoneEmpty
                        })
                        
                })

            }
        case .Animating:
            break

        }
    }
    
    func nextCard() -> CardContentView {
        return CardContentView()
    }
    
    func detailViewForCurrentCard() -> CardDetailView? {
        return CardDetailView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let path = UIBezierPath(roundedRect:deckView.bounds, byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSizeMake(10.0, 10.0))
        let shape = CAShapeLayer()
        shape.path = path.CGPath
        deckView.layer.mask = shape
        deckView.layer.masksToBounds = true
        
    }
    
    func refreshBackView(card:CardContentView) {
        if let img = card.imgView.image {
            //let backImg = Utility.imageWithImage(img, scaledToSize: backView.bounds.size)
            UIView.transitionWithView(backView, duration: 1.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { [weak self]() -> Void in
                if let S = self {
                    S.backView.image = img
                }
                }, completion: nil)

        }
        
    }
    
    func maskPath() {
        let width = drawCardLabel.bounds.size.width
        let height = drawCardLabel.bounds.size.height
        let points = [CGPointMake(0.1*width, 0), CGPointMake(0.2*width, height), CGPointMake(width-0.2*width, height), CGPointMake(width-0.1*width, 0)]
        let sp = points[0]
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, sp.x, sp.y)
        for p in points {
            CGPathAddLineToPoint(path, nil, p.x, p.y)
        }
        CGPathCloseSubpath(path)
        
        let shape = CAShapeLayer()
        shape.path = path
        drawCardLabel.layer.mask = shape
        drawCardLabel.layer.masksToBounds = true
    }
    
    func refreshBackground(image:UIImage) {
 
        //let backImg = Utility.imageWithImage(image, scaledToSize: backView.bounds.size)
        UIView.transitionWithView(backView, duration: 1.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { [weak self]() -> Void in
                if let S = self {
                    S.backView.image = image
                }
            }, completion: nil)
    }
    
    func configUI() {
        refreshBackground(UIImage(named: "spade")!)
        
        deckView.image = UIImage(named: "spade")?.crop(CGRectMake(0, 0, deckView.bounds.size.width, deckView.bounds.size.height))
        maskPath()
    }
}

extension CardVC:CardContentViewDelegate, CardDetailViewDelegate {
    func didTapNext() {
        state = .Flipped
        if let cardDetail = detailViewForCurrentCard(){
            cardDetail.delegate = self
            cardDetail.frame = self.cardView.bounds
            UIView.transitionFromView(currentCard!, toView: cardDetail, duration: 0.6, options: [.TransitionFlipFromRight, .CurveEaseInOut]) { (finished) -> Void in
                
            }
        }
       
    }
   
    func didTapBackInCardDetailView(card: CardDetailView) {
        UIView.transitionFromView(card, toView: self.currentCard!, duration: 0.8, options: [.TransitionFlipFromLeft, .CurveEaseInOut]) { (finished) -> Void in
            self.state = .NoneEmpty
        }
    }
}



class CardDefaultView: CardContentView {
    func initialize() {
        imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = 6
        imgView.layer.masksToBounds = true
        imgView.layer.borderColor = UIColor.whiteColor().CGColor
        imgView.layer.borderWidth = 10
        addSubview(imgView)
        imgView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

}

class CardContentView:UIView {
    var imgView:UIImageView!
    weak var delegate:CardContentViewDelegate?
    
}

protocol CardContentViewDelegate:class {
    func didTapNext()
}


class CardDetailView:UIView {
    weak var delegate:CardDetailViewDelegate?
}


protocol CardDetailViewDelegate:class {
    func didTapBackInCardDetailView(card:CardDetailView)
}



