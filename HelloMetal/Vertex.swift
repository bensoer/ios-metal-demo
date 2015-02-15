//
//  Vertex.swift
//  HelloMetal
//
//  Created by Ben Soer on 2015-02-14.
//  Copyright (c) 2015 bensoer. All rights reserved.
//

import Foundation

struct Vertex{
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
    
};