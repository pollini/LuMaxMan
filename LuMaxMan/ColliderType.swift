/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
An option set used for categorizing physics bodies in SpriteKit's physics world.
*/

import SpriteKit
import GameplayKit

struct ColliderType: OptionSetType, Hashable {
    // MARK: Static properties
    
    /// A dictionary to specify which `ColliderType`s should be notified of contacts with other `ColliderType`s.
    static let requestedContactNotifications : [ColliderType: [ColliderType]] =
    [
        .LumaxMan: [.LumaxMan, .Obstacle],
        .Object: [.LumaxMan],
        .Enemy: [.LumaxMan, .Obstacle]
    ]
    
    /// A dictionary of which `ColliderType`s should collide with other `ColliderType`s.
    static let definedCollisions : [ColliderType: [ColliderType]] =
    [
        .LumaxMan: [.LumaxMan, .Obstacle],
        .Object: [.LumaxMan],
        .Enemy: [.LumaxMan, .Obstacle]
    ]
    
    // MARK: Properties
    
    let rawValue: UInt32
    
    // MARK: Options
    
    static var Obstacle: ColliderType  { return self.init(rawValue: 1 << 0) }
    static var LumaxMan: ColliderType { return self.init(rawValue: 1 << 1) }
    static var Enemy: ColliderType { return self.init(rawValue: 1 << 2) }
    static var Object: ColliderType { return self.init(rawValue: 1 << 3) }
    
    // MARK: Hashable
    
    var hashValue: Int {
        return Int(rawValue)
    }
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        switch self.rawValue {
        case ColliderType.Obstacle.rawValue:
            return "ColliderType.Obstacle"
            
        case ColliderType.LumaxMan.rawValue:
            return "ColliderType.LumaxMan"
            
        case ColliderType.Enemy.rawValue:
            return "ColliderType.Enemy"
            
        default:
            return "UnknownColliderType(\(self.rawValue))"
        }
    }
    
    // MARK: SpriteKit Physics Convenience
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `categoryMask` property.
    var categoryMask: UInt32 {
        return rawValue
    }
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `collisionMask` property.
    var collisionMask: UInt32 {
        // Combine all of the collision requests for this type using a bitwise or.
        let mask = ColliderType.definedCollisions[self]?.reduce(ColliderType()) { initial, colliderType in
            return initial.union(colliderType)
        }
        
        // Provide the rawValue of the resulting mask or 0 (so the object doesn't collide with anything).
        return mask?.rawValue ?? 0
    }
    
    /// A value that can be assigned to a 'SKPhysicsBody`'s `contactMask` property.
    var contactMask: UInt32 {
        // Combine all of the contact requests for this type using a bitwise or.
        let mask = ColliderType.requestedContactNotifications[self]?.reduce(ColliderType()) { initial, colliderType in
            return initial.union(colliderType)
        }
        
        // Provide the rawValue of the resulting mask or 0 (so the object doesn't need contact callbacks).
        return mask?.rawValue ?? 0
    }
    
    // MARK: ContactNotifiableType Convenience
    
    /**
    Returns `true` if the `ContactNotifiableType` associated with this `ColliderType` should be
    notified of contact with the passed `ColliderType`.
    */
    func notifyOnContactWithColliderType(colliderType: ColliderType) -> Bool {
        if let requestedContacts = ColliderType.requestedContactNotifications[self] {
            return requestedContacts.contains(colliderType)
        }
        
        return false
    }
}
