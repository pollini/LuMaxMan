//
//  SceneManager.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract: 
//  `SceneManager` is responsible for presenting scenes

import SpriteKit

protocol SceneManagerDelegate: class {
    // Called whenever a scene manager has transitioned to a new scene.
    func sceneManagerDidTransitionToScene(scene: SKScene)
}

/**
 A manager for presenting `BaseScene`s. This allows for the preloading of future
 levels while the player is in game to minimize the time spent between levels.
 */
final class SceneManager {
    // MARK: Types
    
    enum SceneIdentifier {
        case Home, End
        case Settings
        case CurrentLevel, NextLevel
        case Level(Int)
        case SelectLevel
    }
    
    // MARK: Properties
    
    /// The view used to choreograph scene transitions.
    let presentingView: SKView
    
    /// The next scene, assuming linear level progression.
    var nextSceneMetadata: SceneMetadata {
        let homeScene = sceneMetadataForSceneIdentifier(.Home)
        
        // If there is no current scene, we can only transition back to the home scene.
        guard let currentSceneMetadata = currentSceneMetadata else { return homeScene }
        let index = sceneConfigurationInfo.indexOf(currentSceneMetadata)!
        
        if index + 1 < sceneConfigurationInfo.count {
            // Return the metadata for the next scene in the array.
            return sceneConfigurationInfo[index + 1]
        }
        
        // Otherwise, loop back to the home scene.
        return homeScene
    }
    
    /// The `SceneManager`'s delegate.
    weak var delegate: SceneManagerDelegate?
    
    /// The scene that is currently being presented.
    private (set) var currentSceneMetadata: SceneMetadata?
    
    /// Cached array of scene structure loaded from "SceneConfiguration.plist".
    private let sceneConfigurationInfo: [SceneMetadata]
    
    /// An object to act as the observer for `SceneLoaderDidCompleteNotification`s.
    private var loadingCompletedObserver: AnyObject?
    
    // MARK: Initialization
    
    init(presentingView: SKView) {
        self.presentingView = presentingView
        
        /*
        Load the game's `SceneConfiguration` plist. This provides information
        about every scene in the game, and the order in which they should be displayed.
        */
        let url = NSBundle.mainBundle().URLForResource("SceneConfiguration", withExtension: "plist")!
        let scenes = NSArray(contentsOfURL: url) as! [[String: AnyObject]]
        
        /*
        Extract the configuration info dictionary for each possible scene,
        and create a `SceneMetadata` instance from the contents of that dictionary.
        */
        sceneConfigurationInfo = scenes.map {
            SceneMetadata(sceneConfiguration: $0)
        }
    }
    
    // MARK: Scene Presentation
    
    /// Configures and presents a scene.
    func transitionToSceneWithSceneIdentifier(sceneIdentifier: SceneIdentifier) {
        
        guard let scene = sceneForSceneIdentifier(sceneIdentifier) else {
            assertionFailure("Requested presentation for a `sceneMetdata` without a valid `scene`.")
            return
        }
        
        currentSceneMetadata = sceneMetadataForSceneIdentifier(sceneIdentifier)
        
        // Ensure we present the scene on the main queue.
        dispatch_async(dispatch_get_main_queue()) {
            /*
            Provide the scene with a reference to the `SceneLoadingManger`
            so that it can coordinate the next scene that should be loaded.
            */
            scene.sceneManager = self
            
            // Present the scene with a transition.
            let transition = SKTransition.fadeWithDuration(GameplayConfiguration.SceneManager.transitionDuration)
            self.presentingView.presentScene(scene, transition: transition)
            
            // Notify the delegate that the manager has presented a scene.
            self.delegate?.sceneManagerDidTransitionToScene(scene)
        }
    }
    
    /// Determines all possible scenes that the player may reach after the current scene.
    private func allPossibleNextScenes() -> Set<SceneMetadata> {
        let homeScene = sceneConfigurationInfo.first!
        
        // If there is no current scene, we can only go to the home scene.
        guard let currentSceneMetadata = currentSceneMetadata else {
            return [homeScene]
        }
        
        //the user can always go home or replay the level
        return [homeScene, nextSceneMetadata, currentSceneMetadata]
    }
    
    // MARK: Convenience
    
    /// Returns the scene loader associated with the scene identifier.
    func sceneForSceneIdentifier(sceneIdentifier: SceneIdentifier) -> BaseScene? {
        let sceneMetadata = sceneMetadataForSceneIdentifier(sceneIdentifier)
        let baseScene = sceneMetadata.sceneType.init(fileNamed: sceneMetadata.fileName)
        
        baseScene?.createCamera()
        
        return baseScene
    }
    
    func sceneMetadataForSceneIdentifier(sceneIdentifier: SceneIdentifier) -> SceneMetadata {
        let sceneMetadata: SceneMetadata
        
        switch sceneIdentifier {
        case .Home:
            sceneMetadata = sceneConfigurationInfo[2]
            
        case .Settings:
            sceneMetadata = sceneConfigurationInfo.first!
            
        case .SelectLevel:
            sceneMetadata = sceneConfigurationInfo[1]
            
        case .CurrentLevel:
            guard let currentSceneMetadata = currentSceneMetadata else {
                fatalError("Current scene doesn't exist.")
            }
            sceneMetadata = currentSceneMetadata
            
        case .Level(let number):
            sceneMetadata = sceneConfigurationInfo[number+2]
            
        case .NextLevel:
            sceneMetadata = nextSceneMetadata
            
        case .End:
            sceneMetadata = sceneConfigurationInfo.last!
            
        }
        
        return sceneMetadata
    }
}
