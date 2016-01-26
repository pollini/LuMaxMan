//
//  GameViewController.swift
//  LuMaxMan
//
//  Created by Marius on 09.12.15.
//  Copyright (c) 2015 LuMaxMan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SceneManagerDelegate {
    
    /// A manager for coordinating scene resources and presentation.
    var sceneManager: SceneManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadResources()
        
        if !EnemyEntity.texturesLoaded {
            EnemyEntity.loadResources()
        }
        
        // Load the initial home scene.
        let skView = view as! SKView
        sceneManager = SceneManager(presentingView: skView)
        sceneManager.delegate = self
        
        sceneManager.transitionToSceneWithSceneIdentifier(.Home)
        
    }
    
    // Permanently hide the status bar.
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: SceneManagerDelegate
    
    func sceneManagerDidTransitionToScene(scene: SKScene) {
        
        // Fade out the app's initial loading `logoView` if it is visible.
        /*UIView.animateWithDuration(0.2, delay: 0.0, options: [], animations: {
        self.logoView.alpha = 0.0
        }, completion: { _ in
        self.logoView.hidden = true
        })*/
    }
    
    
    // Disable Game Center functionality.
    func enableGameCenter(enableGameCenter: Bool) {
        // Disable respective UI elements or present a suitable (error) message.
    }
}
