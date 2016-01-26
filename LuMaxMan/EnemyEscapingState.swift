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
    
    unowned var entity: EnemyEntity
    
    
    // MARK: Initializers
    
    required init(entity: EnemyEntity) {
        self.entity = entity
    }
    
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is EnemyFollowingState.Type:
            return true
            
        default:
            return false
        }
    }
}