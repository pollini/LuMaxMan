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
    var animation: SimpleAnimation
    
    /// The size to use for the `PlayerBot`s animation textures.
    var textureSize : CGSize
    
    /// The `RenderComponent` associated with this `LumaxMan`.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A PlayerBot must have an RenderComponent.") }
        return renderComponent
    }
    
    /// The `ObjectComponent` associated with this `LumaxMan`.
    var objectComponent: ObjectComponent? {
        return componentForClass(ObjectComponent.self)
    }
    
    static func createObjectEntityWithType(type: ObjectType) -> ObjectEntity {
        let entity: ObjectEntity
        
        switch type {
        case .Key:
            entity = ObjectEntity(textureAtlasNamed: "KeyEntity", andTextureSize: CGSize(width: 40, height: 40))
            entity.setObjectBehaviour(KeyBehavior())
        case .Coin:
            entity = ObjectEntity(textureAtlasNamed: "CoinEntity", andTextureSize: CGSize(width: 20, height: 20))
            entity.setObjectBehaviour(CoinBehavior())
        }
        
        return entity
    }
    
    init(textureAtlasNamed: String, andTextureSize textureSize: CGSize) {
        self.textureSize = textureSize
        
        let atlas = SKTextureAtlas(named: textureAtlasNamed)
        
        let textures = atlas.textureNames.map {
            atlas.textureNamed($0)
        }
        
        self.animation = SimpleAnimation(textures: textures)
        
        super.init()
        
        initComponents()
    }
    
    func setObjectBehaviour(behaviour: ObjectBehavior) {
        addComponent(ObjectComponent(withCollissionBehavior: behaviour))
    }
    
    func initComponents() {
        addComponent(RenderComponent(entity: self))
        
        let physicsBody = SKPhysicsBody(circleOfRadius: self.textureSize.width/2)
        physicsBody.allowsRotation = false
        let physicsComponent = PhysicsComponent(physicsBody: physicsBody, colliderType: .Object)
        
        addComponent(physicsComponent)
        
        // Connect the `PhysicsComponent` and the `RenderComponent`.
        renderComponent.node.physicsBody = physicsComponent.physicsBody
        
        let animationComponent = SimpleAnimationComponent(textureSize: self.textureSize, animation: animation)
        
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

enum ObjectType {
    case Key, Coin
}
