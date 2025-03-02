import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:gpu_image_example/image_painter.dart';
import 'package:gpu_image_example/utils.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  void initState() {
    super.initState();
    loadTexture();
  }

  gpu.Texture? texture;

  Future<void> loadTexture() async {
    texture = await loadTextureFromAsset('assets/image.png');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (texture == null) {
      return Text('Loading...');
    }
    return CustomPaint(
      painter: ImagePainter(texture!),
    );
  }
}
