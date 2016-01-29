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
    
    // The current times of the Enemy in this state.
    var waitingTime: Double
    var updatingTime: Double
    var currentTime: Double
    
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
        self.waitingTime = Double(entity.waitingTime)
        self.updatingTime = Double(entity.updatingTime)
        self.currentTime = Double(entity.updatingTime)
    }
    
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Reset the elapsed time.
        // elapsedTime = 0.0
        currentTime = updatingTime
        
        //let movementComponent = self.movementComponent
        //movementComponent.nextTranslation = nil
        
        entity.agent.behavior = entity.behaviorForCurrentState
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        //elapsedTime += seconds
        currentTime -= seconds
        
        // If the Enemy is about to get followed, re-enter EnemyEscapingState.
        if !entity.isFollowing {
            stateMachine?.enterState(EnemyEscapingState.self)
        
        } else {
            if currentTime <= 0.0 {
                currentTime = updatingTime
                NSLog("setting behavior, currentTime: \(currentTime)")
                entity.agent.behavior = entity.behaviorForCurrentState
            }
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
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        // Assing an empty behavior to cancel any active agent control when leaving this state.
        entity.agent.behavior = GKBehavior()
    }
}
