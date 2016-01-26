/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A `GKComponent` that provides and manages the actions used to animate characters on screen as they move through different states and face different directions. `AnimationComponent` is supported by a structure called `Animation` that encapsulates information about an individual animation.
*/

import SpriteKit
import GameplayKit

/// The different animation states that an animated character can be in.
enum AnimationState: String {
    case Idle = "Idle"
    case Moving = "Moving"
    case Hit = "Hit"
}

/**
 Encapsulates all of the information needed to animate an entity and its shadow
 for a given animation state and facing direction.
 */
struct Animation {
    
    // MARK: Properties
    
    /// The animation state represented in this animation.
    let animationState: AnimationState
    
    /// The direction the entity is facing during this animation.
    let direction: Direction
    
    /// One or more `SKTexture`s to animate as a cycle for this animation.
    let textures: [SKTexture]
    
    /// Whether this action's `textures` array should be repeated forever when animated.
    let repeatTexturesForever: Bool
}

class AnimationComponent: GKComponent {
    /// The key to use when adding a texture animation action to the entity's body.
    static let textureActionKey = "textureAction"
    
    /// The time to display each frame of a texture animation.
    static let timePerFrame = NSTimeInterval(1.0 / 10.0)
    
    // MARK: Properties
    
    /**
    The most recent animation state that the animation component has been requested to play,
    but has not yet started playing.
    */
    var requestedAnimationState: AnimationState?
    
    /// The node on which animations should be run for this animation component.
    let node: SKSpriteNode
    
    /// The node for the entity's shadow (to be set by the entity if needed).
    var shadowNode: SKSpriteNode?
    
    /// The current set of animations for the component's entity.
    var animations: [AnimationState: [Direction: Animation]]
    
    /// The animation that is currently running.
    private(set) var currentAnimation: Animation?
    
    /// The length of time spent in the current animation state and direction.
    private var elapsedAnimationDuration: NSTimeInterval = 0.0
    
    // MARK: Initializers
    
    init(textureSize: CGSize, animations: [AnimationState: [Direction: Animation]]) {
        node = SKSpriteNode(texture: nil, size: textureSize)
        self.animations = animations
    }
    
    // MARK: Character Animation
    
    private func runAnimationForAnimationState(animationState: AnimationState, direction: Direction, deltaTime: NSTimeInterval) {
        
        // Update the tracking of how long we have been animating.
        elapsedAnimationDuration += deltaTime
        
        // Check if we are already running this animation. There's no need to do anything if so.
        if currentAnimation != nil && currentAnimation!.animationState == animationState && currentAnimation!.direction == direction { return }
        
        /*
        Retrieve a copy of the stored animation for the requested state and direction.
        `Animation` is a structure - i.e. a value type - so the `animation` variable below
        will contain a unique copy of the animation's data.
        We request this copy as a variable (rather than a constant) so that the
        `animation` variable's `frameOffset` property can be modified later in this method
        if we choose to offset the animation's start point from zero.
        */
        guard let animation = animations[animationState]?[direction] else {
            print("Unknown animation for state \(animationState.rawValue), direction \(direction.rawValue).")
            return
        }
        
        // Remove the existing texture animation action if it exists.
        node.removeActionForKey(AnimationComponent.textureActionKey)
        
        // Create a new action to display the appropriate animation textures.
        let texturesAction: SKAction
        
        if animation.textures.count == 1 {
            // If the new animation only has a single frame, create a simple "set texture" action.
            texturesAction = SKAction.setTexture(animation.textures.first!)
        }
        else {
            // Create an appropriate action from the (possibly offset) animation frames.
            if animation.repeatTexturesForever {
                texturesAction = SKAction.repeatActionForever(SKAction.animateWithTextures(animation.textures, timePerFrame: AnimationComponent.timePerFrame))
            }
            else {
                texturesAction = SKAction.animateWithTextures(animation.textures, timePerFrame: AnimationComponent.timePerFrame)
            }
        }
        
        // Add the textures animation to the body node.
        node.runAction(texturesAction, withKey: AnimationComponent.textureActionKey)
        
        // Remember the animation we are currently running.
        currentAnimation = animation
        
        // Reset the "how long we have been animating" counter.
        elapsedAnimationDuration = 0.0
    }
    
    // MARK: GKComponent Life Cycle
    
    override func updateWithDeltaTime(deltaTime: NSTimeInterval) {
        super.updateWithDeltaTime(deltaTime)
        
        // If an animation has been requested, run the animation.
        if let animationState = requestedAnimationState {
            guard let orientationComponent = entity?.componentForClass(OrientationComponent.self) else { fatalError("An AnimationComponent's entity must have an OrientationComponent.") }
            
            runAnimationForAnimationState(animationState, direction: orientationComponent.direction, deltaTime: deltaTime)
            requestedAnimationState = nil
        }
    }
    
    // MARK: Texture loading utilities
    
    /// Returns the first texture in an atlas for a given `Direction`.
    class func firstTextureForOrientation(direction: Direction, inAtlas atlas: SKTextureAtlas, withImageIdentifier identifier: String) -> SKTexture {
        // Filter for this facing direction, and sort the resulting texture names alphabetically.
        let textureNames = atlas.textureNames.filter {
            $0.hasPrefix("\(identifier)_\(direction.rawValue)_")
            }.sort()
        
        // Find and return the first texture for this direction.
        return atlas.textureNamed(textureNames.first!)
    }
    
    /// Creates a texture action from all textures in an atlas.
    class func actionForAllTexturesInAtlas(atlas: SKTextureAtlas) -> SKAction {
        // Sort the texture names alphabetically, and map them to an array of actual textures.
        let textures = atlas.textureNames.sort().map {
            atlas.textureNamed($0)
        }
        
        // Create an appropriate action for these textures.
        if textures.count == 1 {
            return SKAction.setTexture(textures.first!)
        }
        else {
            let texturesAction = SKAction.animateWithTextures(textures, timePerFrame: AnimationComponent.timePerFrame)
            return SKAction.repeatActionForever(texturesAction)
        }
    }
    
    /// Creates an `Animation` from textures in an atlas and actions loaded from file.
    class func animationsFromAtlas(atlas: SKTextureAtlas, withImageIdentifier identifier: String, forAnimationState animationState: AnimationState, bodyActionName: String? = nil, shadowActionName: String? = nil, repeatTexturesForever: Bool = true, playBackwards: Bool = false) -> [Direction: Animation] {
        
        /// A dictionary of animations with an entry for each compass direction.
        var animations = [Direction: Animation]()
        
        for direction in Direction.allDirections {
            
            // Find all matching texture names, sorted alphabetically, and map them to an array of actual textures.
            let textures = atlas.textureNames.filter {
                $0.hasPrefix("\(identifier)_\(direction.rawValue)_")
                }.sort {
                    playBackwards ? $0 > $1 : $0 < $1
                }.map {
                    atlas.textureNamed($0)
            }
            
            // Create a new `Animation` for these settings.
            animations[direction] = Animation(
                animationState: animationState,
                direction: direction,
                textures: textures,
                repeatTexturesForever: repeatTexturesForever
            )
            
        }
        
        return animations
    }
    
}
