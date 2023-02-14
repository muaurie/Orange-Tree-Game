//
//  GameScene.swift
//  Orange-Tree-Game
//
//  Created by Cherish Spikes on 2/1/23.
//

import SpriteKit

class GameScene: SKScene {
    var orangeTree: SKSpriteNode!
    var orange: Orange?
    //create property to store where touch begins
    var touchStart: CGPoint = .zero //xcode knows that is has the type of CGPoint, because type already declared
    //so no need to write var touchStart: CGPoint = CGPoint.zero
    //add a shapenode that will hold the shape of the line and draw it on the scene
    var shapeNode = SKShapeNode()
    //create a boundary for the oranges to stay within the edge of the game
    var boundary = SKNode()
    var numOfLevels: UInt32 = 3
    
    
    override func didMove(to view: SKView) {
        orangeTree = childNode(withName: "tree") as? SKSpriteNode
        //configure the shape node and add as a child of the scene
        shapeNode.lineWidth = 20
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
        
        //add the Sun to the scene
        let sun = SKSpriteNode(imageNamed: "Sun")
        sun.name = "sun"
        sun.position.x = size.width / 2 - (sun.size.width * 0.75)
        sun.position.y = size.height / 2 - (sun.size.width * 0.75)
        addChild(sun)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //getting the location of the touch on the screen
        let touch = touches.first!
        let location = touch.location(in: self)
    //check that the touch was on the orange tree
        if atPoint(location).name == "tree" {
            orange = Orange()
            orange?.physicsBody?.isDynamic = false //ensures that orange doesn't get affected by gravity until
            //- you are ready to throw it.
            orange?.position = location
            addChild(orange!)
    //store the location of the touch for later
        touchStart = location
    //give the orange an impulse to mke it fly -> deleted later
         //   let vector = CGVector(dx: 100, dy: 0)
          //  orange?.physicsBody?.applyImpulse(vector)
        }
        // Check if the sun was tapped and change the level
        for node in nodes(at: location) {
          if node.name == "sun" {
            let n = Int(arc4random() % numOfLevels + 1)
            if let scene = GameScene.Load(level: n) {
              scene.scaleMode = .aspectFill
              if let view = view {
                view.presentScene(scene)
              }
            }
          }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //get locaiton of touch
        let touch = touches.first!
        let location = touch.location(in: self)
        // update the Orange position to current locaiton
        orange?.position = location
        //draw the firing vector, create a path between touchStart and location
        let path = UIBezierPath()
        path.move(to: touchStart)
        path.addLine(to: location)
        shapeNode.path = path.cgPath
    }
    //When the user stops finger movement and lets go, the orange should go flying:
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //get location of where the touch ended
        let touch = touches.first!
        let location = touch.location(in: self)
        //get the difference between start and end point
        let dx = (touchStart.x - location.x) * 0.5
        let dy = (touchStart.y - location.y) * 0.5
        let vector = CGVector(dx: dx, dy: dy)
        
        //set orange dynamic again AND apply vector as an impulse
        orange?.physicsBody?.isDynamic = true
        orange?.physicsBody?.applyImpulse(vector)
        // remove the path from ShapeNode when touch ends
        shapeNode.path = nil
    }
}
//class extensions can extend the functionality of a class and organize code
extension GameScene: SKPhysicsContactDelegate {
    //called when the physicsWorld (engine) detects two nodes colliding
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        //check that the bodies collided hard enough, force is necessary for gamepla
        if contact.collisionImpulse > 15 {
            if nodeA?.name == "skull" {
                removeSkull(node: nodeA!)
                skullDestroyedParticles(point: nodeA!.position)
            } else if nodeB?.name == "skull" {
                removeSkull(node: nodeB!)
                skullDestroyedParticles(point: nodeA!.position)
            }
        }
    }
    //define function used to remove skull from scene
    func removeSkull(node: SKNode) {
        node.removeFromParent()
        
        //set the contact delegate
        physicsWorld.contactDelegate = self
    // define boundary
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
        let background = childNode(withName: "background") as? SKSpriteNode
        boundary.position = CGPoint(x: (background?.size.width ?? 0) / -2, y: (background?.size.height ?? 0) / -2)
        addChild(boundary)
    }
    //class method to load .sks files
    static func Load(level: Int) -> GameScene? {
      return GameScene(fileNamed: "Level-\(level)")
    }
}

extension GameScene {
  func skullDestroyedParticles(point: CGPoint) {
      if let explosion = SKEmitterNode(fileNamed: "Explosion") {
        addChild(explosion)
        explosion.position = point
        let wait = SKAction.wait(forDuration: 1)
        let removeExplosion = SKAction.removeFromParent()
        explosion.run(SKAction.sequence([wait, removeExplosion]))
      }
    }
}


