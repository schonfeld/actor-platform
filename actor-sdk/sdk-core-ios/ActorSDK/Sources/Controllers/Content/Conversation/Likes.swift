//
//  Likes.swift
//  ActorSDK
//
//  Created by Michael Schonfeld on 9/6/16.
//  Copyright © 2016 Steve Kite. All rights reserved.
//

import Foundation

open class LikersOverlay {
    fileprivate static var textColor = UIColor(red:1, green:1, blue:1, alpha:1.0)
    fileprivate static var textFont = UIFont.textFontOfSize(14)
    fileprivate static var overlayFont = UIFont.textFontOfSize(20)
    fileprivate static let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    fileprivate static let blurEffectView = UIVisualEffectView(effect: blurEffect)

    fileprivate let dateFormatter = DateFormatter().initFullDateFormatter()
    
    var overlayView = UIView()
    var overlayTitle = UILabel()
    var likersTitle = UILabel()
    var likersLabel = UILabel()
    var sentAtTitle = UILabel()
    var sentAtLabel = UILabel()

    class var shared: LikersOverlay {
        struct Static {
            static let instance: LikersOverlay = LikersOverlay()
        }
        
        return Static.instance
    }
    
    open func showOverlay(_ view: UIView!, message: ACMessage) {
        overlayView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width - 60,
            height: 250))
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        overlayView.layer.cornerRadius = 10
        overlayView.clipsToBounds = true
        
        // Overlay title
        overlayTitle = UILabel(frame: CGRect(x: 0, y: 5, width: overlayView.bounds.width, height: 35))
        overlayTitle.text = "Message Info"
        overlayTitle.textAlignment = NSTextAlignment.center
        overlayTitle.font = LikersOverlay.overlayFont
        overlayTitle.textColor = LikersOverlay.textColor
        overlayView.addSubview(overlayTitle)
        
        // Likers information
        likersTitle = UILabel(frame: CGRect(x: 5, y: 60, width: overlayView.bounds.width - 10, height: 20))
        likersTitle.text = "liked by"
        likersTitle.textAlignment = NSTextAlignment.left
        likersTitle.textColor = LikersOverlay.textColor
        likersTitle.font = LikersOverlay.textFont
        let likersTitleBottomLine = CALayer()
        likersTitleBottomLine.frame = CGRect(x:0, y:20, width:(overlayView.bounds.width-10), height: 1.0)
        likersTitleBottomLine.backgroundColor = UIColor.white.cgColor
        likersTitle.layer.addSublayer(likersTitleBottomLine)
        overlayView.addSubview(likersTitle)
        
        var likers:[String] = [];
        if(message.reactions != nil && message.reactions.size() > 0) {
            let uids = (message.reactions.getWith(0) as AnyObject).getUids() as JavaUtilList;

            for uid:Int in uids.toSwiftArray() {
                let user = Actor.getUserWithUid(jint(uid))
                likers.append(user.getNameModel().get())
            }
        }
        
        if(likers.isEmpty) {
            likers.append("(nobody)")
        }
        
        likersLabel = UILabel(frame: CGRect(x: 5, y: 84, width: overlayView.bounds.width - 10, height: 70))
        likersLabel.text = likers.joined(separator: ", ")
        likersLabel.font = LikersOverlay.textFont
        likersLabel.textColor = LikersOverlay.textColor
        likersLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        likersLabel.numberOfLines = 0
        likersLabel.sizeToFit()
        overlayView.addSubview(likersLabel)
        
        // Sent at
        sentAtTitle = UILabel(frame: CGRect(x: 5, y: 150, width: overlayView.bounds.width - 10, height: 20))
        sentAtTitle.text = "sent at"
        sentAtTitle.textAlignment = NSTextAlignment.left
        sentAtTitle.textColor = LikersOverlay.textColor
        sentAtTitle.font = LikersOverlay.textFont
        let sentAtBottomLine = CALayer()
        sentAtBottomLine.frame = CGRect(x:0,y:0,width:(overlayView.bounds.width-10), height: 1.0);
        sentAtBottomLine.backgroundColor = UIColor.white.cgColor
        sentAtTitle.layer.addSublayer(sentAtBottomLine)
        overlayView.addSubview(sentAtTitle)

        sentAtLabel = UILabel(frame: CGRect(x: 5, y: 170, width: overlayView.bounds.width - 10, height: 30))
        sentAtLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(Double(message.date) / 1000.0)))
        sentAtLabel.font = LikersOverlay.textFont
        sentAtLabel.textColor = LikersOverlay.textColor
        overlayView.addSubview(sentAtLabel)
        
        // Dismiss on tap
        overlayView.gestureRecognizers?.removeAll()
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LikersOverlay.hideOverlayView)))
        overlayView.isUserInteractionEnabled = true
        
        LikersOverlay.blurEffectView.frame = UIScreen.main.bounds
        LikersOverlay.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        LikersOverlay.blurEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LikersOverlay.hideOverlayView)))
        LikersOverlay.blurEffectView.isUserInteractionEnabled = true
        view.addSubview(LikersOverlay.blurEffectView)

        UIView.transition(with: view, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {view.addSubview(self.overlayView)}, completion: nil)
    }
    
    @objc open func hideOverlayView() {
        overlayView.removeFromSuperview()
        LikersOverlay.blurEffectView.removeFromSuperview()
    }
    
    open func isVisible() -> Bool {
        return overlayView.superview != nil
    }
}

extension DateFormatter {
    func initFullDateFormatter() -> DateFormatter {
        dateFormat = "EEEE, MMM d, yyyy 'at' HH:mm"
        return self
    }
}
