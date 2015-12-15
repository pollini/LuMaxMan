//
//  EntityNode.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract:
//  A simple `SKNode` subclass that stores a `weak` reference to an associated `GKEntity`. Provides a way to discover the entity associated with a node.
//

import SpriteKit
import GameplayKit

class EntityNode: SKNode {
    // MARK: Properties
    
    weak var entity: GKEntity!
}
