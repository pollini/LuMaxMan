//
//  AppDelegate.swift
//  LuMaxMan
//
//  Created by Marius on 09.12.15.
//
//

import UIKit
import GameKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController : GameViewController?
    
    internal private(set) var currentPlayerID: String?
    
    // isGameCenterAuthenticationComplete is set after authentication, and authenticateWithCompletionHandler's completionHandler block has been run. It is unset when the application is backgrounded.
    internal private(set) var isGameCenterAuthenticationComplete: Bool?
    //internal private(set) var isGameCenterAuthenticationComplete: Bool?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
/*
*** GAME CENTER STUFF
        self.mainViewController = self.window?.rootViewController as? GameViewController
        
        // Enable Game Center functionality.
        self.isGameCenterAuthenticationComplete = false
        
        if !isGameCenterAPIAvailable() {
            // Game Center is not available.
        
        } else {
            
            let localPlayer : GKLocalPlayer = GKLocalPlayer.localPlayer()
            
            localPlayer.authenticateHandler = {(viewController, error) -> Void in
                
                if viewController != nil {
                    self.mainViewController?.presentViewController(viewController!, animated: true, completion: nil)
                
                } else {
                    if localPlayer.authenticated {
                        self.isGameCenterAuthenticationComplete = true
                        
                        // Player Ids have switched.
                        if self.currentPlayerID != localPlayer.playerID {
                        }
                    } else {
                        // login view controller or something
                    }
                }
            }
        }
*/
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
/*
*** GAME CENTER STUFF
        Invalidate Game Center Authentication and save game state, so the game doesn't start until the Authentication Completion Handler is run. This prevents a new user from using the old users game state.
        self.isGameCenterAuthenticationComplete = false
        self.mainViewController!.enableGameCenter(false)
*/
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // Preferred method for testing for GameKit/Game Center.
    func isGameCenterAPIAvailable() -> Bool {
        
        // Check for presence of GKLocalPlayer API.
        if let _ : AnyClass = (NSClassFromString("GKLocalPlayer"))! {
            let reqSysVer : String = "4.1"
            let currSysVer : String = UIDevice.currentDevice().systemVersion
            
            // The device must be running running iOS 4.1 or later.
            let osVersionSupported : Bool = currSysVer.compare(reqSysVer, options:NSStringCompareOptions.NumericSearch, range: nil, locale: nil) != NSComparisonResult.OrderedAscending
            
            return osVersionSupported
        }
        
        return false;
    }
}

