//
//  LevelScene+Pause.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract:
//  An extension on `LevelScene` which ensures that game play is paused when the app enters the background for a number of user initiated events.

import UIKit

extension LevelScene {
    // MARK: Properties
    
    /**
    The scene's `paused` property is set automatically when the
    app enters the background. Override to check if an `overlay` node is
    being presented to determine if the game should be paused.
    */
    override var paused: Bool {
        didSet {
            if overlay != nil {
                uniNode.paused = true
            }
        }
    }
    
    // MARK: Convenience
    
    /**
    Register for notifications about the app becoming inactive in
    order to pause the game.
    */
    func registerForPauseNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pauseGame", name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    func pauseGame() {
        stateMachine.enterState(LevelScenePauseState.self)
    }
    
    func unregisterForPauseNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
    }
}