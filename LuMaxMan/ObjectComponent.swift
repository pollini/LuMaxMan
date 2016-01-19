//
//  ObjectComponent.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 19/01/16.
//
//

import SpriteKit
import GameplayKit

class ObjectComponent: GKComponent {
    // MARK: Properties
    
    // The `RenderComponent` vends a node allowing an entity to be rendered in a scene.
    let behaviour : ObjectBehaviour
    
    init(withCollissionBehaviour behaviour: ObjectBehaviour) {
        self.behaviour = behaviour
    }
    
    func contactWithEntityDidBegin(contactEntity: GKEntity?) {
        behaviour.contactBeginBetweenEntity(entity!, andEntity: contactEntity)
    }
    
    func contactWithEntityDidEnd(contactEntity: GKEntity?) {
        behaviour.contactEndBetweenEntity(entity!, andEntity: contactEntity)
    }
}

protocol ObjectBehaviour {
    func contactBeginBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?)
    
    func contactEndBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?)
}