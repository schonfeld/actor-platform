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
    case textOut
    // Income text bubble
    case textIn
    // Outcome media bubble
    case mediaOut
    // Income media bubble
    case mediaIn
    // Service bubble
    case service
    // Sticker bubble
    case sticker
}

/**
    Root class for bubble layouter. Used for preprocessing bubble layout in background.
*/
public protocol AABubbleLayouter  {

    func isSuitable(_ message: ACMessage) -> Bool

    func buildLayout(_ peer: ACPeer, message: ACMessage) -> AACellLayout

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
open class AABubbleCell: UICollectionViewCell {

    open static let bubbleContentTop: CGFloat = 6
    open static let bubbleContentBottom: CGFloat = 6
    open static let bubbleTop: CGFloat = 3
    open static let bubbleTopCompact: CGFloat = 1
    open static let bubbleBottom: CGFloat = 3
    open static let bubbleBottomCompact: CGFloat = 1
    open static let avatarPadding: CGFloat = 39
    open static let dateSize: CGFloat = 30
    open static let newMessageSize: CGFloat = 30

    fileprivate static let outBgColor = UIColor(red:0.87, green:0.94, blue:0.97, alpha:1.0)
    fileprivate static let mentionBgColor = UIColor(red:0.87, green:0.97, blue:0.90, alpha:1.0)

    //
    // Cached Date bubble images
    //
    fileprivate static var dateBgImage = ActorSDK.sharedActor().style.statusBackgroundImage

    // MARK: -
    // MARK: Public vars

    // Views
    open let avatarView = AAAvatarView()
    open var avatarAdded: Bool = false

    fileprivate static var likeImageFilledGray = UIImage.bundled("heart_filled_gray")
    fileprivate static var likeImageFilledRed = UIImage.bundled("heart_filled_red")
    fileprivate static var likeImage = UIImage.bundled("heart_outline")
    fileprivate static var likeCounterColor = UIColor(red:0.62, green:0.62, blue:0.62, alpha:1.0)
    fileprivate static var likeCounterFont = UIFont.textFontOfSize(8)
    open let likeBtn = UIImageView()

    fileprivate let dateText = UILabel()
    fileprivate let dateBg = UIImageView()

    fileprivate let newMessage = UILabel()

    // Layout
    open var contentInsets : UIEdgeInsets = UIEdgeInsets()
    open var bubbleInsets : UIEdgeInsets = UIEdgeInsets()
    open var fullContentInsets : UIEdgeInsets {
        get {
            return UIEdgeInsets(
                top: contentInsets.top + bubbleInsets.top + (isShowDate ? AABubbleCell.dateSize : 0) + (isShowNewMessages ? AABubbleCell.newMessageSize : 0),
                left: contentInsets.left + bubbleInsets.left + (isGroup ? AABubbleCell.avatarPadding : 0),
                bottom: contentInsets.bottom + bubbleInsets.bottom,
                right: contentInsets.right + bubbleInsets.right)
        }
    }
    open var needLayout: Bool = true

    open let groupContentInsetY = 20.0
    open let groupContentInsetX = 40.0
    open var bubbleVerticalSpacing: CGFloat = 6.0
    open let bubblePadding: CGFloat = 6;
    open let bubbleMediaPadding: CGFloat = 10;

    // Binded data
    open var peer: ACPeer!
    open weak var controller: AAConversationContentController!
    open var isGroup: Bool = false
    open var isFullSize: Bool!
    open var bindedSetting: AACellSetting?

    open var bindedMessage: ACMessage? = nil
    open var bubbleType:BubbleType? = nil
    open var isOut: Bool = false
    open var isShowDate: Bool = false
    open var isShowNewMessages: Bool = false

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
        dateText.contentMode = UIViewContentMode.center
        dateText.textAlignment = NSTextAlignment.center

        newMessage.font = UIFont.mediumSystemFontOfSize(14)
        newMessage.textColor = appStyle.chatUnreadTextColor
        newMessage.contentMode = UIViewContentMode.center
        newMessage.textAlignment = NSTextAlignment.center
        newMessage.backgroundColor = appStyle.chatUnreadBgColor
        newMessage.text = AALocalized("ChatNewMessages")

        //"New Messages"

        contentView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)

