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
    
    /// The animations to use for a `LumaxMan`.
    static var animations: [AnimationState: [Direction: Animation]]?
    
    /// The size to use for the `PlayerBot`s animation textures.
    static var textureSize = CGSize(width: 80.0, height: 80.0)
    
    /// Textures used by `PlayerBotAppearState` to show a `PlayerBot` appearing in the scene.
    static var appearTextures: [Direction: SKTexture]?
    
    static var texturesLoaded: Bool = false
    
    /// The `RenderComponent` associated with this `LumaxMan`.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A LumaxMan must have an RenderComponent.") }
        return renderComponent
    }
    
    /// The `InputComponent` associated with this `LumaxMan`.
    var inputComponent: InputComponent? {
        return componentForClass(InputComponent.self)
    }
    
    /// The `IntelligenceComponent` associated with this `LumaxMan`.
    var intelligenceComponent: IntelligenceComponent? {
        return componentForClass(IntelligenceComponent.self)
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
    
    // MARK: Physics collision
    
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
            Preload all of the texture atlases for `PlayerBot`. This improves
            the overall loading speed of the animation cycles for this character.
            */
            SKTextureAtlas.preloadTextureAtlasesNamed(atlasNames) { error, atlases in
                if let error = error {
                    fatalError("One or more texture atlases could not be found: \(error)")
                }
                
                /*
                This closure sets up all of the `PlayerBot` animations
                after the `PlayerBot` texture atlases have finished preloading.
                
                Store the first texture from each direction of the `PlayerBot`'s idle animation,
                for use in the `PlayerBot`'s "appear"  state.
                */
                appearTextures = [:]
                for orientation in Direction.allDirections {
                    //appearTextures![orientation] = AnimationComponent.firstTextureForOrientation(orientation, inAtlas: atlases[0], withImageIdentifier: "LumaxManIdle")
                    appearTextures![orientation] = AnimationComponent.firstTextureForOrientation(orientation, inAtlas: atlases[1], withImageIdentifier: "LumaxManMoving")
                }
                
                // Set up all of the `PlayerBot`s animations.
                animations = [:]
                //animations![.Idle] = AnimationComponent.animationsFromAtlas(atlases[0], withImageIdentifier: "LumaxManIdle", forAnimationState: .Idle)
                animations![.Idle] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "LumaxManMoving", forAnimationState: .Idle)
                animations![.Moving] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "LumaxManMoving", forAnimationState: .Moving)
                //animations![.Hit] = AnimationComponent.animationsFromAtlas(atlases[2], withImageIdentifier: "LumaxManHit", forAnimationState: .Hit, repeatTexturesForever: false)
                animations![.Hit] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "LumaxManMoving", forAnimationState: .Hit, repeatTexturesForever: false)
                
                LumaxManEntity.texturesLoaded = true
            }
        }
    }
}