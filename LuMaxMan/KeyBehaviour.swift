//
//  KeyBehaviour.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 19/01/16.
//
//

import GameplayKit

class KeyBehaviour: ObjectBehaviour {
    func contactBeginBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?) {
        guard let objectEntity = entity as? ObjectEntity else { return }
        objectEntity.renderComponent.node.hidden = true
        
        guard let lumaxEntity = contactEntity as? LumaxManEntity else { return }
        lumaxEntity.missingKeys--
    }
    
    func contactEndBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?) {}
}