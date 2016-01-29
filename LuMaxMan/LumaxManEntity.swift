//
//  LumaxManEntity.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//

import GameplayKit
import SpriteKit

class LumaxManEntity: GKEntity, ContactNotifiableType {
    
    /// The animations to use for LumaxMan.
    static var animations: [AnimationState: [Direction: Animation]]?
    
    /// The size to use for LumaxMan's animation textures.
    static var textureSize = CGSize(width: 70.0, height: 70.0)
    
    /// Textures used to show LumaxMan appearing in the scene.
    static var appearTextures: [Direction: SKTexture]?
    
    static var texturesLoaded: Bool = false
    
    // The agent used to find pathes to LumaxMan.
    let agent: GKAgent2D
    
    /// The RenderComponent associated with LumaxMan.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A LumaxMan must have an RenderComponent.") }
        return renderComponent
    }
    
    /// The InputComponent associated with LumaxMan.
    var inputComponent: InputComponent? {
        return componentForClass(InputComponent.self)
    }
    
    /// The `IntelligenceComponent` associated with this `LumaxMan`.
    var intelligenceComponent: IntelligenceComponent? {
        return componentForClass(IntelligenceComponent.self)
    }
    
    /// The `MovementComponent` associated with this `LumaxMan`.
    var movementComponent: MovementComponent? {
        return componentForClass(MovementComponent.self)
    }
    
    var missingKeys : Int = 0
    var collectedCoins : Int = 0 {
        didSet {
            currentLevelScene?.collectedCoins(collectedCoins)
        }
    }
    
    var remainingLives : Int = 3 {
        didSet {
            currentLevelScene?.remainingLives(remainingLives)
        }
    }
    
    var currentLevelScene : LevelScene?
    
    override init() {
        agent = GKAgent2D()
        
        super.init()
        
        initComponents()
    }
    
    func initComponents() {
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let inputComponent = InputComponent()
        addComponent(inputComponent)
        
        
        let physicsBody = SKPhysicsBody(circleOfRadius: LumaxManEntity.textureSize.width/2)
        physicsBody.allowsRotation = false
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .LumaxMan)
        
        addComponent(physicsComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
        
        // `AnimationComponent` tracks and vends the animations for different entity states and directions.
        guard let animations = LumaxManEntity.animations else {
            fatalError("Attempt to access LumaxMan.animations before they have been loaded.")
        }
        let animationComponent = AnimationComponent(textureSize: LumaxManEntity.textureSize, animations: animations)
        addComponent(animationComponent)
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
        
        let intelligenceComponent = IntelligenceComponent(states: [
            LMAppearState(entity: self),
            LMMovingState(entity: self),
            LMHitState(entity: self)
            ])
        
        addComponent(intelligenceComponent)
    }
    
    // MARK: Physics Collisions
    
    func contactWithEntityDidBegin(entity: GKEntity?) {
        inputComponent?.updateDisplacement(float2(x: 0, y:0))
    }
    
    func contactWithEntityDidEnd(entity: GKEntity?) {
    }
    
    
    static func loadResources() {
        if !LumaxManEntity.texturesLoaded {
            let atlasNames = [
                "LumaxManIdle",
                "LumaxManMoving",
                "LumaxManHit"
            ]
            
            /*
            Preload all of the texture atlases for LumaxMan. This improves
            the overall loading speed of the animation cycles for this character.
            */
            SKTextureAtlas.preloadTextureAtlasesNamed(["LumaxManMoving"]) { error, atlases in
                if let error = error {
                    fatalError("One or more texture atlases could not be found: \(error)")
                }
                
                /*
                This closure sets up all of the LumaxMan animations
                after the LumaxMan texture atlases have finished preloading.
                
                Store the first texture from each direction of the LumaxMan's idle animation,
                for use in the LumaxMan's "appear"  state.
                */
                appearTextures = [:]
                for orientation in Direction.allDirections {
                    //appearTextures![orientation] = AnimationComponent.firstTextureForOrientation(orientation, inAtlas: atlases[0], withImageIdentifier: "LumaxManIdle")
                    appearTextures![orientation] = AnimationComponent.firstTextureForOrientation(orientation, inAtlas: atlases[0], withImageIdentifier: "LumaxManMoving")
                }
                
                // Set up all animations of LumaxMan.
                animations = [:]
                animations![.Idle] = AnimationComponent.animationsFromAtlas(atlases[0], withImageIdentifier: "LumaxManMoving", forAnimationState: .Idle)
                animations![.Moving] = AnimationComponent.animationsFromAtlas(atlases[0], withImageIdentifier: "LumaxManMoving", forAnimationState: .Moving)
                
                animations![.Hit] = AnimationComponent.animationsFromAtlas(atlases[0], withImageIdentifier: "LumaxManMoving", forAnimationState: .Hit, repeatTexturesForever: false)
                
                LumaxManEntity.texturesLoaded = true
            }
        }
    }
    
    // MARK: Agent System Update
    
    // Sets the position of the agent of LumaxMan to match the node position.
    func updateAgentPositionToMatchNodePosition() {
        let renderComponent = self.renderComponent
        agent.position = float2(renderComponent.node.position)
    }
}