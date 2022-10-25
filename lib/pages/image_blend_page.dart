import 'package:flutter/material.dart';
import 'package:sweden_lecture/helpers/image_helper.dart';
import 'dart:ui' as ui;

class ImageBlendPage extends StatefulWidget {
  const ImageBlendPage({Key? key}) : super(key: key);

  @override
  State<ImageBlendPage> createState() => _ImageBlendPageState();
}

class _ImageBlendPageState extends State<ImageBlendPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: FutureBuilder<ui.Image>(
          future: ImageHelper.loadUiImage('assets/images/code.jpeg'),
          builder: (context, snapshot2) {
            if (!snapshot2.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return FutureBuilder<ui.Image>(
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
                    painter:
                        _ImageBlendPainter(imageLoaded.data!, snapshot2.data!),
                  ),
                );
              },
            );
          }),
    );
  }
}

class _ImageBlendPainter extends CustomPainter {
  final ui.Image image;
  final ui.Image bgImage;

  _ImageBlendPainter(this.image, this.bgImage);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPosition = Offset(
      size.width / 2 - bgImage.width / 2,
      size.height / 2 - bgImage.height / 2,
    );

    final circlePainter = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.multiply;

    final outputRect = Offset.zero & size;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final sizes = applyBoxFit(BoxFit.contain, imageSize, outputRect.size);
    final Rect inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputSubrect =
        Alignment.center.inscribe(sizes.destination, outputRect);

    canvas.drawImage(bgImage, bgPosition, circlePainter);

    canvas.drawImageRect(image, inputSubrect, outputSubrect, circlePainter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
