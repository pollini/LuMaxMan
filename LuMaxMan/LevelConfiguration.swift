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
    
    // MARK: Initialization
    
    init(fileName: String) {
        self.fileName = fileName
        
        let url = NSBundle.mainBundle().URLForResource(fileName, withExtension: "plist")!
        
        configurationInfo = NSDictionary(contentsOfURL: url) as! [String: AnyObject]
        
        //let botConfigurations = configurationInfo["taskBotConfigurations"] as! [[String: AnyObject]]
    }
}