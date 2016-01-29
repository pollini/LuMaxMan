//
//  LMHitState.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 17/12/15.
//
//

import SpriteKit
import GameplayKit

class LMHitState: GKState {
    // MARK: Properties
    
    unowned var entity: LumaxManEntity
    
    /// The amount of time the entity has been in the "hit" state.
    var elapsedTime: NSTimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.componentForClass(AnimationComponent.self) else { fatalError("A LMHitState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    // MARK: Initializers
    
    required init(entity: LumaxManEntity) {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Reset the elapsed "hit" duration on entering this state.
        elapsedTime = 0.0
        
        //Remove one life
        entity.remainingLives--
        
        
        // Request the "hit" animation
        animationComponent.requestedAnimationState = .Hit
    }
    
    override func willExitWithNextState(nextState: GKState) {
        //Respawn player at original point
        if let spawnPosition = entity.currentLevelScene?.spawnPosition where nextState is LMMovingState {
            entity.movementComponent?.moveToPoint(spawnPosition)
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        // Update the amount of time the `PlayerBot` has been in the "hit" state.
        elapsedTime += seconds
        
        // When the entity has been in this state for long enough, transition to the appropriate next state.
        if elapsedTime >= GameplayConfiguration.LumaxMan.hitStateDuration {
            stateMachine?.enterState(LMMovingState.self)
        }
    }
}