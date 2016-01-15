/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A state used by `LevelScene` to indicate that the game is actively being played. This state updates the current time of the level's countdown timer.
*/

import SpriteKit
import GameplayKit

class LevelSceneActiveState: GKState {
    // MARK: Properties
    
    unowned let levelScene: LevelScene
    
    var timeRemaining: NSTimeInterval = 0.0
    
    /*
    A formatter for individual date components used to provide an appropriate
    display value for the timer.
    */
    let timeRemainingFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.zeroFormattingBehavior = .Pad
        formatter.allowedUnits = [.Minute, .Second]
        
        return formatter
    }()
    
    // The formatted string representing the time remaining.
    var timeRemainingString: String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, timeRemaining))
        
        return timeRemainingFormatter.stringFromDateComponents(components)!
    }
    
    // MARK: Initializers
    
    init(levelScene: LevelScene) {
        self.levelScene = levelScene
        
        timeRemaining = levelScene.levelConfiguration.timeLimit
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        timeRemaining -= seconds
        
        // Update the displayed time remaining.
        levelScene.timerNode.text = timeRemainingString
        
        if timeRemaining <= 0 {
            // If the goal is met, the player has completed the level.
            stateMachine?.enterState(LevelSceneFailState.self)
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LevelScenePauseState.Type, is LevelSceneFailState.Type, is LevelSceneSuccessState.Type:
            return true
            
        default:
            return false
        }
    }
}
