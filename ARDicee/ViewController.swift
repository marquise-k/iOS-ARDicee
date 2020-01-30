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

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        
//        let sphere = SCNSphere(radius: 0.2)
//        //
//        let material = SCNMaterial()
//        //
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_moon.jpg")
//
//        // material is an array as you can assign multiple materials to an object eg. shininess , transparency, color, etc.
//
//        sphere.materials = [material]
//
//        // Assigning a node aka a point in 3d space
//        let node = SCNNode()
//        // puting the node across the xyz axis
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        //Assigning the node an object to display aka a geometry which in this case is our lovely cube
//
//        node.geometry = sphere
//        //We add a child node aka our cube to our root node in our 3d scene.
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
//
//        //        // Create a new scene
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//
//        diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//
//        sceneView.scene.rootNode.addChildNode(diceNode)
//
//        }
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            // convert touch location to 3d position corresponding to one of our AR plane anchors
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        
                    //placing the dice on the touched position
                    // y position is different so the dice seats on top of the plane so we offset it vertically by its radius
                    
                
                diceNode.position = SCNVector3(
                    x: hitResult.worldTransform.columns.3.x,
                    y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                    z: hitResult.worldTransform.columns.3.z)
        
                sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    let randomX = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
                    
                    let randomZ = Float(arc4random_uniform(4) + 1)*(Float.pi/2)
                        
                diceNode.runAction(SCNAction.rotateBy(
                    x: CGFloat(randomX * 5),
                    y: 0,
                    z: CGFloat(randomZ * 5),
                    duration: 0.5))
                }
            }
        }
    }
    
    // Method to execute when app detects a horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // checks if anchor is of type ARPlaneAnchor (plane detection)
        if anchor is ARPlaneAnchor {
            //print("plane detected")
            // Reassigning our detected anchor to a new variable
            let planeAnchor = anchor as! ARPlaneAnchor
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
            
            node.addChildNode(planeNode)
            
            
            
        } else {
            return
        }
    }

}
