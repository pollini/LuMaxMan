/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A state used by `LevelScene` to indicate that the player failed to complete a level.
*/

import SpriteKit
import GameplayKit

class LevelSceneFailState: LevelSceneOverlayState {
    // MARK: Properties
    
    override var overlaySceneFileName: String {
        return "FailScene"
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        levelScene.uniNode.paused = true
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return false
    }
}