        contentView.addSubview(newMessage)
        contentView.addSubview(dateBg)
        contentView.addSubview(dateText)

        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AABubbleCell.avatarDidTap)))
        avatarView.isUserInteractionEnabled = true

        likeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AABubbleCell.likeDidTap)))
        likeBtn.isUserInteractionEnabled = true

        backgroundColor = UIColor.clear

        // Speed up animations
        self.layer.speed = 1.5

        //self.layer.shouldRasterize = true
        //self.layer.rasterizationScale = UIScreen.mainScreen().scale
        //self.layer.drawsAsynchronously = true
        //self.contentView.layer.drawsAsynchronously = true

        let swipeDetector = UISwipeGestureRecognizer(
            target: self,
            action: #selector(AABubbleCell.contentViewDidSwipe))
        swipeDetector.direction = UISwipeGestureRecognizerDirection.left
        contentView.addGestureRecognizer(swipeDetector)
        contentView.isUserInteractionEnabled = true;
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setConfig(_ peer: ACPeer, controller: AAConversationContentController) {
        self.peer = peer
        self.controller = controller
        if (peer.isGroup && !isFullSize) {
            self.isGroup = true
        }
    }

    open override var canBecomeFirstResponder : Bool {
        return false
    }

    func contentViewDidSwipe() {
        if(!LikersOverlay.shared.isVisible() && bindedMessage != nil) {
            LikersOverlay.shared.showOverlay(contentView.superview!.superview!.superview!, message: bindedMessage!)
        }
    }
//    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(Object.delete(_:)) {
//            return true
//        }
//        return false
//    }

//    open override func delete(_ sender: Any?) {
//        let rids = IOSLongArray(length: 1)
//        rids?.replaceLong(at: 0, withLong: bindedMessage!.rid)
//        Actor.deleteMessages(with: self.peer, withRids: rids)
//    }

    func avatarDidTap() {
        if bindedMessage != nil {
            controller.onBubbleAvatarTap(self.avatarView, uid: bindedMessage!.senderId)
        }
    }

    func likeDidTap() {
        if bindedMessage != nil {
            likeBtn.removeFromSuperview()

            if (bindedMessage!.reactions != nil &&
                bindedMessage!.reactions.size() > 0 &&
                (bindedMessage!.reactions.getWith(0) as AnyObject).getUids() != nil &&
                ((bindedMessage!.reactions.getWith(0) as AnyObject).getUids() as JavaUtilList).contains(withId: Actor.myUid().toNSNumber())) {
                controller.executeHidden(Actor.removeReaction(with: self.peer, withRid: bindedMessage!.rid, withCode: "❤"))
            }
            else {
                controller.executeHidden(Actor.addReaction(with: self.peer, withRid: bindedMessage!.rid, withCode: "❤"))
            }
        }
    }

    open func performBind(_ message: ACMessage, receiveDate: jlong, readDate: jlong, setting: AACellSetting, isShowNewMessages: Bool, layout: AACellLayout) {
        var reuse = false
        if (bindedMessage != nil && bindedMessage?.rid == message.rid && bindedMessage?.reactions?.size() == message.reactions?.size()) {
            reuse = true
        }
        isOut = message.senderId == Actor.myUid();
        backgroundColor = isOut ? AABubbleCell.outBgColor : UIColor.clear
        bindedMessage = message

        if let textContent = message.content as? ACTextContent {
            if textContent.getMentions().contains(withId: Actor.myUid().toNSNumber()) {
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
                    avatarView.bind(name!, id: Int(user.getId()), avatar: avatar)
                } else {
                    let avatar: ACAvatar? = user.getAvatarModel().get()
                    let name = user.getNameModel().get()
                    avatarView.bind(name!, id: Int(user.getId()), avatar: avatar)
                }
                if !avatarAdded {
                    contentView.addSubview(avatarView)
                    avatarAdded = true
                }

                if bindedMessage != nil {
                    let likeCount = UILabel()
                    likeCount.textAlignment = NSTextAlignment.center
                    likeCount.font = AABubbleCell.likeCounterFont
                    likeCount.textColor = AABubbleCell.likeCounterColor
                    likeCount.frame = CGRect(x: 11, y: 14, width: 9, height: 9);
                    likeCount.text = "0"
                    likeBtn.image = AABubbleCell.likeImage

                    if(bindedMessage!.reactions != nil && bindedMessage!.reactions.size() > 0) {
                        let uids = (bindedMessage!.reactions.getWith(0) as AnyObject).getUids() as JavaUtilList;
                        if(uids.contains(withId: Actor.myUid().toNSNumber())) {
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

                contentView.addSubview(likeBtn)
            } else {
                if avatarAdded {
                    avatarView.removeFromSuperview()
                    avatarAdded = false
                }

                likeBtn.removeFromSuperview()
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

    open func bind(_ message: ACMessage, receiveDate: jlong, readDate: jlong, reuse: Bool, cellLayout: AACellLayout, setting: AACellSetting) {
        fatalError("bind(message:) has not been implemented")
    }

    open func bindBubbleType(_ type: BubbleType, isCompact: Bool) {
    }

    func updateView() {
    }

    // MARK: -
    // MARK: Layout

    open override func layoutSubviews() {
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
            dateText.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
            dateText.sizeToFit()
            dateText.frame = CGRect(
                x: (self.contentView.frame.size.width-dateText.frame.width)/2, y: 8, width: dateText.frame.width, height: 18)
            dateBg.frame = CGRect(x: dateText.frame.minX - 8, y: dateText.frame.minY, width: dateText.frame.width + 16, height: 18)

            dateText.isHidden = false
            dateBg.isHidden = false
        } else {
            dateText.isHidden = true
            dateBg.isHidden = true
        }

        if (isShowNewMessages) {
            var top = CGFloat(0)
            if (isShowDate) {
                top += AABubbleCell.dateSize
            }
            newMessage.isHidden = false
            newMessage.frame = CGRect(x: 0, y: top + CGFloat(2), width: self.contentView.frame.width, height: AABubbleCell.newMessageSize - CGFloat(4))
        } else {
            newMessage.isHidden = true
        }
    }

    open func layoutContent(_ maxWidth: CGFloat, offsetX: CGFloat) {

    }

    func layoutAvatar() {
        let avatarSize = CGFloat(36)
        avatarView.frame = CGRect(
            x: 10,
            y: 10 + (isShowDate ? AABubbleCell.dateSize : 0) + (isShowNewMessages ? AABubbleCell.newMessageSize : 0),
            width: avatarSize,
            height: avatarSize)
    }

    func layoutLike() {
        likeBtn.frame = CGRect(
            x: self.contentView.frame.size.width - 26,
            y: 10 + (isShowDate ? AABubbleCell.dateSize : 0) + (isShowNewMessages ? AABubbleCell.newMessageSize : 0),
            width: 18,
            height: 18)
    }

    // Need to be called in child cells
    open func layoutBubble(_ contentWidth: CGFloat, contentHeight: CGFloat) {
    }

    open func layoutBubble(_ frame: CGRect) {
    }

    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}
