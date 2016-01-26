//
//  EnemyEntity.swift
//  LuMaxMan
//
//  Created by Marius on 13.01.16.
//
//

import SpriteKit
import GameplayKit

class EnemyEntity: GKEntity, ContactNotifiableType, GKAgentDelegate {
    
    // MARK: Nested types
    
/*
    enum EnemyBehiavour {
        // Follow/hunt LumaxMan.
        case FollowAgent(GKAgent2D)
        
        // Escape from LumaxMan.
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
    static var textureSize = CGSize(width: 60.0, height: 60.0)
    
    static var texturesLoaded: Bool = false
    
    // The location to use for the enemy's starting point.
    //var spawnLocation: float2?
    
    // The time an enemy has to wait inside the "box" where enemies are supposed to spawn at the beginning of a game.
    var waitingTime: Float
    
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
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("An Enemy must have an RenderComponent.") }
        return renderComponent
    }
    
    
    // MARK: Initializers
    
    required init(spawnLocation: float2, isFollowing: Bool, waitingTime: Float) {
        //self.spawnLocation = spawnLocation
        self.isFollowing = isFollowing
        self.waitingTime = waitingTime
        
        super.init()
        
        // Create components that define how the entity looks and behaves.
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Enemy.physicsBodyRadius, center: CGPointMake(0, 0))
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Enemy)
        addComponent(physicsComponent)
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // Connect the PhysicsComponent and the RenderComponent.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // `AnimationComponent` tracks and vends the animations for different entity states and directions.
        guard let animations = EnemyEntity.animations else {
            fatalError("Attempt to access LumaxMan.animations before they have been loaded.")
        }
        let animationComponent = AnimationComponent(textureSize: EnemyEntity.textureSize, animations: animations)
        animationComponent.requestedAnimationState = .Idle
        addComponent(animationComponent)
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            EnemyEscapingState(entity: self),
            EnemyFollowingState(entity: self)
            ])
        addComponent(intelligenceComponent)
    }
    
    // MARK: ContactNotifiableType
    
    func contactWithEntityDidBegin(entity: GKEntity?) {
        
    }
    
    func contactWithEntityDidEnd(entity: GKEntity?) {
    }
    
    
    // MARK: 
    
    static func loadResources() {
        
        let enemyAtlasNames = [
            "EnemyEscaping",
            "EnemyHunting"
        ]
        
        /*
        Preload all of the texture atlases for an Enemy. This improves
        the overall loading speed of the animation cycles for this character.
        */
        SKTextureAtlas.preloadTextureAtlasesNamed(enemyAtlasNames) { error, atlases in
            if let error = error {
                fatalError("One or more texture atlases could not be found: \(error)")
            }
            
            /*
            This closure sets up all of the `GroundBot` animations
            after the `GroundBot` texture atlases have finished preloading.
            */
            
            animations = [:]
            animations![.Idle] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "EnemyHunting", forAnimationState: .Idle)
            animations![.Moving] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "EnemyHunting", forAnimationState: .Moving)
            animations![.Hit] = AnimationComponent.animationsFromAtlas(atlases[0], withImageIdentifier: "EnemyEscaping", forAnimationState: .Hit, repeatTexturesForever: false)
            
            EnemyEntity.texturesLoaded = true
        }
    }

}
