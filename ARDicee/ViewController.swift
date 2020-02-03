//
//  ViewController.swift
//  ARDicee
//
//  Created by Marquise Kamanke on 2020-01-29.
//  Copyright © 2020 Marquise Kamanke. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]() // We create an array to store all of the generated dice and initialise it to be empty

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Dice Rendering Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            // convert touch location to 3d position corresponding to one of our AR plane anchors
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
                    if let hitResult = results.first {
                        addDice(atLocation: hitResult)
                    }
                }
            }
        
    func addDice(atLocation location: ARHitTestResult) { // adding internal parameter location for readability, this is optional
        
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        
                    //placing the dice on the touched position
                    // y position is different so the dice seats on top of the plane so we offset it vertically by its radius
                    
                
                diceNode.position = SCNVector3(
                    x: location.worldTransform.columns.3.x,
                    y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                    z: location.worldTransform.columns.3.z)
        
                    diceArray.append(diceNode) // Everytime we create an array we append it to our array
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                
                    roll(dice: diceNode)
     }
   }

func roll(dice: SCNNode) {
      let randomX = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
                      
      let randomZ = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
                          
      dice.runAction(SCNAction.rotateBy(
          x: CGFloat(randomX * 5),
          y: 0,
          z: CGFloat(randomZ * 5),
          duration: 0.5))
  }


    func rollAll() {
        
        if !diceArray.isEmpty {  // if dice array is not empty
            for dice in diceArray { // for every dice in dice array
                roll(dice: dice) // roll dice aka execute roll function passing dice
            }
        }
    }
    
    
    func removeAllDice() {
    
        if !diceArray.isEmpty { // if dice array is not emoty
            for dice in diceArray {
                dice.removeFromParentNode()  // remove from parent node
            }
        }
    }
    
    
    // Method to execute when app detects a horizontal plane

    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        removeAllDice()
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    } // function to roll all the dice on shake


//MARK: - ARSCNViewDelegateMethod
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}  // We try to downcast this new constant (planeAnchor) from type ARAnchor to type ARPlane Anchor (plane detection). If the anchor we detected cannot be converted into ARPlaneAnchor, then the planeanchor will be an optional which equals to nil. Then the  conditional statement fails and we return early
        
            let planeNode = createPlane(withPlaneAnchor: planeAnchor)
                
            node.addChildNode(planeNode)
    }

//MARK: -Plane Rendering Methods

    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode { // Making sure the output of this method is a SCNNode
    
    // Creating a plane in Scene Kit. We'll just use the width and the height of plane anchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            // Creating our node to attach our geometry too
            let planeNode = SCNNode()
            //Positioning the node on our 3D axis
            // y is 0 because its a flat horizontal plane
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y:0, z: planeAnchor.center.z)
            // By default,  SCNPlane stands vertically, not horizontalle (refer to docs) so we need to transform it so it's vertical
            // Angle is in radians. Needs to be -90 deg because it rotates counterclockwise by default while we need the opposite
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
    
            return planeNode
        }
}
