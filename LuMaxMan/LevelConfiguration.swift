//
//  LevelConfiguration.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 16/12/15.
//
//

import Foundation

/// Encapsulates the starting configuration of a level in the game.
struct LevelConfiguration {
    // MARK: Properties
    
    /// Cached data loaded from the level's data file.
    private let configurationInfo: [String: AnyObject]
    
    /// The file name identifier for this level. Used for loading files and assets.
    let fileName: String
    
    /// The initial orientation of the `LumaxMan` when the level is first loaded.
    var initialLumaxManOrientation: Direction {
        return Direction(string: (configurationInfo["initialLumaxManOrientation"] as! String))
    }
    
    //The time to complete the level
    var timeLimit: NSTimeInterval {
        return configurationInfo["timeLimit"] as! NSTimeInterval
    }
    
    //The number of keys to complete the level
    var numberOfKeys: Int {
        return configurationInfo["numberOfKeys"] as! Int
    }
    // MARK: Initialization
    
    init?(fileName: String) {
        self.fileName = fileName
        
        let url = NSBundle.mainBundle().URLForResource(fileName, withExtension: "plist")!
        
        guard let configurationInfo = NSDictionary(contentsOfURL: url) as? [String: AnyObject] else {
            return nil
        }
        
        self.configurationInfo = configurationInfo
    }
}