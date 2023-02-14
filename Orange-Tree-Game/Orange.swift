//
//  Orange.swift
//  Orange-Tree-Game
//
//  Created by Cherish Spikes on 2/5/23.
//

//this class will alow one to make as many oranges as needed
import SpriteKit
//when a class extends another class, call it super() to initalize the "super class."
class Orange: SKSpriteNode {
  init() {
      //set size and appearance of an orange, set to the orange.png asset
    let texture = SKTexture(imageNamed: "Orange")
    let size = texture.size()
      //set color to clear so that you don't override the images color
    let color = UIColor.clear
   
    super.init(texture: texture, color: color, size: size)
   //create a circular physics body that fits the outline of the orange:
    physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2) //(size.width / 2 )pass in half of the width of the texture
  }
 
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
