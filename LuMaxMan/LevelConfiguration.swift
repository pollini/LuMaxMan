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
    // MARK: Type for the starting configuration of a single Enemy.
    struct EnemyConfiguration {
        // MARK: Properties
        let isFollowing: Bool
        let waitingTime: Double
        let updatingTime: Double
        
        // MARK: Initialization
        init(enemyConfigInfo: [String: AnyObject]) {
            isFollowing = true
            waitingTime = enemyConfigInfo["initialWaitingTime"] as! Double
            updatingTime = enemyConfigInfo["updatingTime"] as! Double
        }
    }
    
    // MARK: Properties
    
    /// Cached data loaded from the level's data file.
    private let configurationInfo: [String: AnyObject]
    
    // The configuration settings for Enemys on this level.
    let enemyConfigurations: [EnemyConfiguration]
    
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
        return configurationInfo["numberOfKeysToComplete"] as! Int
    }
    // MARK: Initialization
    
    init?(fileName: String) {
        self.fileName = fileName
        
        let url = NSBundle.mainBundle().URLForResource(fileName, withExtension: "plist")!
        
        guard let configurationInfo = NSDictionary(contentsOfURL: url) as? [String: AnyObject] else {
            return nil
        }
        
        self.configurationInfo = configurationInfo
        
        // Map the array of EnemyConfiguration dictionaries to an array of EnemyConfiguration instances.
        let eConfig = configurationInfo["enemyConfigurations"] as! [[String: AnyObject]]
        
        enemyConfigurations = eConfig.map { EnemyConfiguration(enemyConfigInfo: $0)}
    }
}