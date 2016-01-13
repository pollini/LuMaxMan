//
//  MenuScene.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//

class MenuScene: BaseScene {
    
    /// The "NEW GAME" button which allows the player to proceed to the first level.
    var proceedButton: ButtonNode? {
        return childNodeWithName(ButtonIdentifier.ProceedToNextScene.rawValue) as? ButtonNode
    }
}