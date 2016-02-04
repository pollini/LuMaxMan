//
//  BaseScene.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
// Abstract:
//  The base class for all scenes in the app.

import SpriteKit

/**
 A base class for all of the scenes in the app.
 */
class BaseScene: SKScene, ControlInputSourceGameStateDelegate, ButtonNodeResponderType {
    // MARK: Properties
    
    /**
    The native size for this scene. This is the height at which the scene
    would be rendered if it did not need to be scaled to fit a window or device.
    Defaults to `zeroSize`; the actual value to use is set in `createCamera()`.
    */
    var nativeSize = CGSize.zero
    
    /**
     The background node for this `BaseScene` if needed. Provided by those subclasses
     that use a background scene in their SKS file to center the scene on screen.
     */
    var backgroundNode: SKSpriteNode? {
        return nil
    }
    
    /// All buttons currently in the scene. Updated by assigning the result of `findAllButtonsInScene()`.
    var buttons = [ButtonNode]()
    
    /**
     A flag to indicate if focus based navigation is currently enabled. Also
     used to ensure buttons are navigated at a reasonable rate by toggling this
     flag after a short delay in `controlInputSource(_: didSpecifyDirection:)`.
     */
    var focusChangesEnabled = false
    
    /// The current scene overlay (if any) that is displayed over this scene.
    var overlay: SceneOverlay? {
        didSet {
            // Clear the `buttons` in preparation for new buttons in the overlay.
            buttons = []
            
            if let overlay = overlay, camera = camera {
                overlay.backgroundNode.removeFromParent()
                camera.addChild(overlay.backgroundNode)
                
                // Animate the overlay in.
                overlay.backgroundNode.alpha = 0.0
                overlay.backgroundNode.runAction(SKAction.fadeInWithDuration(0.25))
                overlay.updateScale()
                
                buttons = findAllButtonsInScene()
            }
            
            // Animate the old overlay out.
            oldValue?.backgroundNode.runAction(SKAction.fadeOutWithDuration(0.25)) {
                oldValue?.backgroundNode.removeFromParent()
            }
        }
    }
    
    /// A reference to the scene manager for scene progression.
    weak var sceneManager: SceneManager!
    
    // MARK: SKScene Life Cycle
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        updateCameraScale()
        overlay?.updateScale()
        
        // Find all the buttons and set the initial focus.
        buttons = findAllButtonsInScene()
    }
    
    override func didChangeSize(oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        updateCameraScale()
        overlay?.updateScale()
    }
    
    // MARK: ControlInputSourceDelegate
    
    func controlInputSourceDidTogglePauseState(controlInputSource: ControlInputSourceType) {
        // Subclasses implement to toggle pause state.
    }
    
    // MARK: Camera Actions
    
    /**
    Creates a camera for the scene, and updates its scale.
    This method should be called when initializing an instance of a `BaseScene` subclass.
    */
    func createCamera() {
        if let backgroundNode = backgroundNode {
            // If the scene has a background node, use its size as the native size of the scene.
            nativeSize = backgroundNode.size
        }
        else {
            // Otherwise, use the scene's own size as the native size of the scene.
            nativeSize = size
        }
        
        if self.camera == nil {
            let camera = SKCameraNode()
            self.camera = camera
            addChild(camera)
        }
        
        updateCameraScale()
    }
    
    /// Centers the scene's camera on a given point.
    func centerCameraOnPoint(point: CGPoint) {
        if let camera = camera {
            camera.position = point
        }
    }
    
    /// Scales the scene's camera.
    func updateCameraScale() {
        /*
        Because the game is normally playing in landscape, use the scene's current and
        original heights to calculate the camera scale.
        */
        if let camera = camera {
            camera.setScale(nativeSize.height / size.height)
        }
    }
    
    
    /// Searches the scene for all `ButtonNode`s.
    func findAllButtonsInScene() -> [ButtonNode] {
        return ButtonIdentifier.allButtonIdentifiers.flatMap { buttonIdentifier in
            childNodeWithName("//\(buttonIdentifier.rawValue)") as? ButtonNode
        }
    }
    
    // MARK: ButtonNodeResponderType
    
    func buttonTriggered(button: ButtonNode) {
        switch button.buttonIdentifier! {
        case .Home:
            sceneManager.transitionToSceneWithSceneIdentifier(.Home)
            
        case .Settings:
            sceneManager.transitionToSceneWithSceneIdentifier(.Settings)
            
        case .ProceedToNextScene:
            sceneManager.transitionToSceneWithSceneIdentifier(.NextLevel)
            
        case .Replay:
            sceneManager.transitionToSceneWithSceneIdentifier(.CurrentLevel)
            
        case .BackToMenu:
            sceneManager.transitionToSceneWithSceneIdentifier(.Home)
            
        case .Retry:
            sceneManager.transitionToSceneWithSceneIdentifier(.CurrentLevel)
            
        case .SelectLevel:
            sceneManager.transitionToSceneWithSceneIdentifier(.SelectLevel)
            
        case .Highscore:
            guard let rootViewController = self.view?.window?.rootViewController,
                let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("highscoreNC") as? UINavigationController
                else {
                    return
            }
            
            guard let highscoreController = controller.visibleViewController as? HighscoreViewController else { return }
            
            highscoreController.setCallerViewController(rootViewController)
            
            rootViewController.modalTransitionStyle = .CoverVertical
            rootViewController.modalPresentationStyle = .CurrentContext
            rootViewController.presentViewController(controller, animated: true, completion: nil)
            
        case .SelectLevel1:
            sceneManager.transitionToSceneWithSceneIdentifier(.Level(1))
            
        case .SelectLevel2:
            sceneManager.transitionToSceneWithSceneIdentifier(.Level(2))
            
        case .SelectLevel3:
            sceneManager.transitionToSceneWithSceneIdentifier(.Level(3))
        
        case .SelectLevel4:
            sceneManager.transitionToSceneWithSceneIdentifier(.Level(4))
            
        case .SelectLevel5:
            sceneManager.transitionToSceneWithSceneIdentifier(.Level(5))
            
        default:
            fatalError("Unsupported ButtonNode type in Scene.")
        }
    }
}
