//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import UIKit

/**
    Bubble types
*/
public enum BubbleType {
    // Outcome text bubble
    case TextOut
    // Income text bubble
    case TextIn
    // Outcome media bubble
    case MediaOut
    // Income media bubble
    case MediaIn
    // Service bubble
    case Service
    // Sticker bubble
    case Sticker
}

/**
    Root class for bubble layouter. Used for preprocessing bubble layout in background.
*/
public protocol AABubbleLayouter  {
    
    func isSuitable(message: ACMessage) -> Bool
    
    func buildLayout(peer: ACPeer, message: ACMessage) -> AACellLayout
    
    func cellClass() -> AnyClass
}

extension AABubbleLayouter {
    func cellReuseId() -> String {
        return "cell_\(cellClass())"
    }
}

/**
    Root class for bubble cells
*/
public class AABubbleCell: UICollectionViewCell {
    
    public static let bubbleContentTop: CGFloat = 6
    public static let bubbleContentBottom: CGFloat = 6
    public static let bubbleTop: CGFloat = 3
    public static let bubbleTopCompact: CGFloat = 1
    public static let bubbleBottom: CGFloat = 3
    public static let bubbleBottomCompact: CGFloat = 1
    public static let avatarPadding: CGFloat = 39
    public static let dateSize: CGFloat = 30
    public static let newMessageSize: CGFloat = 30
    
    private static let outBgColor = UIColor(red:0.87, green:0.94, blue:0.97, alpha:1.0)
    private static let mentionBgColor = UIColor(red:0.87, green:0.97, blue:0.90, alpha:1.0)
    
    //
    // Cached Date bubble images
    //
    private static var dateBgImage = ActorSDK.sharedActor().style.statusBackgroundImage
    
    // MARK: -
    // MARK: Public vars
    
    // Views
    public let avatarView = AAAvatarView()
    public var avatarAdded: Bool = false
    
