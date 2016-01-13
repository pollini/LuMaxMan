//
//  LMAppearState.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 17/12/15.
//
//
/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A state used to represent the player at level start when being 'beamed' into the level.
*/

import SpriteKit
import GameplayKit

class LMAppearState: GKState {
    // MARK: Properties
    
    unowned var entity: LumaxManEntity
    
    /// The amount of time the `PlayerBot` has been in the "appear" state.
    var elapsedTime: NSTimeInterval = 0.0
    
    /// The `AnimationComponent` associated with the `entity`.
    var animationComponent: AnimationComponent {
        guard let animationComponent = entity.componentForClass(AnimationComponent.self) else { fatalError("A LMAppearState's entity must have an AnimationComponent.") }
        return animationComponent
    }
    
    /// The `RenderComponent` associated with the `entity`.
    var renderComponent: RenderComponent {
        guard let renderComponent = entity.componentForClass(RenderComponent.self) else { fatalError("A LMAppearState's entity must have an RenderComponent.") }
        return renderComponent
    }
    
    /// The `OrientationComponent` associated with the `entity`.
    var orientationComponent: OrientationComponent {
        guard let orientationComponent = entity.componentForClass(OrientationComponent.self) else { fatalError("A LMAppearState's entity must have an OrientationComponent.") }
        return orientationComponent
    }
    
    /// The `InputComponent` associated with the `entity`.
    var inputComponent: InputComponent {
        guard let inputComponent = entity.componentForClass(InputComponent.self) else { fatalError("A LMAppearState's entity must have an InputComponent.") }
        return inputComponent
    }
    
    /// The `SKSpriteNode` used to show the player animating into the scene.
    var node = SKSpriteNode()
    
    // MARK: Initializers
    
    required init(entity: LumaxManEntity) {
        self.entity = entity
    }
    
    // MARK: GKState Life Cycle
    
    override func didEnterWithPreviousState(previousState: GKState?) {
        super.didEnterWithPreviousState(previousState)
        
        // Reset the elapsed time.
        elapsedTime = 0.0
        
        /*
        The `PlayerBot` is about to appear in the level. We use an `SKShader` to
        provide a "teleport" effect to beam in the `PlayerBot`.
        */
        
        // Retrieve and use an initial texture for the `PlayerBot`, taken from the appropriate idle animation.
        guard let appearTextures = LumaxManEntity.appearTextures else {
            fatalError("Attempt to access PlayerBot.appearTextures before they have been loaded.")
        }
        let texture = appearTextures[orientationComponent.direction]!
        node.texture = texture
        node.size = LumaxManEntity.textureSize
        
        // Add the node to the `PlayerBot`'s render node.
        renderComponent.node.addChild(node)
        
        // Hide the animation component node until the `PlayerBot` exits this state.
        animationComponent.node.hidden = true
        
        // Disable the input component while the `PlayerBot` appears.
        inputComponent.isEnabled = false
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        super.updateWithDeltaTime(seconds)
        
        // Update the amount of time that the `PlayerBot` has been teleporting in to the level.
        elapsedTime += seconds
        
        // Check if we have spent enough time
        if elapsedTime > GameplayConfiguration.LumaxMan.appearDuration {
            // Remove the node from the scene
            node.removeFromParent()
            
            // Switch the `PlayerBot` over to a "player controlled" state.
            stateMachine?.enterState(LMMovingState.self)
        }
    }
    
    override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass is LMMovingState.Type
    }
    
    override func willExitWithNextState(nextState: GKState) {
        super.willExitWithNextState(nextState)
        
        // Un-hide the animation component node.
        animationComponent.node.hidden = false
        
        // Re-enable the input component
        inputComponent.isEnabled = true
    }
}
