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

/**
 In DemoBots you have the ability to request two different kinds of movement.
 - `isRelativeToOrientation = true`: moves the node based on the node's existing rotation
 and is thus "relative" to the node's orientation.
 - `isRelativeToOrientation = false`: moves the node in exactly the manner specified
 by the vector and is not adjusted for the node's orientation.
 
 For example:
 If the node is facing to the right of the level, supplying `isRelativeToOrientation = true`
 and `float2(x: 1, y: 0)` will move the node forward - towards the right of the screen.
 Passing the same vector but `isRelativeToOrientation = false` will move the node to the top
 of the screen regardless of the node's orientation.
 */
struct MovementKind {
    // MARK: Properties
    
    /**
    Relative movement accounts for the current orientation of the entity when
    calculating displacement.
    */
    let isRelativeToOrientation: Bool
    
    /// The movement to execute.
    let displacement: float2
    
    // MARK: Initializers
    
    init(displacement: float2, relativeToOrientation: Bool = false) {
        isRelativeToOrientation = relativeToOrientation
        self.displacement = displacement
    }
}

class MovementComponent: GKComponent {
    // MARK: Properties
    
    /// Value used to calculate the translational movement of the entity.
    var nextTranslation: MovementKind?
    
    /// Value used to calculate the rotational movement of the entity.
    var nextRotation: MovementKind?
    
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
        let node = renderComponent.node
        let orientationComponent = self.orientationComponent
        
        var animationState: AnimationState?
        
        if let movement = nextRotation, newRotation = angleForRotatingNode(node, withRotationalMovement: movement, duration: deltaTime)  {
            // Update the node's `zRotation` with new rotation information.
            orientationComponent.zRotation = newRotation
            animationState = .Idle
        }
        else {
            // Clear the rotation if a valid angle could not be created.
            nextRotation = nil
        }
        
        // Update the node's `position` with new displacement information.
        if let movement = nextTranslation, newPosition = pointForTranslatingNode(node, withTranslationalMovement: movement, duration: deltaTime) {
            node.position = newPosition
            
            // If no explicit rotation is being provided, orient in the direction of movement.
            if nextRotation == nil {
                orientationComponent.zRotation = CGFloat(atan2(movement.displacement.y, movement.displacement.x))
            }
            animationState = .Moving
        }
        else {
            // Clear the translation if a valid point could not be created.
            nextTranslation = nil
        }
        
        
        /*
        If an animation is required, and the `AnimationComponent` is running,
        and the requested animation can be overwritten, update the `AnimationComponent`'s
        requested animation state.
        */
        if let animationState = animationState {
            // `animationComponent` is a computed property. Declare a local version so we don't compute it multiple times.
            let animationComponent = self.animationComponent
            
            if animationStateCanBeOverwritten(animationComponent.currentAnimation?.animationState) && animationStateCanBeOverwritten(animationComponent.requestedAnimationState) {
                animationComponent.requestedAnimationState = animationState
            }
        }
    }
    
    // MARK: Convenience Methods
    
    /// Produces the destination point for the node, based on the provided translation.
    func pointForTranslatingNode(node: SKNode, withTranslationalMovement translation: MovementKind, duration: NSTimeInterval) -> CGPoint? {
        // No translation if the vector is a zeroVector.
        guard translation.displacement != float2() else { return nil }
        
        var displacement = translation.displacement
        /*
        If the translation is relative, the displacement vector needs to be
        rotated to account for the node's current orientation.
        */
        if translation.isRelativeToOrientation {
            // Ensure the relative displacement component is non-zero.
            guard displacement.x != 0 else { return nil }
            displacement = calculateAbsoluteDisplacementFromRelativeDisplacement(displacement)
        }
        
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
    
    func angleForRotatingNode(node: SKNode, withRotationalMovement rotation: MovementKind, duration: NSTimeInterval) -> CGFloat? {
        // No rotation if the vector is a zeroVector.
        guard rotation.displacement != float2() else { return nil }
        
        let angle: CGFloat
        if rotation.isRelativeToOrientation {
            // Clockwise: (dx: 0.0, dy: -1.0), CounterClockwise: (dx: 0.0, dy: 1.0)
            let rotationComponent = rotation.displacement.y
            guard rotationComponent != 0 else { return nil }
            
            /*
            Add a fixed amount to the node's existing `zRotation` based
            on the direction of the relative angle.
            */
            let rotationDirection = CGFloat(rotationComponent > 0 ? 1 : -1)
            
            // Add to the node's existing rotation.
            angle = orientationComponent.zRotation + rotationDirection
        }
        else {
            // Determine the angle of the rotational displacement.
            angle = CGFloat(atan2(rotation.displacement.y, rotation.displacement.x))
        }
        
        return angle
    }
    
    /**
     Calculates a new vector by taking a relative displacement and adjusting
     the angle to match the initial orientation and requested displacement.
     */
    private func calculateAbsoluteDisplacementFromRelativeDisplacement(relativeDisplacement: float2) -> float2 {
        // If available use the `nextRotation` for the most recent request, otherwise use current `zRotation`.
        var angleRelativeToOrientation = Float(orientationComponent.zRotation)
        
        // Forward: (dx: 1.0, dy: 0.0), Backward: (dx: -1.0, dy: 0.0)
        if relativeDisplacement.x < 0 {
            // The entity is moving backwards, add 180 degrees to the angle
            angleRelativeToOrientation += Float(M_PI)
        }
        
        // Calculate the components of a new vector with direction based off the `angleRelativeToOrientation`.
        let dx = length(relativeDisplacement) * cos(angleRelativeToOrientation)
        let dy = length(relativeDisplacement) * sin(angleRelativeToOrientation)
        
        // Make rotation correspond with relative movement, so that entities can walk and face the same direction.
        if nextRotation == nil {
            let directionFactor = Float(relativeDisplacement.x)
            nextRotation = MovementKind(displacement: float2(x: directionFactor * dx, y: directionFactor * dy))
        }
        
        return float2(x: dx, y: dy)
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
