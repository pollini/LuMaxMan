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
    static func behaviorForAgent(agent: GKAgent2D, followingAgent lumaxmanAgent: GKAgent2D, avoidingAgents enemyAgents: [EnemyAgent], inScene scene: LevelScene) -> GKBehavior {
        
        let behavior = EnemyBehavior()
        
        behavior.setSpeed(agent)
        
        // The goal for following LumaxMan.
        behavior.setWeight(0.9, forGoal: GKGoal(toSeekAgent: lumaxmanAgent))
        
        // The goal for avoiding other enemies.
        //behavior.setWeight(0.75, forGoal: GKGoal(toAvoidAgents: enemyAgents, maxPredictionTime: 1.0))
        
        behavior.avoidObstaclesForScene(scene)
        
        return behavior
    }
    
    static func behaviorForAgent(agent: GKAgent2D, escapingFromAgent lumaxmanAgent: GKAgent2D, inScene scene: LevelScene) -> GKBehavior {
        let behavior = EnemyBehavior()
        
        behavior.setSpeed(agent)
        
        behavior.setWeight(0.9, forGoal: GKGoal(toFleeAgent: lumaxmanAgent))
        
        behavior.avoidObstaclesForScene(scene)
        
        return behavior
    }
    
    
    private func setSpeed(agent: GKAgent2D) {
        // Adds a goal to reach a specific speed.
        setWeight(0.25, forGoal: GKGoal(toReachTargetSpeed: agent.maxSpeed))
    }
    
    private func avoidObstaclesForScene(scene: LevelScene) {
        setWeight(1.0, forGoal: GKGoal(toAvoidObstacles: scene.polygonObstacles, maxPredictionTime: 1.0))
    }
}
