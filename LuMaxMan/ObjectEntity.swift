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
    static var animation: SimpleAnimation?
    
    /// The size to use for the `PlayerBot`s animation textures.
    static var textureSize = CGSize(width: 40, height: 40)
    
    /// Textures used by `PlayerBotAppearState` to show a `PlayerBot` appearing in the scene.
    static var appearTextures: [Direction: SKTexture]?
    
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
        
        let atlas = SKTextureAtlas(named: "KeyEntity")
        
        let textures = atlas.textureNames.map {
            atlas.textureNamed($0)
        }
        
        ObjectEntity.animation = SimpleAnimation(textures: textures)
        
        initComponents()
    }
    
    func setObjectBehaviour(behaviour: ObjectBehaviour) {
        addComponent(ObjectComponent(withCollissionBehaviour: behaviour))
    }
    
    func initComponents() {
        addComponent(RenderComponent(entity: self))
        
        let physicsBody = SKPhysicsBody(circleOfRadius: ObjectEntity.textureSize.width/2)
        physicsBody.allowsRotation = false
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Object)
        
        addComponent(physicsComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        // `AnimationComponent` tracks and vends the animations for different entity states and directions.
        guard let animation = ObjectEntity.animation else {
            fatalError("Attempt to access ObjectEntity before they have been loaded.")
        }
        
        let animationComponent = SimpleAnimationComponent(textureSize: ObjectEntity.textureSize, animation: animation)
        
        
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
}
