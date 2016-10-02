//
//  AuthController.swift
//  Actor
//
//  Created by Michael Schonfeld on 8/25/16.
//  Copyright © 2016 Steve Kite. All rights reserved.
//

import UIKit
import ActorSDK

open class AuthController : AAViewController {
    
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
    
    open override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = ActorSDK.sharedActor().style.welcomeBgColor
        
        self.bgImage.image = ActorSDK.sharedActor().style.welcomeBgImage
        self.bgImage.isHidden = ActorSDK.sharedActor().style.welcomeBgImage == nil
        self.bgImage.contentMode = .scaleAspectFill
        
        self.logoView.image = ActorSDK.sharedActor().style.welcomeLogo
        self.size = ActorSDK.sharedActor().style.welcomeLogoSize
        self.logoViewVerticalGap = ActorSDK.sharedActor().style.logoViewVerticalGap
        
        appNameLabel.text = AALocalized("WelcomeTitle").replace("{app_name}", dest: ActorSDK.sharedActor().appName)
        appNameLabel.textAlignment = .center
        appNameLabel.backgroundColor = UIColor.clear
        appNameLabel.font = UIFont.mediumSystemFontOfSize(24)
        appNameLabel.textColor = ActorSDK.sharedActor().style.welcomeTitleColor
        
        someInfoLabel.text = AALocalized("WelcomeTagline")
        someInfoLabel.textAlignment = .center
        someInfoLabel.backgroundColor = UIColor.clear
        someInfoLabel.font = UIFont.systemFont(ofSize: 16)
        someInfoLabel.numberOfLines = 2
        someInfoLabel.textColor = ActorSDK.sharedActor().style.welcomeTaglineColor
        
        signinButton.setTitle(AALocalized("WelcomeLogIn"), for: .normal)
        signinButton.titleLabel?.font = UIFont.mediumSystemFontOfSize(17)
        signinButton.setTitleColor(ActorSDK.sharedActor().style.welcomeSignupTextColor, for: .normal)
        signinButton.setBackgroundImage(Imaging.roundedImage(ActorSDK.sharedActor().style.welcomeSignupBgColor, radius: 22), for: .normal)
        signinButton.setBackgroundImage(Imaging.roundedImage(ActorSDK.sharedActor().style.welcomeSignupBgColor.alpha(0.7), radius: 22), for: .highlighted)
        signinButton.addTarget(self, action: #selector(AAWelcomeController.signInAction), for: UIControlEvents.touchUpInside)
        
        self.view.addSubview(self.bgImage)
        self.view.addSubview(self.logoView)
        self.view.addSubview(self.appNameLabel)
        self.view.addSubview(self.someInfoLabel)
        self.view.addSubview(self.signinButton)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if AADevice.isiPhone4 {
            logoView.frame = CGRect(x: (view.width - size.width) / 2, y: 90, width: size.width, height: size.height)
            appNameLabel.frame = CGRect(x: (view.width - 300) / 2, y: logoView.bottom + 30, width: 300, height: 29)
            someInfoLabel.frame = CGRect(x: (view.width - 300) / 2, y: appNameLabel.bottom + 8, width: 300, height: 56)
            
            signinButton.frame = CGRect(x: (view.width - 136) / 2, y: view.height - 44 - 25, width: 136, height: 44)
        } else {
            
            logoView.frame = CGRect(x: (view.width - size.width) / 2, y: logoViewVerticalGap, width: size.width, height: size.height)
            appNameLabel.frame = CGRect(x: (view.width - 300) / 2, y: logoView.bottom + 35, width: 300, height: 29)
            someInfoLabel.frame = CGRect(x: (view.width - 300) / 2, y: appNameLabel.bottom + 8, width: 300, height: 56)
            
            signinButton.frame = CGRect(x: (view.width - 136) / 2, y: view.height - 44 - 35, width: 136, height: 44)
        }
        
        self.bgImage.frame = view.bounds
    }
    
    open func signInAction() {
        // TODO: Remove BG after auth?
        UIApplication.shared.keyWindow?.backgroundColor = ActorSDK.sharedActor().style.welcomeBgColor
        self.presentElegantViewController(AAAuthNavigationController(rootViewController: AAAuthLogInViewController()))
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Fix after cancel?
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
}
