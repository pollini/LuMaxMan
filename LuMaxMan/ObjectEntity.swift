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
    
    /// The size to use for the LumaxMans animation textures.
    var textureSize : CGSize
    
    /// The `RenderComponent` associated with this `LumaxMan`.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("An Object must have a RenderComponent.") }
        return renderComponent
    }
    
    // The agent used to find pathes to LumaxMan.
    let agent: GKAgent2D
    
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
        case .Heart:
            entity = ObjectEntity(textureAtlasNamed: "HeartEntity", andTextureSize: CGSize(width: 20, height: 20))
            entity.setObjectBehaviour(HeartBehavior())
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
        
        agent = GKAgent2D()
        
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
    
    
    // MARK: Agent System Update
    
    // Sets the position of the agent of LumaxMan to match the node position.
    func updateAgentPositionToMatchNodePosition() {
        let renderComponent = self.renderComponent
        agent.position = float2(renderComponent.node.position)
        print("\(self), \(agent.position)")
    }
}

enum ObjectType {
    case Key, Coin, Heart
    //static let allObjects = [Key, Coin, Heart]
    static let allObjects = [Coin, Heart]
    
    func objectPath () -> String {
        switch self {
        case .Key:
            return "keys"
        case .Coin:
            return "coins"
        case .Heart:
            return "hearts"
        }
    }
}
