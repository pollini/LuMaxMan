//
//  InputComponent.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//


import SpriteKit
import GameplayKit

class InputComponent: GKComponent, ControlInputSourceDelegate {
    // MARK: Properties
    var translation: MovementKind? {
        didSet {
            applyTranslation(translation)
        }
    }
    
    var isEnabled = true {
        didSet {
            if isEnabled {
                // Apply the current input state to the movement and beam components.
                applyTranslation(translation)
            }
            else {
                // Apply a state of no input to the movement and beam components.
                applyTranslation(nil)
            }
        }
    }
    
    // MARK: ControlInputSourceDelegate
    
    func updateDisplacement(displacement: float2) {
        translation = MovementKind(displacement: displacement)
    }
    
    func applyTranslation(translation: MovementKind?) {
        if let movementComponent = entity?.componentForClass(MovementComponent.self) {
            movementComponent.nextTranslation = translation
        }
    }
}