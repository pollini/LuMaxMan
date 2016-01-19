//
//  KeyEntity.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/01/16.
//
//

import GameplayKit
import SpriteKit

class ObjectEntity: GKEntity, ContactNotifiableType {
    
    /// The animations to use for a `LumaxMan`.
    static var animations: [AnimationState: [Direction: Animation]]?
    
    /// The size to use for the `PlayerBot`s animation textures.
    static var textureSize = CGSize(width: 120.0, height: 120.0)
    
    /// Textures used by `PlayerBotAppearState` to show a `PlayerBot` appearing in the scene.
    static var appearTextures: [Direction: SKTexture]?
    
    static var texturesLoaded: Bool = false
    
    /// The `RenderComponent` associated with this `LumaxMan`.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A PlayerBot must have an RenderComponent.") }
        return renderComponent
    }
    
    /// The `ObjectComponent` associated with this `LumaxMan`.
    var objectComponent: ObjectComponent? {
        return componentForClass(ObjectComponent.self)
    }
    
    override init() {
        super.init()
        
        initComponents()
    }
    
    func setObjectBehaviour(behaviour: ObjectBehaviour) {
        addComponent(ObjectComponent(withCollissionBehaviour: behaviour))
    }
    
    func initComponents() {
        addComponent(RenderComponent(entity: self))
        
        addComponent(OrientationComponent())
        
        let physicsBody = SKPhysicsBody(circleOfRadius: ObjectEntity.textureSize.width)
        physicsBody.allowsRotation = false
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Object)
        
        addComponent(physicsComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // `AnimationComponent` tracks and vends the animations for different entity states and directions.
        guard let animations = ObjectEntity.animations else {
            fatalError("Attempt to access ObjectEntity before they have been loaded.")
        }
        
        let animationComponent = AnimationComponent(textureSize: ObjectEntity.textureSize, animations: animations)
        addComponent(animationComponent)
        
        // Connect the `RenderComponent` and `ShadowComponent` to the `AnimationComponent`.
        renderComponent.node.addChild(animationComponent.node)
    }
    
    func contactWithEntityDidBegin(entity: GKEntity?) {
        objectComponent?.contactWithEntityDidBegin(entity)
    }
    
    func contactWithEntityDidEnd(entity: GKEntity?) {
        objectComponent?.contactWithEntityDidEnd(entity)
    }
    
    static func loadResources() {
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
                appearTextures![orientation] = AnimationComponent.firstTextureForOrientation(orientation, inAtlas: atlases[0], withImageIdentifier: "LumaxManIdle")
            }
            
            // Set up all of the `PlayerBot`s animations.
            animations = [:]
            animations![.Idle] = AnimationComponent.animationsFromAtlas(atlases[0], withImageIdentifier: "LumaxManIdle", forAnimationState: .Idle)
            animations![.Moving] = AnimationComponent.animationsFromAtlas(atlases[1], withImageIdentifier: "LumaxManMoving", forAnimationState: .Moving)
            animations![.Hit] = AnimationComponent.animationsFromAtlas(atlases[2], withImageIdentifier: "LumaxManHit", forAnimationState: .Hit, repeatTexturesForever: false)
            
            LumaxManEntity.texturesLoaded = true
        }
    }
}
