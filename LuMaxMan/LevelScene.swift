//
//  LevelScene.swift
//  LuMaxMan
//
//  Created by Alexander Holzer on 15/12/15.
//
//

import GameplayKit
import CoreGraphics
import SpriteKit

/// The names and z-positions of each layer in a level's world.
enum UniLayer: CGFloat {
    // The zPosition offset to use per character (`PlayerBot` or `TaskBot`).
    static let zSpacePerCharacter: CGFloat = 100
    
    // Specifying `AboveCharacters` as 1000 gives room for 9 enemies on a level.
    case Floor = -100, Obstacles = -25, Characters = 0, AboveCharacters = 1000, Top = 1100
    
    // The expected name for this node in the scene file.
    var nodeName: String {
        switch self {
        case .Floor: return "Floor"
        case .Obstacles: return "Obstacles"
        case .Characters: return "Characters"
        case .AboveCharacters: return "AboveCharacters"
        case .Top: return "Top"
        }
    }
    
    
    // The full path to this node, for use with `childNodeWithName(_:)`.
    var nodePath: String {
        return "/Uni/\(nodeName)"
    }
    
    static var allLayers = [Floor, Obstacles, Characters, AboveCharacters, Top]
}

class LevelScene: BaseScene, SKPhysicsContactDelegate {
    // MARK: Properties
    let lumaxMan = LumaxManEntity()
    
    let pause = SKSpriteNode(imageNamed:"pause");
    
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    var upSwipe: UISwipeGestureRecognizer!
    var downSwipe: UISwipeGestureRecognizer!
    
    var uniNode: SKNode {
        return childNodeWithName("Uni")!
    }
    
    /// Stores a reference to the root nodes for each world layer in the scene.
    var uniLayerNodes = [UniLayer: SKNode]()
    
    var entities = Set<GKEntity>()
    
    var levelConfiguration: LevelConfiguration!
    
    let graph = GKObstacleGraph(obstacles: [], bufferRadius: 0)
    
    var lastUpdateTimeInterval: NSTimeInterval = 0
    let maximumUpdateDeltaTime: NSTimeInterval = 1.0 / 60.0
    
    lazy var stateMachine: GKStateMachine = GKStateMachine(states: [
        LevelSceneActiveState(levelScene: self),
        LevelScenePauseState(levelScene: self),
        LevelSceneSuccessState(levelScene: self),
        LevelSceneFailState(levelScene: self)
        ])
    
    let timerNode = SKLabelNode(text: "--:--")
    
    var gestureInput : GestureControlInputSource? = GestureControlInputSource()
    
    lazy var obstacleSpriteNodes: [SKSpriteNode] = self["\(UniLayer.Obstacles.nodePath)/*"] as! [SKSpriteNode]
    lazy var polygonObstacles: [GKPolygonObstacle] = SKNode.obstaclesFromNodePhysicsBodies(self.obstacleSpriteNodes)
    
    lazy var componentSystems: [GKComponentSystem] = {
        let movementSystem = GKComponentSystem(componentClass: MovementComponent.self)
        let animationSystem = GKComponentSystem(componentClass: AnimationComponent.self)
        let intelligenceSystem = GKComponentSystem(componentClass: IntelligenceComponent.self)
        
        // The systems will be updated in order. This order is explicitly defined to match assumptions made within components.
        return [intelligenceSystem, movementSystem, animationSystem]
    }()
    
    
    // MARK: Initializers
    
    deinit {
        unregisterForPauseNotifications()
    }
    
    // MARK: Scene Life Cycle
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        // Load the level's configuration from the level data file.
        guard let levelConfiguration = LevelConfiguration(fileName: sceneManager.currentSceneMetadata!.fileName) else {
            return
        }
        
        self.levelConfiguration = levelConfiguration
        
        // Set up the path finding graph with all polygon obstacles.
        graph.addObstacles(polygonObstacles)
        
        // Register for notifications about the app becoming inactive.
        registerForPauseNotifications()
        
        // Create references to the base nodes that define the different layers of the scene.
        loadUniLayers()
        