    private static var likeImageFilledGray = UIImage.bundled("heart_filled_gray")
    private static var likeImageFilledRed = UIImage.bundled("heart_filled_red")
    private static var likeImage = UIImage.bundled("heart_outline")
    private static var likeCounterColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.0)
    private static var likeCounterFont = UIFont.textFontOfSize(8)
    public let likeBtn = UIImageView()
    public var likeBtnAdded: Bool = false
    
    private let dateText = UILabel()
    private let dateBg = UIImageView()
    
    private let newMessage = UILabel()
    
    // Layout
    public var contentInsets : UIEdgeInsets = UIEdgeInsets()
    public var bubbleInsets : UIEdgeInsets = UIEdgeInsets()
    public var fullContentInsets : UIEdgeInsets {
        get {
            return UIEdgeInsets(
                top: contentInsets.top + bubbleInsets.top + (isShowDate ? AABubbleCell.dateSize : 0) + (isShowNewMessages ? AABubbleCell.newMessageSize : 0),
                left: contentInsets.left + bubbleInsets.left + (isGroup ? AABubbleCell.avatarPadding : 0),
                bottom: contentInsets.bottom + bubbleInsets.bottom,
                right: contentInsets.right + bubbleInsets.right)
        }
    }
    public var needLayout: Bool = true
    
    public let groupContentInsetY = 20.0
    public let groupContentInsetX = 40.0
    public var bubbleVerticalSpacing: CGFloat = 6.0
    public let bubblePadding: CGFloat = 6;
    public let bubbleMediaPadding: CGFloat = 10;
    
    // Binded data
    public var peer: ACPeer!
    public weak var controller: AAConversationContentController!
    public var isGroup: Bool = false
    public var isFullSize: Bool!
    public var bindedSetting: AACellSetting?
    
    public var bindedMessage: ACMessage? = nil
    public var bubbleType:BubbleType? = nil
    public var isOut: Bool = false
    public var isShowDate: Bool = false
    public var isShowNewMessages: Bool = false
    
    var appStyle: ActorStyle {
        get {
            return ActorSDK.sharedActor().style
        }
    }
    
    // MARK: -
    // MARK: Constructors

    public init(frame: CGRect, isFullSize: Bool) {
        super.init(frame: frame)
        
        self.isFullSize = isFullSize
  
        dateBg.image = AABubbleCell.dateBgImage
        dateText.font = UIFont.mediumSystemFontOfSize(12)
        dateText.textColor = appStyle.chatDateTextColor
        dateText.contentMode = UIViewContentMode.Center
        dateText.textAlignment = NSTextAlignment.Center
        
        newMessage.font = UIFont.mediumSystemFontOfSize(14)
        newMessage.textColor = appStyle.chatUnreadTextColor
        newMessage.contentMode = UIViewContentMode.Center
        newMessage.textAlignment = NSTextAlignment.Center
        newMessage.backgroundColor = appStyle.chatUnreadBgColor
        newMessage.text = AALocalized("ChatNewMessages")
        
        //"New Messages"
        
        contentView.transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
        
        contentView.addSubview(newMessage)
        contentView.addSubview(dateBg)
        contentView.addSubview(dateText)
        
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AABubbleCell.avatarDidTap)))
        avatarView.userInteractionEnabled = true

        likeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AABubbleCell.likeDidTap)))
        likeBtn.userInteractionEnabled = true
        
        backgroundColor = UIColor.clearColor()
        
        // Speed up animations
        self.layer.speed = 1.5
        
        //self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = UIScreen.mainScreen().scale
        //self.layer.drawsAsynchronously = true
        //self.contentView.layer.drawsAsynchronously = true
        
        let swipeDetector = UISwipeGestureRecognizer(
            target: self,
            action: #selector(AABubbleCell.contentViewDidSwipe))
        swipeDetector.direction = UISwipeGestureRecognizerDirection.Left
        contentView.addGestureRecognizer(swipeDetector)
        contentView.userInteractionEnabled = true;
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConfig(peer: ACPeer, controller: AAConversationContentController) {
        self.peer = peer
        self.controller = controller
        if (peer.isGroup && !isFullSize) {
            self.isGroup = true
        }
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return false
    }

    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(NSObject.delete(_:)) {
            return true
        }
        return false
    }
    
    public override func delete(sender: AnyObject?) {
        let rids = IOSLongArray(length: 1)
        rids.replaceLongAtIndex(0, withLong: bindedMessage!.rid)
        Actor.deleteMessagesWithPeer(self.peer, withRids: rids)
    }

    func contentViewDidSwipe() {
        if(!LikersOverlay.shared.isVisible() && bindedMessage != nil) {
            LikersOverlay.shared.showOverlay(contentView.superview!.superview!.superview!, message: bindedMessage!)
        }
    }
    
    func avatarDidTap() {
        if bindedMessage != nil {
            controller.onBubbleAvatarTap(self.avatarView, uid: bindedMessage!.senderId)
        }
    }
    
    func likeDidTap() {
        if bindedMessage != nil {
            likeBtnAdded = false
            likeBtn.removeFromSuperview()
            
            if (bindedMessage!.reactions != nil &&
                bindedMessage!.reactions.size() > 0 &&
                bindedMessage!.reactions.getWithInt(0).getUids() != nil &&
                (bindedMessage!.reactions.getWithInt(0).getUids() as JavaUtilList).containsWithId(Actor.myUid().toNSNumber())) {
                controller.execute(Actor.removeReactionWithPeer(self.peer, withRid: bindedMessage!.rid, withCode: "❤"))
            }
            else {
                controller.execute(Actor.addReactionWithPeer(self.peer, withRid: bindedMessage!.rid, withCode: "❤"))
            }
        }
    }
    
    public func performBind(message: ACMessage, receiveDate: jlong, readDate: jlong, setting: AACellSetting, isShowNewMessages: Bool, layout: AACellLayout) {

        var reuse = false
        if (bindedMessage != nil && bindedMessage?.rid == message.rid && bindedMessage?.reactions?.size() == message.reactions?.size()) {
            reuse = true
        }
        isOut = message.senderId == Actor.myUid();
        backgroundColor = isOut ? AABubbleCell.outBgColor : UIColor.clearColor()
        bindedMessage = message
        
        if let textContent = message.content as? ACTextContent {
            if textContent.getMentions().containsWithId(Actor.myUid().toNSNumber()) {
                backgroundColor = AABubbleCell.mentionBgColor
            }
        }
        
        self.isShowNewMessages = isShowNewMessages
        if !reuse && !isFullSize {
            if (isGroup) {
                let user = Actor.getUserWithUid(message.senderId)
                        
                // Small hack for replacing senter name and title
                // with current group title
                if user.isBot() && user.getNameModel().get() == "Bot" {
                    let group = Actor.getGroupWithGid(self.peer.peerId)
                    let avatar: ACAvatar? = group.getAvatarModel().get()
                    let name = group.getNameModel().get()
                    avatarView.bind(name, id: Int(user.getId()), avatar: avatar)
                } else {
                    let avatar: ACAvatar? = user.getAvatarModel().get()
                    let name = user.getNameModel().get()
                    avatarView.bind(name, id: Int(user.getId()), avatar: avatar)
                }
                if !avatarAdded {
                    contentView.addSubview(avatarView)
                    avatarAdded = true
                }
                
                if bindedMessage != nil {
                    let likeCount = UILabel()
                    likeCount.textAlignment = NSTextAlignment.Center
                    likeCount.font = AABubbleCell.likeCounterFont
                    likeCount.textColor = AABubbleCell.likeCounterColor
                    likeCount.frame = CGRect(x: 11, y: 14, width: 9, height: 9);
                    likeCount.text = "0"
                    likeBtn.image = AABubbleCell.likeImage
                    
                    if(bindedMessage!.reactions != nil && bindedMessage!.reactions.size() > 0) {
                        let uids = bindedMessage!.reactions.getWithInt(0).getUids() as JavaUtilList;
                        if(uids.containsWithId(Actor.myUid().toNSNumber())) {
                            likeBtn.image = AABubbleCell.likeImageFilledRed
                        }
                        else {
                            likeBtn.image = AABubbleCell.likeImageFilledGray
                        }
                        likeCount.text = String(uids.size())
                    }
                    
                    likeBtn.removeAllSubviews()
                    likeBtn.addSubview(likeCount)
                }
                
                if !likeBtnAdded {
                    contentView.addSubview(likeBtn)
                    likeBtnAdded = true
                }
            } else {
                if avatarAdded {
                    avatarView.removeFromSuperview()
                    avatarAdded = false
                }
                if likeBtnAdded {
                    likeBtn.removeFromSuperview()
                    likeBtnAdded = false
                }
            }
        }
        
        self.isShowDate = setting.showDate
        if (isShowDate) {
            self.dateText.text = layout.anchorDate
        }
        
        self.bindedSetting = setting
        
        bind(message, receiveDate: receiveDate, readDate: readDate, reuse: reuse, cellLayout: layout, setting: setting)
        
        if (!reuse) {
            needLayout = true
            super.setNeedsLayout()
        }
    }
    
    public func bind(message: ACMessage, receiveDate: jlong, readDate: jlong, reuse: Bool, cellLayout: AACellLayout, setting: AACellSetting) {
        fatalError("bind(message:) has not been implemented")
    }
    
    public func bindBubbleType(type: BubbleType, isCompact: Bool) {
    }
    
    func updateView() {
    }
    
    // MARK: -
    // MARK: Layout
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        UIView.performWithoutAnimation { () -> Void in
            let endPadding: CGFloat = 32
            let startPadding: CGFloat = (self.isGroup) ? AABubbleCell.avatarPadding : 0
            let cellMaxWidth = self.contentView.frame.size.width - endPadding - startPadding
            self.layoutContent(cellMaxWidth, offsetX: startPadding)
            self.layoutAnchor()
            if (self.isGroup && !self.isFullSize) {
                self.layoutAvatar()
                self.layoutLike()
            }
        }
    }
    
    func layoutAnchor() {
        if (isShowDate) {
            dateText.frame = CGRectMake(0, 0, 1000, 1000)
            dateText.sizeToFit()
            dateText.frame = CGRectMake(
                (self.contentView.frame.size.width-dateText.frame.width)/2, 8, dateText.frame.width, 18)
            dateBg.frame = CGRectMake(dateText.frame.minX - 8, dateText.frame.minY, dateText.frame.width + 16, 18)
            
            dateText.hidden = false
            dateBg.hidden = false
        } else {
            dateText.hidden = true
            dateBg.hidden = true
        }
        
        if (isShowNewMessages) {
            var top = CGFloat(0)
            if (isShowDate) {
                top += AABubbleCell.dateSize
            }
            newMessage.hidden = false
            newMessage.frame = CGRectMake(0, top + CGFloat(2), self.contentView.frame.width, AABubbleCell.newMessageSize - CGFloat(4))
        } else {
            newMessage.hidden = true
        }
    }
    
    public func layoutContent(maxWidth: CGFloat, offsetX: CGFloat) {
        
    }
    
    func layoutAvatar() {
        let avatarSize = CGFloat(36)
        avatarView.frame = CGRect(
            x: 10,
            y: 10,
            width: avatarSize,
            height: avatarSize)
    }
    
    func layoutLike() {
        likeBtn.frame = CGRect(
            x: self.contentView.frame.size.width - 26,
            y: 10,
            width: 18,
            height: 18)
    }
    
    // Need to be called in child cells
    public func layoutBubble(contentWidth: CGFloat, contentHeight: CGFloat) {
    }
    
    public func layoutBubble(frame: CGRect) {
    }
    
    public override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}
