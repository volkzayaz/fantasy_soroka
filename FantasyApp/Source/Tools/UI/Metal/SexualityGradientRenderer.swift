//
//  SexualityGradientRenderer.swift
//  FantasyApp
//
//  Created by Borys Vynohradov on 27.08.2019.
//  Copyright © 2019 Fantasy App. All rights reserved.
//

import Foundation
import MetalKit

public class SexualityGradientRenderer: NSObject {
    // MARK: - Public properties
    public let device = MTLCreateSystemDefaultDevice()
    public var progress: Float = 0
    public var fromTextureResource: CGImage? {
        didSet {
            guard let resource = fromTextureResource, fromTextureResource != oldValue else { return }
            
            fromTexture = try! textureLoader.newTexture(cgImage: resource, options: [.SRGB: false])
            
        }
    }
    public var toTextureResource: CGImage? {
        didSet {
            guard let resource = toTextureResource, toTextureResource != oldValue else { return }
            toTexture = try! textureLoader.newTexture(cgImage: resource, options: [.SRGB: false])
        }
    }

    // MARK: - Private properties
    private var textureLoader: MTKTextureLoader!
    private var queue: MTLCommandQueue!
    private var cps: MTLComputePipelineState!
    private var timer: Float = 0
    private var timerBuffer: MTLBuffer!
    private var progressBuffer: MTLBuffer!
    private var fromTexture: MTLTexture?
    private var toTexture: MTLTexture?

    override public init() {
        guard let device = device else {
            super.init()
            return
        }
        queue = device.makeCommandQueue()
        textureLoader = MTKTextureLoader(device: device)
        timerBuffer = device.makeBuffer(length: MemoryLayout<Float>.size,
                                        options: [])
        progressBuffer = device.makeBuffer(length: MemoryLayout<Float>.size,
                                           options: [])
        super.init()
        configureShaders()
    }
}

// MARK: - Drawing
extension SexualityGradientRenderer: MTKViewDelegate {
    private func update() {
        timer += 0.01

        let timerBufferPointer = timerBuffer.contents()
        memcpy(timerBufferPointer, &timer, MemoryLayout<Float>.size)

        let progressBufferPointer = progressBuffer.contents()
        memcpy(progressBufferPointer, &progress, MemoryLayout<Float>.size)
    }

    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    public func draw(in view: MTKView) {
        guard let _ = device,
            let fromTexture = fromTexture,
            let toTexture = toTexture,
            let drawable = view.currentDrawable,
            let commandBuffer = queue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
                return
        }
        // compute function
        commandEncoder.setComputePipelineState(cps)
        #if arch(i386) || arch(x86_64)
        #else
        commandEncoder.setTexture(drawable.texture, index: 0)
        #endif
        commandEncoder.setTexture(fromTexture, index: 1)
        commandEncoder.setTexture(toTexture, index: 2)
        commandEncoder.setBuffer(timerBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(progressBuffer, offset: 0, index: 1)

        // time/progress update
        update()

        // thread groups setup
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        #if arch(i386) || arch(x86_64)
        #else
        let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width,
                                       drawable.texture.height / threadGroupCount.height,
                                       1)
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        #endif
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Configuration
private extension SexualityGradientRenderer {
    func configureShaders() {
        guard let device = device,
            let library = device.makeDefaultLibrary() else {
            return
        }

        do {
            let kernel = library.makeFunction(name: "compute")!
            cps = try device.makeComputePipelineState(function: kernel)
        } catch {
            debugPrint("\(error)")
        }
    }
}
