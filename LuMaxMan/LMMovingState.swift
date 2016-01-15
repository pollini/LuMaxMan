//
//  LMMovingState.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 17/12/15.
//
//

import SpriteKit
import GameplayKit

class LMMovingState: GKState {
    // MARK: Properties
    
    unowned var entity: LumaxManEntity
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.componentForClass(AnimationComponent.self) else { fatalError("A PlayerBotPlayerControlledState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `MovementComponent` associated with the `entity`.
    var movementComponent: MovementComponent {
        guard let movementComponent = entity.componentForClass(MovementComponent.self) else { fatalError("A PlayerBotPlayerControlledState's entity must have a MovementComponent.") }
        return movementComponent
    }
    
    /// The `InputComponent` associated with the `entity`.
    var inputComponent: InputComponent {
        guard let inputComponent = entity.componentForClass(InputComponent.self) else { fatalError("A PlayerBotPlayerControlledState's entity must have an InputComponent.") }
        return inputComponent
    }
    
    // MARK: Initializers
    
    required init(entity: LumaxManEntity) {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Turn on controller input for the `PlayerBot` when entering the player-controlled state.
        inputComponent.isEnabled = true
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        /*
        Assume an animation of "idle" that can then be overwritten by the movement
        component in response to user input.
        */
        animationComponent.requestedAnimationState = .Idle
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is LMHitState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        // Turn off controller input for the `PlayerBot` when leaving the player-controlled state.
        entity.componentForClass(InputComponent.self)?.isEnabled = false
        
        // `movementComponent` is a computed property. Declare a local version so we don't compute it multiple times.
        let movementComponent = self.movementComponent
        
        // Cancel any planned movement or rotation when leaving the player-controlled state.
        movementComponent.nextTranslation = nil
    }
}