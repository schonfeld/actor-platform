//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation
import UIKit
import MessageUI
import ActorSDK

public class RootController : AARootTabViewController {
    public override init() {
        super.init()
        self.viewControllers = self.getMainNavigations()
        self.selectedIndex = 1
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.hidePlaceholders()
    }
    
    private func getMainNavigations() -> [AANavigationController] {
        let allControllers = ActorSDK.sharedActor().delegate.actorRootControllers()
        
        if let all = allControllers {
            
            var mainNavigations = [AANavigationController]()
            
            for controller in all {
                mainNavigations.append(AANavigationController(rootViewController: controller))
            }
            
            return mainNavigations
        } else {
            
            var mainNavigations = [AANavigationController]()
            
            ////////////////////////////////////
            // Contacts
            ////////////////////////////////////
            
            if let contactsController = ActorSDK.sharedActor().delegate.actorControllerForContacts() {
                mainNavigations.append(AANavigationController(rootViewController: contactsController))
            } else {
                mainNavigations.append(AANavigationController(rootViewController: AAContactsViewController()))
            }
            
            ////////////////////////////////////
            // Recent dialogs
            ////////////////////////////////////
            
            if let recentDialogs = ActorSDK.sharedActor().delegate.actorControllerForDialogs() {
                mainNavigations.append(AANavigationController(rootViewController: recentDialogs))
            } else {
                mainNavigations.append(AANavigationController(rootViewController: AARecentViewController()))
            }
            
            ////////////////////////////////////
            // Settings
            ////////////////////////////////////
            
            if let settingsController = ActorSDK.sharedActor().delegate.actorControllerForSettings() {
                mainNavigations.append(AANavigationController(rootViewController: settingsController))
            } else {
                mainNavigations.append(AANavigationController(rootViewController: AASettingsViewController()))
            }
            
            
            return mainNavigations
        }
    }
}