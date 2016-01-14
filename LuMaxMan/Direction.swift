/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
An enumeration that converts between rotations (in radians) and 4 point orientations (with Right as zero). Used when determining which animation to use for an entity's current orientation.
*/

import CoreGraphics

/// The different directions that an animated character can be facing.
enum Direction: Int {
    case Right = 0, Top, Left, Bottom
    
    /// Convenience array of all available directions.
    static let allDirections: [Direction] = [ .Right, .Top, .Left, .Bottom ]
    
    /// The angle of rotation that the orientation represents.
    var zRotation: CGFloat {
        // Calculate the number of radians between each direction.
        let stepSize = CGFloat(M_PI * 2.0) / CGFloat(Direction.allDirections.count)
        
        return CGFloat(self.rawValue) * stepSize
    }
    
    /// Creates a new `FacingDirection` for a given `zRotation` in radians.
    init(zRotation: CGFloat) {
        let twoPi = M_PI * 2
        
        // Normalize the node's rotation.
        let rotation = (Double(zRotation) + twoPi) % twoPi
        
        // Convert the rotation of the node to a percentage of a circle.
        let orientation = rotation / twoPi
        
        // Scale the percentage to a value between 0 and 4.
        let rawFacingValue = round(orientation * 4.0) % 4.0
        
        // Select the appropriate `CompassDirection` based on its members' raw values, which also run from 0 to 15.
        self = Direction(rawValue: Int(rawFacingValue))!
    }
    
    init(string: String) {
        switch string {
        case "Top":
            self = .Top
            
        case "Right":
            self = .Right
            
        case "Bottom":
            self = .Bottom
            
        case "Left":
            self = .Left
            
        default:
            fatalError("Unknown or unsupported string - \(string)")
        }
    }
}
