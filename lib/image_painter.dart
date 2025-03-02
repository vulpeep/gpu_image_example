import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart' as vm;

const _kShaderBundlePath = 'assets/image.shaderbundle';
final _shaderLibrary = gpu.ShaderLibrary.fromAsset(_kShaderBundlePath)!;

class ImagePainter extends CustomPainter {
  ImagePainter(this.imageTexture);
  final gpu.Texture imageTexture;

  @override
  void paint(Canvas canvas, ui.Size size) {
    final commandBuffer = gpu.gpuContext.createCommandBuffer();
    final outputTexture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      size.width.toInt(),
      size.height.toInt(),
    )!;

    final colorAttachment = gpu.ColorAttachment(
      texture: outputTexture,
      loadAction: gpu.LoadAction.clear,
      storeAction: gpu.StoreAction.store,
      clearValue: vm.Vector4(0, 0, 0, 1),
    );

    final renderTarget = gpu.RenderTarget.singleColor(colorAttachment);

    final renderPass = commandBuffer.createRenderPass(renderTarget);

    final gpu.Shader vertexShader = _shaderLibrary['ImageVertex']!;
    final gpu.Shader fragmentShader = _shaderLibrary['ImageFragment']!;

    final pipeline =
        gpu.gpuContext.createRenderPipeline(vertexShader, fragmentShader);

    renderPass.bindPipeline(pipeline);

    final transformMatrix = vm.Matrix4.identity();

    final transformUniformSlot = vertexShader.getUniformSlot("Transform");
    final uniformBuffer = gpu.gpuContext.createHostBuffer();
    final uniformView = uniformBuffer.emplace(
      transformMatrix.storage.buffer.asByteData(),
    );
    renderPass.bindUniform(transformUniformSlot, uniformView);

    final vertices = Float32List.fromList([
      0, 0, //
      0, 1, //
      1, 0, //
      0, 1, //
      1, 0, //
      1, 1, //
    ]);
    final verticesDeviceBuffer = gpu.gpuContext
        .createDeviceBufferWithCopy(ByteData.sublistView(vertices))!;

    final verticesView = gpu.BufferView(
      verticesDeviceBuffer,
      offsetInBytes: 0,
      lengthInBytes: verticesDeviceBuffer.sizeInBytes,
    );

    renderPass.bindVertexBuffer(verticesView, 6);

    final uniformTextureSlot = fragmentShader.getUniformSlot("uTexture");

    renderPass.bindTexture(uniformTextureSlot, imageTexture);

    renderPass.draw();

    commandBuffer.submit();

    canvas.drawImage(outputTexture.asImage(), Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
