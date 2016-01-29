//
//  MovementComponent.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract:
//  A `GKComponent` that enables an entity to move appropriately for the input directing it. Used by a `GKEntity` to move around a level in response to input from its `InputComponent`

import SpriteKit
import GameplayKit

struct MovementKind {
    // MARK: Properties
    
    /// The movement to execute.
    let displacement: float2
    
    // MARK: Initializers
    init(displacement: float2) {
        self.displacement = displacement
    }
}

class MovementComponent: GKComponent {
    /// Value used to calculate the translational movement of the entity.
    var nextTranslation: MovementKind?
    
    var allowsStrafing = false
    
    /// The `RenderComponent` for this component's entity.
    var renderComponent: RenderComponent {
        guard let renderComponent = entity?.componentForClass(RenderComponent.self) else { fatalError("A MovementComponent's entity must have a RenderComponent") }
        return renderComponent
    }
    
    /// The `OrientationComponent` for this component's entity.
    var orientationComponent: OrientationComponent {
        guard let orientationComponent = entity?.componentForClass(OrientationComponent.self) else { fatalError("A MovementComponent's entity must have an OrientationComponent") }
        return orientationComponent
    }
    
    /// The `AnimationComponent` for this component's entity.
    var animationComponent: AnimationComponent {
        guard let animationComponent = entity?.componentForClass(AnimationComponent.self) else { fatalError("A MovementComponent's entity must have an AnimationComponent") }
        return animationComponent
    }
    
    /// Determines how quickly the entity is moved in points per second.
    var movementSpeed: CGFloat
    
    
    // MARK: Initializers
    
    override init() {
        movementSpeed = GameplayConfiguration.LumaxMan.movementSpeed
    }
    
    // MARK: GKComponent Life Cycle
    
    override func updateWithDeltaTime(deltaTime: NSTimeInterval) {
        super.updateWithDeltaTime(deltaTime)
        
        // Declare local versions of computed properties so we don't compute them multiple times.
        let node = self.renderComponent.node
        if entity is LumaxManEntity {
            //print("LMPOS: \(node.position)")
        }
        
        let orientationComponent = self.orientationComponent
        
        var animationState: AnimationState?
        
        // Update the node's `position` with new displacement information.
        if let movement = self.nextTranslation, newPosition = self.pointForTranslatingNode(node, withTranslationalMovement: movement, duration: deltaTime) {
            node.position = newPosition
            
            orientationComponent.zRotation = CGFloat(atan2(movement.displacement.y, movement.displacement.x))
            
            animationState = .Moving
        }
        else {
            // Clear the translation if a valid point could not be created.
            self.nextTranslation = nil
        }
        /*
        If an animation is required, and the `AnimationComponent` is running,
        and the requested animation can be overwritten, update the `AnimationComponent`'s
        requested animation state.
        */
        if let animationState = animationState {
            // `animationComponent` is a computed property. Declare a local version so we don't compute it multiple times.
            let animationComponent = self.animationComponent
            
            if self.animationStateCanBeOverwritten(animationComponent.currentAnimation?.animationState) && self.animationStateCanBeOverwritten(animationComponent.requestedAnimationState) {
                animationComponent.requestedAnimationState = animationState
            }
        }
    }
    
    func moveToPoint(position: CGPoint) {
        self.renderComponent.node.position = position
    }
    
    // MARK: Convenience Methods
    
    /// Produces the destination point for the node, based on the provided translation.
    func pointForTranslatingNode(node: SKNode, withTranslationalMovement translation: MovementKind, duration: NSTimeInterval) -> CGPoint? {
        // No translation if the vector is a zeroVector.
        guard translation.displacement != float2() else { return nil }
        
        var displacement = translation.displacement
        
        let angle = CGFloat(atan2(displacement.y, displacement.x))
        
        // Calculate the furthest distance between two points the entity could travel.
        let maxPossibleDistanceToMove = movementSpeed * CGFloat(duration)
        
        /*
        Make sure that the total possible distance that can be travelled by
        the node is scaled by the the displacement's magnitude. For example,
        if a user is interacting with a `GameControlInputSource` that is using
        a thumb-stick to move the player, the actual displacement value would be
        between 0.0 and 1.0. In that case, we want to move the corresponding
        node relative to that amount of input.
        */
        let normalizedDisplacement: float2
        if length(displacement) > 1.0 {
            normalizedDisplacement = normalize(displacement)
        }
        else {
            normalizedDisplacement = displacement
        }
        
        let actualDistanceToMove = CGFloat(length(normalizedDisplacement)) * maxPossibleDistanceToMove
        
        // Find the x and y components of the distance based on the angle.
        let dx = actualDistanceToMove * cos(angle)
        let dy = actualDistanceToMove * sin(angle)
        
        // Return the final point the entity should move to.
        return CGPoint(x: node.position.x + dx, y: node.position.y + dy)
    }
    
    /**
     Determine if the `animationState` can be overwritten. For example, if
     an `.Attack` animation is being run, we do not want to replace this
     with any sort of movement animation.
     */
    private func animationStateCanBeOverwritten(animationState: AnimationState?) -> Bool {
        switch animationState {
        case nil, .Idle?, .Moving?:
            return true
            
        default:
            return false
        }
    }
}
