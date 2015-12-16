//
//  LumaxManEntity.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//

import GameplayKit

class LumaxManEntity: GKEntity {
    /// The `RenderComponent` associated with this `LumaxMan`.
    var renderComponent: RenderComponent {
        guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A PlayerBot must have an RenderComponent.") }
        return renderComponent
    }
    
    override init() {
        super.init()
        
        let renderComponent = RenderComponent(entity: self)
        addComponent(renderComponent)
        
        let orientationComponent = OrientationComponent()
        addComponent(orientationComponent)
        
        let inputComponent = InputComponent()
        addComponent(inputComponent)
        
        let movementComponent = MovementComponent()
        addComponent(movementComponent)
    }
}