        addLumaxMan()
        
        addKeys()
        
        // Gravity will be in the negative z direction; there is no x or y component.
        physicsWorld.gravity = CGVector.zero
        
        // The scene will handle physics contacts itself.
        physicsWorld.contactDelegate = self
        
        // Move to the active state
        stateMachine.enterState(LevelSceneActiveState.self)
        
        // Configure the `timerNode` and add it to the camera node.
        timerNode.zPosition = UniLayer.AboveCharacters.rawValue
        timerNode.fontColor = SKColor.whiteColor()
        scaleTimerNode()
        camera!.addChild(timerNode)
        
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        upSwipe.direction = .Up
        downSwipe.direction = .Down
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(upSwipe)
        view.addGestureRecognizer(downSwipe)
        
        gestureInput?.delegate = lumaxMan.componentForClass(InputComponent.self)
        
        // Add Pause Button to Camera
        pause.name = "PauseButton";
        pause.position = CGPoint(x: size.width/2,y: size.height/2);
        pause.anchorPoint = CGPoint(x: 1, y: 1)
        pause.size = CGSize(width: 50,height: 50)
        camera!.addChild(pause)
        
    }
    
    func addKeys() {
        for keyEmptyNode in self["\(UniLayer.Characters.nodePath)/keys/*"] {
            let keyEntity = ObjectEntity()
            keyEntity.setObjectBehaviour(KeyBehaviour())
            
            // Set initial position.
            let node = keyEntity.renderComponent.node
            node.position = keyEmptyNode.position
            
            // Add the `TaskBot` to the scene and the component systems.
            addEntity(keyEntity)
        }
    }
    
    // Handle the Pause Button
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject! in touches {
            let touchLocation = touch.locationInNode(self.camera!)
            
            if (pause.containsPoint(touchLocation)) {
                stateMachine.enterState(LevelScenePauseState.self)
                
            }
        }
    }

    // Handle the buttons if the game is paused
    override func buttonTriggered(button: ButtonNode) {
        
        switch button.buttonIdentifier! {
        case .Resume:
            stateMachine.enterState(LevelSceneActiveState.self)
        
        default:
            super.buttonTriggered(button)
        }

    }
    
    
    /// Scales and positions the timer node to fit the scene's current height.
    private func scaleTimerNode() {
        // Update the font size of the timer node based on the height of the scene.
        timerNode.fontSize = size.height * 0.05
        
        // Make sure the timer node is positioned at the top of the scene.
        timerNode.position.y = (size.height / 2.0) - timerNode.frame.size.height
        print(timerNode.frame.size.height)
        // Add padding between the top of scene and the top of the timer node.
        timerNode.position.y -= timerNode.fontSize * 0.2
    }
    
    override func didChangeSize(oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        /*
        A `LevelScene` needs to update its camera constraints to match the new
        aspect ratio of the window when the window size changes.
        */
        setCameraConstraints()
    }
    
    // MARK: SKScene Processing
    
    /// Called before each frame is rendered.
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        
        // Don't perform any updates if the scene isn't in a view.
        guard view != nil else { return }
        
        // Calculate the amount of time since `update` was last called.
        var deltaTime = currentTime - lastUpdateTimeInterval
        
        // If more than `maximumUpdateDeltaTime` has passed, clamp to the maximum; otherwise use `deltaTime`.
        deltaTime = deltaTime > maximumUpdateDeltaTime ? maximumUpdateDeltaTime : deltaTime
        
        // The current time will be used as the last update time in the next execution of the method.
        lastUpdateTimeInterval = currentTime
        
        
        /*
        Don't evaluate any updates if the `worldNode` is paused.
        Pausing a subsection of the node tree allows the `camera`
        and `overlay` nodes to remain interactive.
        */
        if uniNode.paused { return }
        
        // Update the level's state machine.
        stateMachine.updateWithDeltaTime(deltaTime)
        
        /*
        Update each component system.
        The order of systems in `componentSystems` is important
        and was determined when the `componentSystems` array was instantiated.
        */
        for componentSystem in componentSystems {
            componentSystem.updateWithDeltaTime(deltaTime)
        }
    }
    
    override func didFinishUpdate() {
        // Sort the entities in the scene by ascending y-position.
        let ySortedEntities = entities.sort {
            let nodeA = $0.0.componentForClass(RenderComponent.self)!.node
            let nodeB = $0.1.componentForClass(RenderComponent.self)!.node
            
            return nodeA.position.y > nodeB.position.y
        }
        
        // Set the `zPosition` of each entity so that entities with a higher y-position are rendered above those with a lower y-position.
        var characterZPosition = UniLayer.zSpacePerCharacter
        for entity in ySortedEntities {
            let node = entity.componentForClass(RenderComponent.self)!.node
            node.zPosition = characterZPosition
            
            // Use a large enough z-position increment to leave space for emitter effects.
            characterZPosition += UniLayer.zSpacePerCharacter
        }
    }
    
    // MARK: Level Construction
    
    func loadUniLayers() {
        for uniLayer in UniLayer.allLayers {
            // Try to find a matching node for this world layer's node name.
            let foundNodes = self[uniLayer.nodePath]
            
            // Make sure it was possible to find a node with this name.
            precondition(!foundNodes.isEmpty, "Could not find a world layer node for \(uniLayer.nodeName)")
            
            // Retrieve the actual node.
            let layerNode = foundNodes.first!
            
            // Make sure that the node's `zPosition` is correct relative to the other world layers.
            layerNode.zPosition = uniLayer.rawValue
            
            // Store a reference to the retrieved node.
            uniLayerNodes[uniLayer] = layerNode
        }
    }
    
    // MARK: Convenvience
    
    /// Constrains the camera to follow LumaxMan without approaching the scene edges.
    private func setCameraConstraints() {
        // Don't try to set up camera constraints if we don't yet have a camera.
        guard let camera = camera else { return }
        
        // Constrain the camera to stay a constant distance of 0 points from the player node.
        let zeroRange = SKRange(constantValue: 0.0)
        let playerNode = lumaxMan.renderComponent.node
        let playerBotLocationConstraint = SKConstraint.distance(zeroRange, toNode: playerNode)
        
        /*
        Also constrain the camera to avoid it moving to the very edges of the scene.
        First, work out the scaled size of the scene. Its scaled height will always be
        the original height of the scene, but its scaled width will vary based on
        the window's current aspect ratio.
        */
        //let scaledSize = CGSize(width: size.width * camera.xScale, height: size.height * camera.yScale)
        
        /*
        Find the root "floor" node in the scene (the container node for
        the level's background tiles).
        */
        //let floorNode = childNodeWithName(UniLayer.Floor.nodePath)!
        
        /*
        Calculate the accumulated frame of this node.
        The accumulated frame of a node is the outer bounds of all of the node's
        child nodes, i.e. the total size of the entire contents of the node.
        This gives us the bounding rectangle for the level's environment.
        */
        //let floorContentRect = floorNode.calculateAccumulatedFrame()
        
        /*
        Work out how far within this rectangle to constrain the camera.
        We want to stop the camera when we get within 100pts of the edge of the screen,
        unless the level is so small that this inset would be outside of the level.
        */
        //let xInset = min((scaledSize.width / 2) - 100.0, floorContentRect.width / 2)
        //let yInset = min((scaledSize.height / 2) - 100.0, floorContentRect.height / 2)
        
        // Use these insets to create a smaller inset rectangle within which the camera must stay.
        //let insetContentRect = floorContentRect.insetBy(dx: xInset, dy: yInset)
        
        // Define an `SKRange` for each of the x and y axes to stay within the inset rectangle.
        //let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
        //let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
        
        // Constrain the camera within the inset rectangle.
        //let levelEdgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        //levelEdgeConstraint.referenceNode = floorNode
        
        /*
        Add both constraints to the camera. The scene edge constraint is added
        second, so that it takes precedence over following the `PlayerBot`.
        The result is that the camera will follow the player, unless this would mean
        moving too close to the edge of the level.
        */
        camera.constraints = [playerBotLocationConstraint/*, levelEdgeConstraint*/]
    }
    
    private func addLumaxMan() {
        // Find the location of the player's initial position.
        let charactersNode = childNodeWithName(UniLayer.Characters.nodePath)!
        let transporter = charactersNode.childNodeWithName("LumaxMan")!
        
        // Set the initial orientation.
        guard let orientationComponent = lumaxMan.componentForClass(OrientationComponent.self) else {
            fatalError("A LumaxMan must have an orientation component to be able to be added to a level")
        }
        orientationComponent.direction = levelConfiguration.initialLumaxManOrientation
        lumaxMan.missingKeys = levelConfiguration.numberOfKeys
        
        // Set up the `PlayerBot` position in the scene.
        let playerNode = lumaxMan.renderComponent.node
        playerNode.position = transporter.position
        
        // Constrain the camera to the `PlayerBot` position and the level edges.
        setCameraConstraints()
        
        // Add the `lumaxMan` to the scene and component systems.
        addEntity(lumaxMan)
    }
    
    func addEntity(entity: GKEntity) {
        entities.insert(entity)
        
        for componentSystem in self.componentSystems {
            componentSystem.addComponentWithEntity(entity)
        }
        
        // If the entity has a `RenderComponent`, add its node to the scene.
        if let renderNode = entity.componentForClass(RenderComponent.self)?.node {
            addNode(renderNode, toUniLayer: .Characters)
        }
        
        // If the entity has an `IntelligenceComponent`, enter its initial state.
        if let intelligenceComponent = entity.componentForClass(IntelligenceComponent.self) {
            intelligenceComponent.enterInitialState()
        }
    }
    
    func addNode(node: SKNode, toUniLayer uniLayer: UniLayer) {
        let uniLayerNode = uniLayerNodes[uniLayer]!
        
        uniLayerNode.addChild(node)
    }
    
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        
        gestureInput?.move(sender.direction)
        
        
    }
    
    
    // MARK: SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        handleContact(contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity?) in
            ContactNotifiableType.contactWithEntityDidBegin(otherEntity)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        handleContact(contact) { (ContactNotifiableType: ContactNotifiableType, otherEntity: GKEntity?) in
            ContactNotifiableType.contactWithEntityDidEnd(otherEntity)
        }
    }
    
    // MARK: SKPhysicsContactDelegate convenience
    
    private func handleContact(contact: SKPhysicsContact, contactCallback: (ContactNotifiableType, GKEntity?) -> Void) {
        // Get the `ColliderType` for each contacted body.
        let colliderTypeA = ColliderType(rawValue: contact.bodyA.categoryBitMask)
        let colliderTypeB = ColliderType(rawValue: contact.bodyB.categoryBitMask)
        
        // Determine which `ColliderType` should be notified of the contact.
        let aWantsCallback = colliderTypeA.notifyOnContactWithColliderType(colliderTypeB)
        let bWantsCallback = colliderTypeB.notifyOnContactWithColliderType(colliderTypeA)
        
        // Make sure that at least one of the entities wants to handle this contact.
        assert(aWantsCallback || bWantsCallback, "Unhandled physics contact - A = \(colliderTypeA), B = \(colliderTypeB)")
        
        let entityA = (contact.bodyA.node as? EntityNode)?.entity
        let entityB = (contact.bodyB.node as? EntityNode)?.entity
        
        /*
        If `entityA` is a notifiable type and `colliderTypeA` specifies that it should be notified
        of contact with `colliderTypeB`, call the callback on `entityA`.
        */
        if let notifiableEntity = entityA as? ContactNotifiableType where aWantsCallback {
            contactCallback(notifiableEntity, entityB)
        }
        
        /*
        If `entityB` is a notifiable type and `colliderTypeB` specifies that it should be notified
        of contact with `colliderTypeA`, call the callback on `entityB`.
        */
        if let notifiableEntity = entityB as? ContactNotifiableType where bWantsCallback {
            contactCallback(notifiableEntity, entityA)
        }
    }
}










