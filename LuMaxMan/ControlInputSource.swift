//
//  ControlInputSource.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract:
//  Protocols that manage and respond to control input

import simd

enum ControlInputDirection: Int {
    case Up = 0, Down, Left, Right
    
    init?(vector: float2) {
        // Require sufficient displacement to specify direction.
        guard length(vector) >= 0.5 else { return nil }
        
        // Take the max displacement as the specified axis.
        if abs(vector.x) > abs(vector.y) {
            self = vector.x > 0 ? .Right : .Left
        }
        else {
            self = vector.y > 0 ? .Up : .Down
        }
    }
}

/// Delegate methods for responding to control input that applies to the game as a whole.
protocol ControlInputSourceGameStateDelegate: class {
    func controlInputSourceDidTogglePauseState(controlInputSource: ControlInputSourceType)
}

/// Delegate methods for responding to control input that applies to the `PlayerBot`.
protocol ControlInputSourceDelegate: class {
    /**
     Update the `ControlInputSourceDelegate` with new displacement
     in a top down 2D coordinate system (x, y):
     Up:    (0.0, 1.0)
     Down:  (0.0, -1.0)
     Left:  (-1.0, 0.0)
     Right: (1.0, 0.0)
     */
    func updateDisplacement(displacement: float2)
}

/// A protocol to be adopted by classes that provide control input and notify their delegates when input is available.
protocol ControlInputSourceType: class {
    /// A delegate that receives information about actions that apply to the `PlayerBot`.
    weak var delegate: ControlInputSourceDelegate? { get set }
    
    /// A delegate that receives information about actions that apply to the game as a whole.
    weak var gameStateDelegate: ControlInputSourceGameStateDelegate? { get set }
}