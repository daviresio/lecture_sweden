import 'package:flutter/material.dart';
import 'package:sweden_lecture/helpers/image_helper.dart';
import 'dart:ui' as ui;

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<ui.Image>(
        future: ImageHelper.loadUiImage('assets/images/dash.png'),
        builder: (context, imageLoaded) {
          if (!imageLoaded.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _RedimensionedImagePainter(imageLoaded.data!),
            ),
          );
        },
      ),
    );
  }
}

class _RedimensionedImagePainter extends CustomPainter {
  final ui.Image image;

  _RedimensionedImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final outputRect = Offset.zero & size;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final sizes = applyBoxFit(BoxFit.contain, imageSize, outputRect.size);
    final Rect inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputSubrect =
        Alignment.center.inscribe(sizes.destination, outputRect);

    canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// ignore: unused_element
class _ImageCenterPainter extends CustomPainter {
  final ui.Image image;

  _ImageCenterPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final position = Offset(
      size.width / 2 - image.width / 2,
      size.height / 2 - image.width / 2,
    );
    canvas.drawImage(image, position, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
