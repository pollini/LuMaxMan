//
//  AdditionalTimeBehavior.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 29/01/16.
//
//

import GameplayKit

class AdditionalTimeBehavior: ObjectBehavior {
    func contactBeginBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?) {
        guard let objectEntity = entity as? ObjectEntity else { return }
        objectEntity.renderComponent.node.removeFromParent()
        
        guard let lumaxEntity = contactEntity as? LumaxManEntity else { return }
        
        guard let activeState = lumaxEntity.currentLevelScene?.stateMachine.currentState as? LevelSceneActiveState else { return }
        
        activeState.timeRemaining += 10
        
    }
    
    func contactEndBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?) {}
}