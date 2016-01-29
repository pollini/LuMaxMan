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
    
    // MARK: Properties
    
    // The animations to use for an enemy.
    static var animations: [AnimationState: [Direction: Animation]]?
    
    // The size to use for the enemy's animation textures.
    static var textureSize = CGSize(width: 40.0, height: 40.0)
    
    static var texturesLoaded: Bool = false
    
    // The time an enemy has to wait at the beginning of a game.
    var waitingTime: Double
    
    // The time an enemy updates his path to LumaxMan.
    var updatingTime: Double
    
    // The GKAgent associated with this enemy.
    var agent: EnemyAgent {
        guard let agent = componentForClass(EnemyAgent.self) else { fatalError("An enemy entity must have a GKAgent2D component.") }
        return agent
    }
    
    // Indicates the current "state" of an enemy - following/hunting LuMaxMan, or escaping from him.
    var isFollowing: Bool {
        didSet {
            // Do nothing if the value has not changed.
            guard isFollowing != oldValue else { return }
            
            guard let intelligenceComponent = componentForClass(IntelligenceComponent.self) else { fatalError("An Enemy must have an IntelligenceComponent") }
            
            if isFollowing {
                // Set and use values for following/hunting LuMaxMan.
                
                intelligenceComponent.stateMachine.enterState(EnemyFollowingState.self)
                agent.maxSpeed = GameplayConfiguration.Enemy.movementSpeedWhenFollowing
                
            } else {
                // Set and use values for escaping from LuMaxMan.
                
                intelligenceComponent.stateMachine.enterState(EnemyEscapingState.self)
                agent.maxSpeed = GameplayConfiguration.Enemy.movementSpeedWhenEscaping
            }
        }
    }
    
    // The RenderComponent associated with this enemy.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("An Enemy must have a RenderComponent.") }
        return renderComponent
    }
    
    // PREVIOUS --- The position in the scene that an enemy should move towards to.
    var targetPosition: float2?
    
    // Returns the behavior for an enemy respective to its current state.
    var behaviorForCurrentState: GKBehavior {
        // Check if enemy is in a level - if not return an empty behavior. Crashed here sometimes otherwise.
        guard let levelScene = componentForClass(RenderComponent.self)?.node.scene as? LevelScene else {
            return GKBehavior()
        }
        
        let agentBehavior: GKBehavior
        
        if isFollowing {
            let myInt = levelScene.enemies.indexOf(self)! as Int
            agentBehavior = EnemyBehavior.behaviorForAgent(agent, followingAgent: (levelScene.levelKeys.objectAtIndex(myInt) as! ObjectEntity).agent, avoidingAgents: levelScene.enemies.map({ $0.agent }), inScene: levelScene)
        
        } else {
            agentBehavior = EnemyBehavior.behaviorForAgent(agent, escapingFromAgent: levelScene.lumaxMan.agent, inScene: levelScene)
        }
        
        return agentBehavior
    }
    
    // MARK: Initializers
    
    required init(isFollowing: Bool, waitingTime: Double, updatingTime: Double) {
        self.isFollowing = isFollowing
        self.waitingTime = waitingTime
        self.updatingTime = updatingTime
        
        super.init()
        
        // Create an EnemyAgent to represent this Enemy in the physics system.
        let agent = EnemyAgent()
        agent.delegate = self
        
        // Some basic configuration for the EnemyAgent.
        agent.maxSpeed = isFollowing ? GameplayConfiguration.Enemy.movementSpeedWhenFollowing : GameplayConfiguration.Enemy.movementSpeedWhenEscaping
        agent.maxAcceleration = isFollowing ? GameplayConfiguration.Enemy.movementSpeedWhenFollowing : GameplayConfiguration.Enemy.movementSpeedWhenEscaping
        agent.radius = Float(GameplayConfiguration.Enemy.physicsBodyRadius)
        agent.mass = 0.5
        agent.behavior = GKBehavior()
        
        // GKAgent2D is subclass of GKComponent. So, adding the agent as a subclass means it will be updated during the component update cycle. Nice!
        addComponent(agent)
        
        // Create components that define how the entity looks and behaves.
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let physicsBody = SKPhysicsBody(circleOfRadius: GameplayConfiguration.Enemy.physicsBodyRadius, center: CGPoint(x: 0, y: 0))
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Enemy)
        addComponent(physicsComponent)
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // Connect the PhysicsComponent and the RenderComponent.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // AnimationComponent tracks and vends the animations for different entity states and directions.
        guard let animations = EnemyEntity.animations else {
            fatalError("Attempt to access Enemy.animations before they have been loaded.")
        }
        let animationComponent = AnimationComponent(textureSize: EnemyEntity.textureSize, animations: animations)
        animationComponent.requestedAnimationState = .Idle
        addComponent(animationComponent)
        
        // Connect the RenderComponent to the AnimationComponent.
        renderComponent.node.addChild(animationComponent.node)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            EnemyEscapingState(entity: self),
            EnemyFollowingState(entity: self)
            ])
        addComponent(intelligenceComponent)
    }
    
    
    // MARK: ContactNotifiableType
    
    func contactWithEntityDidBegin(entity: GKEntity?) {
        guard let lumaxMan = entity as? LumaxManEntity else { return }
        
        lumaxMan.intelligenceComponent?.stateMachine.enterState(LMHitState)
    }
    
    func contactWithEntityDidEnd(entity: GKEntity?) {
    }
    
    
    // MARK: GKAgentDelegate
    
    func agentWillUpdate(agent: GKAgent) {
        // GKAgents do not "exist" in the SpriteKit physics world, so we have to adjust their positions "manually".
        updateAgentPositionToMatchNodePosition()
        
    }
    
    func agentDidUpdate(agent: GKAgent) {
        
        updateNodePositionToMatchAgentPosition()
        
        agent.behavior = behaviorForCurrentState
    }
    
    
    func updateAgentPositionToMatchNodePosition() {
        let renderComponent = self.renderComponent
        
        agent.position = float2(x: Float(renderComponent.node.position.x), y: Float(renderComponent.node.position.y))
    }
    
    func updateNodePositionToMatchAgentPosition() {
        let agentPosition = CGPoint(agent.position)
        
        renderComponent.node.position = agentPosition
    }
    
    
    // MARK: load assets
    
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
            
            animations = [:]
            animations![.Idle] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "EnemyHunting", forAnimationState: .Idle)
            animations![.Moving] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "EnemyHunting", forAnimationState: .Moving)
            animations![.Hit] = AnimationComponent.animationsFromAtlas(atlases[0], withImageIdentifier: "EnemyEscaping", forAnimationState: .Hit, repeatTexturesForever: false)
            
            EnemyEntity.texturesLoaded = true
        }
    }
    
}
