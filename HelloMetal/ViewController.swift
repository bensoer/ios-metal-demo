//
//  ViewController.swift
//  HelloMetal
//
//  Created by Ben Soer on 2015-02-13.
//  Copyright (c) 2015 bensoer. All rights reserved.
//
/* Source: http://www.raywenderlich.com/77488/ios-8-metal-tutorial-swift-getting-started */
/* Source: http://www.raywenderlich.com/81399/ios-8-metal-tutorial-swift-moving-to-3d */

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {

    var device: MTLDevice! = nil;
    
    var metalLayer: CAMetalLayer! = nil
    
    //var vertexBuffer: MTLBuffer! = nil
    
   /* let vertexData:[Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0]*/
    
    //var objectToDraw: Triangle!
    var objectToDraw: Cube!
    
    var pipelineState: MTLRenderPipelineState! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    
    var projectionMatrix: Matrix4!
    
    var lastFrameTimestamp: CFTimeInterval = 0.0 //rotation timer
    
    /* -- END OF SETUP ATTRIBUTES -- */
    
    var timer: CADisplayLink! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degreesToRad(85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        
        device = MTLCreateSystemDefaultDevice();
        
        metalLayer = CAMetalLayer()          // 1
        metalLayer.device = device           // 2
        metalLayer.pixelFormat = .BGRA8Unorm // 3
        metalLayer.framebufferOnly = true    // 4
        metalLayer.frame = view.layer.frame  // 5
        view.layer.addSublayer(metalLayer)   // 6
        
        //let dataSize = vertexData.count * sizeofValue(vertexData[0]) // 1
        //vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: nil) // 2
        
        //objectToDraw = Triangle(device: device) -- draws a triangle
        objectToDraw = Cube(device: device) // -- draws a cube
        
        
        // 1
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary!.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary!.newFunctionWithName("basic_vertex")
        
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm //could be an issue
        
        // 3
        var pipelineError : NSError?
        pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor, error: &pipelineError)
        if pipelineState == nil {
            println("Failed to create pipeline state, error \(pipelineError)")
        }
        
        commandQueue = device.newCommandQueue()
        
        /* -- END OF SETUP CODE -- */
        
        timer = CADisplayLink(target: self, selector: Selector("newFrame:")) //timer calls function
        timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func render() {
        var drawable = metalLayer.nextDrawable()
        
        //altering world view
        var worldModelMatrix = Matrix4()
        
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degreesToRad(25), y: 0.0, z: 0.0)
        
        objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
    }
    
    // 1 -- TIMER RECALC FUNCTION
    func newFrame(displayLink: CADisplayLink){
        
        if lastFrameTimestamp == 0.0
        {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        // 2
        var elapsed:CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        // 3
        gameloop(timeSinceLastUpdate: elapsed)
    }
    // -- TIMER RECALC FUNCTION
    func gameloop(#timeSinceLastUpdate: CFTimeInterval) {
        
        // 4
        objectToDraw.updateWithDelta(timeSinceLastUpdate)
        
        // 5
        autoreleasepool {
            self.render()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

