//
//  EnemyFollowingState.swift
//  LuMaxMan
//
//  Created by Marius on 19.01.16.
//
//

import SpriteKit
import GameplayKit

class EnemyFollowingState: GKState {
    
    // MARK: Properties
    
    // The connection to the Enemy being in this state.
    unowned var entity: EnemyEntity
    
    // The time the Enemy currently is in this state.
    //var elapsedTime: NSTimeInterval = 0.0
    
    
    // MARK: Initializers
    
    required init(entity: EnemyEntity) {
        self.entity = entity
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Reset the elapsed time.
        // elapsedTime = 0.0
        
        // Check if the Enemy has a movement component.
        if let movementComponent = entity.componentForClass(MovementComponent.self) {
            // Clear any pending movement.
            movementComponent.nextTranslation = nil
            
        }
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        //elapsedTime += seconds
        
        /*
        If the Enemy is about to get followed, re-enter EnemyEscapingState.
        */
        //if entity.isFollowing || elapsedTime >= GameplayConfiguration.TaskBot.zappedStateDuration {
        if !entity.isFollowing {
            stateMachine?.enterState(EnemyEscapingState.self)
        }
    }
    
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is EnemyEscapingState.Type:
            return true
            
        default:
            return false
        }
    }
}
