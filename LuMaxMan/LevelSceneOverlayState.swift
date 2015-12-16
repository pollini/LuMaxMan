/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The base class for a `LevelScene`'s Pause, Fail, and Success states. Handles the task of loading and displaying a full-screen overlay from a scene file when the state is entered.
*/

import SpriteKit
import GameplayKit

class LevelSceneOverlayState: GKState {
    // MARK: Properties
    
    unowned let levelScene: LevelScene
    
    /// The `SceneOverlay` to display when the state is entered.
    var overlay: SceneOverlay!
    
    /// Overridden by subclasses to provide the name of the .sks file to load to show as an overlay.
    var overlaySceneFileName: String { fatalError("Unimplemented overlaySceneName") }
    
    // MARK: Initializers
    
    init(levelScene: LevelScene) {
        self.levelScene = levelScene
        
        super.init()
        
        overlay = SceneOverlay(overlaySceneFileName: overlaySceneFileName, zPosition: UniLayer.Top.rawValue)
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Provide the levelScene with a reference to the overlay node.
        levelScene.overlay = overlay
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        levelScene.overlay = nil
    }
}