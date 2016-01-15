//
//  EnemyEntity.swift
//  LuMaxMan
//
//  Created by Marius on 13.01.16.
//
//

import SpriteKit
import GameplayKit

class EnemyEntity: GKEntity {
    
    // MARK: Nested types
    
/*
    enum EnemyBehiavour {
        // Follow/hunt LuMaxMan.
        case FollowAgent(GKAgent2D)
        
        // Escape from LuMaxMan.
        case EscapeAgent(GKAgent2D)
    }
    
    // The `GKAgent` associated with this enemy.
    var agent: EnemyAgent {
    guard let agent = componentForClass(EnemyAgent.self) else { fatalError("An enemy entity must have a GKAgent2D component.") }
        return agent
    }
*/
    
    // MARK: Properties
    
    
    // The animations to use for an enemy.
    static var animations: [AnimationState: [Direction: Animation]]?
    
    // The size to use for the enemy's animation textures.
    static var textureSize = CGSize(width: 120.0, height: 120.0)
    
    // The location to use for the enemy's starting point.
    var spawnLocation: float2?
    
    // Indicates the current "state" of an enemy - following/hunting LuMaxMan, or escaping from him.
    var isFollowing: Bool {
        didSet {
            // Do nothing if the value has not changed.
            guard isFollowing != oldValue else { return }
            
            if isFollowing {
                // TO DO: Set and use values for following/hunting LuMaxMan.
                
            } else {
                // TO DO: Set and use values for escaping from LuMaxMan.
            }
        }
    }
    
    // The `RenderComponent` associated with this enemy.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A TaskBot must have an RenderComponent.") }
        return renderComponent
    }
    
    
    // MARK: Initializers
    
    required init(spawnLocation: float2, isFollowing: Bool) {
        self.spawnLocation = spawnLocation
        self.isFollowing = isFollowing
        
        super.init()
    }

}
