//
//  SimpleAnimationComponent.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 26/01/16.
//
//

import SpriteKit
import GameplayKit


/**
 Encapsulates all of the information needed to animate an entity and its shadow
 for a given animation state and facing direction.
 */
struct SimpleAnimation {
    /// One or more `SKTexture`s to animate as a cycle for this animation.
    let textures: [SKTexture]
}

class SimpleAnimationComponent: GKComponent {
    /// The time to display each frame of a texture animation.
    static let timePerFrame = NSTimeInterval(1.0 / 10.0)
    
    // MARK: Properties
    
    /// The node on which animations should be run for this animation component.
    let node: SKSpriteNode
    
    /// The current set of animations for the component's entity.
    var animation: SimpleAnimation
    
    /// The length of time spent in the current animation state and direction.
    private var elapsedAnimationDuration: NSTimeInterval = 0.0
    
    // MARK: Initializers
    
    init(textureSize: CGSize, animation: SimpleAnimation) {
        self.node = SKSpriteNode(texture: nil, size: textureSize)
        self.animation = animation
        super.init()
        runAnimation()
    }
    
    // MARK: Character Animation
    
    private func runAnimation() {
        // Create a new action to display the appropriate animation textures.
        let texturesAction: SKAction
        
        if animation.textures.count == 1 {
            // If the new animation only has a single frame, create a simple "set texture" action.
            texturesAction = SKAction.setTexture(animation.textures.first!)
        }
        else {
            texturesAction = SKAction.repeatActionForever(SKAction.animateWithTextures(animation.textures, timePerFrame: AnimationComponent.timePerFrame))
        }
        
        // Add the textures animation to the body node.
        node.runAction(texturesAction)
    }
    
    // MARK: GKComponent Life Cycle
    
    /*override func updateWithDeltaTime(deltaTime: NSTimeInterval) {
    super.updateWithDeltaTime(deltaTime)
    
    runAnimation()
    }*/
}
