import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

Future<gpu.Texture> loadTextureFromAsset(String assetPath) async {
  final ByteData assetData = await rootBundle.load(assetPath);

  final ui.Codec codec = await ui.instantiateImageCodec(
    assetData.buffer.asUint8List(),
  );

  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  final ByteData? rgbaBytes = await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );

  if (rgbaBytes == null) {
    throw Exception(
        'An error occurred while converting $assetPath to RGBA ByteData');
  }

  final texture = gpu.gpuContext.createTexture(
    gpu.StorageMode.hostVisible,
    image.width,
    image.height,
    format: gpu.PixelFormat.r8g8b8a8UNormInt,
    sampleCount: 1,
    coordinateSystem: gpu.TextureCoordinateSystem.uploadFromHost,
    enableRenderTargetUsage: false,
    enableShaderReadUsage: true,
    enableShaderWriteUsage: false,
  );

  if (texture == null) {
    throw Exception(
        'An error occurred while creating a Texture for $assetPath');
  }

  if (!texture.overwrite(rgbaBytes)) {
    throw Exception('texture.overwrite returned false');
  }

  return texture;
}
