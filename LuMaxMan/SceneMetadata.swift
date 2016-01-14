//
//  SceneMetadata.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract:
//  A structure to encapsulate metadata about a scene in the game.

import Foundation

/// Encapsulates the metadata about a scene in the game.
struct SceneMetadata {
    // MARK: Properties
    
    /// The base file name to use when loading the scene and related resources.
    let fileName: String
    
    /// The type to use when loading this scene (`HomeEndScene` or `LevelScene`).
    let sceneType: BaseScene.Type
    
    // MARK: Initialization
    
    /// Initializes a new `SceneMetadata` instance from a dictionary.
    init(sceneConfiguration: [String: AnyObject]) {
        fileName = sceneConfiguration["fileName"] as! String
        
        let typeIdentifier = sceneConfiguration["sceneType"] as! String
        switch typeIdentifier {
        case "LevelScene":
            sceneType = LevelScene.self
            
        case "MenuScene":
            sceneType = MenuScene.self
            
        case "SettingsScene":
            sceneType = SettingsScene.self
            
        default:
            fatalError("Unidentified sceneType requested.")
        }
    }
}

// MARK: Hashable

/*
Extend `SceneMetadata` to conform to the `Hashable` protocol so that it may be
used as a dictionary key by `SceneManager`.
*/
extension SceneMetadata: Hashable {
    var hashValue: Int {
        return fileName.hashValue
    }
}

/*
In order to be `Hashable`, `SceneMetadata` must also be `Equatable`.
This requirement is satisfied by providing an equality operator function
that takes two `SceneMetadata` instances and determines if they are equal.
*/
func ==(lhs: SceneMetadata, rhs: SceneMetadata)-> Bool {
    return lhs.hashValue == rhs.hashValue
}