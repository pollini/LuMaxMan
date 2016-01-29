//
//  EnemyEscapingState.swift
//  LuMaxMan
//
//  Created by Marius on 19.01.16.
//
//

import SpriteKit
import GameplayKit

class EnemyEscapingState: GKState {
    
    // MARK : Properties
    
    // The connection to the Enemy being in this state.
    unowned var entity: EnemyEntity
    
    // The time the Enemy currently is in this state.
    //var elapsedTime: NSTimeInterval = 0.0
    
    // The MovementComponent associated with the Enemy.
    var movementComponent: MovementComponent {
        guard let movementComponent = entity.componentForClass(MovementComponent.self) else {
            fatalError("An EnemyFollowingState must have a MovementComponent.")
        }
        return movementComponent
    }
    
    
    // MARK: Initializers
    
    required init(entity: EnemyEntity) {
        self.entity = entity
    }
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Reset the elapsed time.
        // elapsedTime = 0.0
        
        //let movementComponent = self.movementComponent
        //movementComponent.nextTranslation = nil
        
        entity.agent.behavior = entity.behaviorForCurrentState
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        //elapsedTime += seconds
        
        // If the Enemy is about to follow LumaxMan, re-enter EnemyFollowingState.
        if entity.isFollowing {
            stateMachine?.enterState(EnemyFollowingState.self)
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is EnemyFollowingState.Type:
            return true
            
        default:
            return false
        }
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        //let movementComponent = self.movementComponent
        //movementComponent.nextTranslation = nil
    }
}