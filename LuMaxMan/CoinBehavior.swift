//
//  CoinBehavior.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 26/01/16.
//
//

import GameplayKit

class CoinBehavior: ObjectBehavior {
    func contactBeginBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?) {
        guard let objectEntity = entity as? ObjectEntity else { return }
        objectEntity.renderComponent.node.removeFromParent()
        
        guard let lumaxEntity = contactEntity as? LumaxManEntity else { return }
        lumaxEntity.collectedCoins++
    }
    
    func contactEndBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?) {}
}