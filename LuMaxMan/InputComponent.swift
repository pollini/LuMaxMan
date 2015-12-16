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
    // MARK: Types
    
    struct InputState {
        var translation: MovementKind?
        var rotation: MovementKind?
        
        static let noInput = InputState()
    }
    
    // MARK: Properties
    
    /**
    `InputComponent` has the ability to ignore input when disabled.
    
    This is used to prevent the player from moving or firing while
    being attacked.
    */
    var isEnabled = true {
        didSet {
            if isEnabled {
                // Apply the current input state to the movement and beam components.
                applyInputState(state)
            }
            else {
                // Apply a state of no input to the movement and beam components.
                applyInputState(InputState.noInput)
            }
        }
    }
    
    var state = InputState() {
        didSet {
            if isEnabled {
                applyInputState(state)
            }
        }
    }
    
    // MARK: ControlInputSourceDelegate
    
    func controlInputSource(controlInputSource: ControlInputSourceType, didUpdateDisplacement displacement: float2) {
        state.translation = MovementKind(displacement: displacement)
    }
    
    func controlInputSource(controlInputSource: ControlInputSourceType, didUpdateAngularDisplacement angularDisplacement: float2) {
        state.rotation = MovementKind(displacement: angularDisplacement)
    }
    
    func controlInputSource(controlInputSource: ControlInputSourceType, didUpdateWithRelativeDisplacement relativeDisplacement: float2) {
        /*
        Create a `MovementKind` instance indicating whether the displacement
        should translate the entity forwards or backwards from the direction
        it is facing.
        */
        state.translation = MovementKind(displacement: relativeDisplacement, relativeToOrientation: true)
    }
    
    func controlInputSource(controlInputSource: ControlInputSourceType, didUpdateWithRelativeAngularDisplacement relativeAngularDisplacement: float2) {
        /*
        Create a `MovementKind` instance indicating whether the displacement
        should rotate the entity clockwise or counter-clockwise from the direction
        it is facing.
        */
        state.rotation = MovementKind(displacement: relativeAngularDisplacement, relativeToOrientation: true)
    }
    
    // MARK: Convenience
    
    func applyInputState(state: InputState) {
        if let movementComponent = entity?.componentForClass(MovementComponent.self) {
            movementComponent.nextRotation = state.rotation
            movementComponent.nextTranslation = state.translation
        }
    }
}