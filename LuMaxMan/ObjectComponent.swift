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
    let behavior : ObjectBehavior
    
    init(withCollissionBehavior behavior: ObjectBehavior) {
        self.behavior = behavior
    }
    
    func contactWithEntityDidBegin(contactEntity: GKEntity?) {
        behavior.contactBeginBetweenEntity(entity!, andEntity: contactEntity)
    }
    
    func contactWithEntityDidEnd(contactEntity: GKEntity?) {
        behavior.contactEndBetweenEntity(entity!, andEntity: contactEntity)
    }
}

protocol ObjectBehavior {
    func contactBeginBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?)
    
    func contactEndBetweenEntity(entity: GKEntity, andEntity contactEntity: GKEntity?)
}