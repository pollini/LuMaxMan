//
//  EnemyBehavior.swift
//  LuMaxMan
//
//  Created by Marius on 21.01.16.
//
//

import SpriteKit
import GameplayKit

class EnemyBehavior: GKBehavior {
    
    // Intial Behavior. Gets "overriden" when all character entities are finally created or when they are changing states.
    static func initialBehaviorForAgent(agent: GKAgent2D,/*huntingAgentOf target: GKAgent2D,*/ inScene scene: LevelScene) -> GKBehavior {
        let behavior = EnemyBehavior()
        
        behavior.setSpeed(agent)
        
        // Adds a goal to randomly walk around (in the first place).
        behavior.setWeight(0.5, forGoal: GKGoal(toWander: agent.maxSpeed))
        
        // Most important: avoid the obstacles!
        behavior.avoidObstaclesForScene(scene)
        
        return behavior
    }
    
    // Behavior for following/hunting LumaxMan, avoiding obstacles and preferably avoid other enemy agents as well
    static func behaviorForAgent(agent: GKAgent2D, followingAgent targetAgent: GKAgent2D, avoidingAgents enemyAgents: [EnemyAgent], inScene scene: LevelScene) -> GKBehavior {
        
        let behavior = EnemyBehavior()
        
        behavior.setSpeed(agent)
        behavior.avoidObstaclesForScene(scene)
        
        //behavior.addGoalsToFollowPathFromStartPoint(agent.position, toEndPoint: targetAgent.position, pathRadius: 10.0, inScene: scene)
        //print("\(targetAgent.position)")
        
        // The goal for following LumaxMan.
        //behavior.setWeight(0.08, forGoal: GKGoal(toSeekAgent: targetAgent))
        behavior.setWeight(0.09, forGoal: GKGoal(toInterceptAgent: targetAgent, maxPredictionTime: 1.0))
        
        // The goal for avoiding other enemies.
        //behavior.setWeight(1.0, forGoal: GKGoal(toAvoidAgents: enemyAgents, maxPredictionTime: 1.0))
        //behavior.setWeight(1.0, forGoal: GKGoal(toSeparateFromAgents: enemyAgents, maxDistance: 50.0, maxAngle: 0.5))
        
        
        return behavior
    }
    
    static func behaviorForAgent(agent: GKAgent2D, escapingFromAgent lumaxmanAgent: GKAgent2D, inScene scene: LevelScene) -> GKBehavior {
        let behavior = EnemyBehavior()
        
        behavior.setSpeed(agent)
        
        behavior.setWeight(0.9, forGoal: GKGoal(toFleeAgent: lumaxmanAgent))
        
        behavior.avoidObstaclesForScene(scene)
        
        return behavior
    }
    
    
    // MARK: Helpers
    
    private func setSpeed(agent: GKAgent2D) {
        // Adds a goal to reach a specific speed.
        setWeight(0.025, forGoal: GKGoal(toReachTargetSpeed: agent.maxSpeed))
    }
    
    private func avoidObstaclesForScene(scene: LevelScene) {
        // Adds a goal to avoid all obstacles of a level.
        setWeight(1.0, forGoal: GKGoal(toAvoidObstacles: scene.polygonObstacles, maxPredictionTime: 1.0))
    }
    
    /// Pathfinds around obstacles to create a path between two points, and adds goals to follow that path.
    private func addGoalsToFollowPathFromStartPoint(startPoint: float2, toEndPoint endPoint: float2, pathRadius: Float, inScene scene: LevelScene) {
        
        // Convert the provided `CGPoint`s into nodes for the `GPGraph`.
        guard let startNode = connectedNodeForPoint(startPoint, onObstacleGraphInScene: scene),
            endNode = connectedNodeForPoint(endPoint, onObstacleGraphInScene: scene) else {
                return
        }
        
        // Remove the "start" and "end" nodes when exiting this scope.
        defer { scene.graph.removeNodes([startNode, endNode]) }
        
        // Find a path between these two nodes.
        let pathNodes = scene.graph.findPathFromNode(startNode, toNode: endNode) as! [GKGraphNode2D]
        
        // A valid `GKPath` can not be created if fewer than 2 path nodes were found, return.
        guard pathNodes.count > 1 else {
            return
        }
        
        // Create a new `GKPath` from the found nodes with the requested path radius.
        let path = GKPath(graphNodes: pathNodes, radius: pathRadius)
        
        // Add "follow path" and "stay on path" goals for this path.
        addFollowAndStayOnPathGoalsForPath(path)
        
    }
    
    private func connectedNodeForPoint(point: float2, onObstacleGraphInScene scene: LevelScene) -> GKGraphNode2D? {
        // Create a graph node for this point.
        let pointNode = GKGraphNode2D(point: point)
        
        // Try to connect this node to the graph.
        scene.graph.connectNodeUsingObstacles(pointNode)
        
        /*
        Check to see if we were able to connect the node to the graph.
        If not, this means that the point is inside the buffer zone of an obstacle
        somewhere in the level. We can't pathfind to a point that is off-graph,
        so we try to find the nearest point that is on the graph, and pathfind
        to there instead.
        */
        if pointNode.connectedNodes.isEmpty {
            // The previous connection attempt failed, so remove the node from the graph.
            scene.graph.removeNodes([pointNode])
            
            // Search the graph for all intersecting obstacles.
            let intersectingObstacles = extrudedObstaclesContainingPoint(point, inScene: scene)
            
            /*
            Connect this node to the graph ignoring the buffer radius of any
            obstacles that the point is currently intersecting.
            */
            scene.graph.connectNodeUsingObstacles(pointNode, ignoringBufferRadiusOfObstacles: intersectingObstacles)
            
            // If still no connection could be made, return `nil`.
            if pointNode.connectedNodes.isEmpty {
                scene.graph.removeNodes([pointNode])
                return nil
            }
        }
        
        return pointNode
    }
    
    private func extrudedObstaclesContainingPoint(point: float2, inScene scene: LevelScene) -> [GKPolygonObstacle] {
        
        let extrusionRadius = Float(35)
        
        /*
        Return only the polygon obstacles which contain the specified point.
        
        Note: This creates a bounding box around the polygon obstacle to check
        for intersection, but a more specific check may be necessary.
        */
        return scene.polygonObstacles.filter { obstacle in
            // Retrieve all vertices for the polygon obstacle.
            let range = Range(start: 0, end: obstacle.vertexCount)
            
            let polygonVertices = range.map { obstacle.vertexAtIndex($0) }
            guard !polygonVertices.isEmpty else { return false }
            
            let maxX = polygonVertices.maxElement { $0.x < $1.x }!.x + extrusionRadius
            let maxY = polygonVertices.maxElement { $0.y < $1.y }!.y + extrusionRadius
            
            let minX = polygonVertices.minElement { $0.x < $1.x }!.x - extrusionRadius
            let minY = polygonVertices.minElement { $0.y < $1.y }!.y - extrusionRadius
            
            return (point.x > minX && point.x < maxX) && (point.y > minY && point.y < maxY)
        }
    }
    
    /// Adds goals to follow and stay on a path.
    private func addFollowAndStayOnPathGoalsForPath(path: GKPath) {
        // The "follow path" goal tries to keep the agent facing in a forward direction when it is on this path.
        setWeight(1.0, forGoal: GKGoal(toFollowPath: path, maxPredictionTime: 1.0, forward: true))
        
        // The "stay on path" goal tries to keep the agent on the path within the path's radius.
        //setWeight(1.0, forGoal: GKGoal(toStayOnPath: path, maxPredictionTime: 1.0))
    }
}
