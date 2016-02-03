//
//  ButtonNode.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//  Abstract:
//  `ButtonNode` is a custom `SKSpriteNode` that provides button-like behavior in a SpriteKit scene. It is supported by `ButtonNodeResponderType` (a protocol for classes that can respond to button presses) and `ButtonIdentifier` (an enumeration that defines all of the kinds of buttons that are supported in the game).

import SpriteKit

/// A type that can respond to `ButtonNode` button press events.
protocol ButtonNodeResponderType: class {
    /// Responds to a button press.
    func buttonTriggered(button: ButtonNode)
}

/// The complete set of button identifiers supported in the app.
enum ButtonIdentifier: String {
    case Resume
    case Home
    case Highscore
    case Settings
    case ProceedToNextScene
    case BackToMenu
    case Replay
    case Retry
    case Cancel
    case SelectLevel
    case SelectLevel1
    case SelectLevel2
    case SelectLevel3
    case SelectLevel5
    
    /// Convenience array of all available button identifiers.
    static let allButtonIdentifiers: [ButtonIdentifier] = [
        .Resume, .Home, .Highscore, .Settings, .ProceedToNextScene, .BackToMenu, .Replay, .Retry, .Cancel, .SelectLevel, .SelectLevel1, .SelectLevel2, .SelectLevel3, .SelectLevel5
    ]
}

/// A custom sprite node that represents a press able and selectable button in a scene.
class ButtonNode: SKSpriteNode {
    // MARK: Properties
    
    /// The identifier for this button, deduced from its name in the scene.
    var buttonIdentifier: ButtonIdentifier!
    
    /**
     The scene that contains a `ButtonNode` must be a `ButtonNodeResponderType`
     so that touch events can be forwarded along through `buttonPressed()`.
     */
    var responder: ButtonNodeResponderType {
        guard let responder = scene as? ButtonNodeResponderType else {
            fatalError("ButtonNode may only be used within a `ButtonNodeResponderType` scene.")
        }
        return responder
    }
    
    /// Indicates whether the button is currently highlighted (pressed).
    var isHighlighted = false {
        // Animate to a pressed / unpressed state when the highlight state changes.
        didSet {
            // Guard against repeating the same action.
            guard oldValue != isHighlighted else { return }
            
            // Remove any existing animations that may be in progress.
            removeAllActions()
            
            // Create a scale action to make the button look like it is slightly depressed.
            let newScale: CGFloat = isHighlighted ? 0.99 : 1.01
            let scaleAction = SKAction.scaleBy(newScale, duration: 0.15)
            
            // Create a color blend action to darken the button slightly when it is depressed.
            let newColorBlendFactor: CGFloat = isHighlighted ? 1.0 : 0.0
            let colorBlendAction = SKAction.colorizeWithColorBlendFactor(newColorBlendFactor, duration: 0.15)
            
            // Run the two actions at the same time.
            runAction(SKAction.group([scaleAction, colorBlendAction]))
        }
    }
    
    var isSelected = false {
        didSet {
            // Change the texture based on the current selection state.
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    /// The texture to use when the button is not selected.
    var defaultTexture: SKTexture?
    
    /// The texture to use when the button is selected.
    var selectedTexture: SKTexture?
    
    /**
     Input focus shows which button will be triggered when the action
     button is pressed on indirect input devices such as game controllers
     and keyboards.
     */
    var isFocused = false {
        didSet {
            if isFocused {
                runAction(SKAction.scaleTo(1.08, duration: 0.20))
            }
            else {
                runAction(SKAction.scaleTo(1.0, duration: 0.20))
            }
        }
    }
    
    // MARK: Initializers
    
    /// Overridden to support `copyWithZone(_:)`.
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Ensure that the node has a supported button identifier as its name.
        guard let nodeName = name, buttonIdentifier = ButtonIdentifier(rawValue: nodeName) else {
            fatalError("Unsupported button name found.")
        }
        self.buttonIdentifier = buttonIdentifier
        
        // Remember the button's default texture (taken from its texture in the scene).
        defaultTexture = texture
        selectedTexture = texture
        
        // Enable user interaction on the button node to detect tap and click events.
        userInteractionEnabled = true
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let newButton = super.copyWithZone(zone) as! ButtonNode
        
        // Copy the `ButtonNode` specific properties.
        newButton.buttonIdentifier = buttonIdentifier
        newButton.defaultTexture = defaultTexture?.copy() as? SKTexture
        newButton.selectedTexture = selectedTexture?.copy() as? SKTexture
        
        return newButton
    }
    
    func buttonTriggered() {
        if userInteractionEnabled {
            // Forward the button press event through to the responder.
            responder.buttonTriggered(self)
        }
    }
    
    // MARK: Responder
    
    /// UIResponder touch handling.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        isHighlighted = true
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        isHighlighted = false
        
        // Touch up inside behavior.
        if containsTouches(touches) {
            buttonTriggered()
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        isHighlighted = false
    }
    
    /// Determine if any of the touches are within the `ButtonNode`.
    private func containsTouches(touches: Set<UITouch>) -> Bool {
        guard let scene = scene else { fatalError("Button must be used within a scene.") }
        
        return touches.contains { touch in
            let touchPoint = touch.locationInNode(scene)
            let touchedNode = scene.nodeAtPoint(touchPoint)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
    }
}
