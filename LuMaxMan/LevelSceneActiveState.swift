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
    
    // MARK: Initializers
    
    init(levelScene: LevelScene) {
        self.levelScene = levelScene
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        let success = false
        
        if success {
            // If the goal is met, the player has completed the level.
            stateMachine?.enterState(LevelSceneSuccessState.self)
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
