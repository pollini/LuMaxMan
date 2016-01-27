/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A state used by `LevelScene` to indicate that the player completed a level successfully.
*/

import SpriteKit
import GameplayKit
import Parse

class LevelSceneSuccessState: LevelSceneOverlayState {
    // MARK: Properties
    
    override var overlaySceneFileName: String {
        return "SuccessScene"
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        if let inputComponent = levelScene.lumaxMan.componentForClass(InputComponent.self) {
            inputComponent.isEnabled = false
        }
        
        guard let user = PFUser.currentUser() else { return }
        
        let highscore = PFObject(className: "Highscore", dictionary: [
            "User": user,
            "Score": levelScene.lumaxMan.collectedCoins
            ])
        
        highscore.saveInBackground()
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return false
    }
}
