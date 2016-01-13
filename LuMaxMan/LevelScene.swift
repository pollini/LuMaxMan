//
//  LevelScene.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//

import SpriteKit
import GameplayKit

class LevelScene: BaseScene {
    
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    var upSwipe: UISwipeGestureRecognizer!
    var downSwipe: UISwipeGestureRecognizer!
    
    
    override func didMoveToView(view: SKView) {
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            print("Swipe Left")
            
        
        }
        
        if (sender.direction == .Right) {
            print("Swipe Right")
            
            
        }
        
        if (sender.direction == .Up) {
            print("Swipe Up")
            

        }
        
        if (sender.direction == .Down) {
            print("Swipe Down")
            

        }
    }

    
}