//
//  AuthController.swift
//  Actor
//
//  Created by Michael Schonfeld on 8/25/16.
//  Copyright © 2016 Steve Kite. All rights reserved.
//

import UIKit
import ActorSDK

public class AuthController : AAViewController {
    
    let bgImage: UIImageView            = UIImageView()
    let logoView: UIImageView           = UIImageView()
    let appNameLabel: UILabel           = UILabel()
    let someInfoLabel: UILabel          = UILabel()
    let signinButton: UIButton          = UIButton()
    var size: CGSize                    = CGSize()
    var logoViewVerticalGap: CGFloat    = CGFloat()
    
    public override init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = ActorSDK.sharedActor().style.welcomeBgColor
        
        self.bgImage.image = ActorSDK.sharedActor().style.welcomeBgImage
        self.bgImage.hidden = ActorSDK.sharedActor().style.welcomeBgImage == nil
        self.bgImage.contentMode = .ScaleAspectFill
        
        self.logoView.image = ActorSDK.sharedActor().style.welcomeLogo
        self.size = ActorSDK.sharedActor().style.welcomeLogoSize
        self.logoViewVerticalGap = ActorSDK.sharedActor().style.logoViewVerticalGap
        
        appNameLabel.text = AALocalized("WelcomeTitle").replace("{app_name}", dest: ActorSDK.sharedActor().appName)
        appNameLabel.textAlignment = .Center
        appNameLabel.backgroundColor = UIColor.clearColor()
        appNameLabel.font = UIFont.mediumSystemFontOfSize(24)
        appNameLabel.textColor = ActorSDK.sharedActor().style.welcomeTitleColor
        
        someInfoLabel.text = AALocalized("WelcomeTagline")
        someInfoLabel.textAlignment = .Center
        someInfoLabel.backgroundColor = UIColor.clearColor()
        someInfoLabel.font = UIFont.systemFontOfSize(16)
        someInfoLabel.numberOfLines = 2
        someInfoLabel.textColor = ActorSDK.sharedActor().style.welcomeTaglineColor
        
        signinButton.setTitle(AALocalized("WelcomeLogIn"), forState: .Normal)
        signinButton.titleLabel?.font = UIFont.mediumSystemFontOfSize(17)
        signinButton.setTitleColor(ActorSDK.sharedActor().style.welcomeSignupTextColor, forState: .Normal)
        signinButton.setBackgroundImage(Imaging.roundedImage(ActorSDK.sharedActor().style.welcomeSignupBgColor, radius: 22), forState: .Normal)
        signinButton.setBackgroundImage(Imaging.roundedImage(ActorSDK.sharedActor().style.welcomeSignupBgColor.alpha(0.7), radius: 22), forState: .Highlighted)
        signinButton.addTarget(self, action: #selector(AAWelcomeController.signInAction), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(self.bgImage)
        self.view.addSubview(self.logoView)
        self.view.addSubview(self.appNameLabel)
        self.view.addSubview(self.someInfoLabel)
        self.view.addSubview(self.signinButton)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if AADevice.isiPhone4 {
            logoView.frame = CGRectMake((view.width - size.width) / 2, 90, size.width, size.height)
            appNameLabel.frame = CGRectMake((view.width - 300) / 2, logoView.bottom + 30, 300, 29)
            someInfoLabel.frame = CGRectMake((view.width - 300) / 2, appNameLabel.bottom + 8, 300, 56)
            
            signinButton.frame = CGRectMake((view.width - 136) / 2, view.height - 44 - 25, 136, 44)
        } else {
            
            logoView.frame = CGRectMake((view.width - size.width) / 2, logoViewVerticalGap, size.width, size.height)
            appNameLabel.frame = CGRectMake((view.width - 300) / 2, logoView.bottom + 35, 300, 29)
            someInfoLabel.frame = CGRectMake((view.width - 300) / 2, appNameLabel.bottom + 8, 300, 56)
            
            signinButton.frame = CGRectMake((view.width - 136) / 2, view.height - 44 - 35, 136, 44)
        }
        
        self.bgImage.frame = view.bounds
    }
    
    public func signInAction() {
        // TODO: Remove BG after auth?
        UIApplication.sharedApplication().keyWindow?.backgroundColor = ActorSDK.sharedActor().style.welcomeBgColor
        self.presentElegantViewController(AAAuthNavigationController(rootViewController: AAAuthLogInViewController()))
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Fix after cancel?
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
}
