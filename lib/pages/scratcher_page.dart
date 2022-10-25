import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:sweden_lecture/helpers/image_helper.dart';

class ScratcherPage extends StatefulWidget {
  const ScratcherPage({Key? key}) : super(key: key);

  @override
  State<ScratcherPage> createState() => _ScratcherPageState();
}

class _ScratcherPageState extends State<ScratcherPage> {
  final List<List<Offset>> offsetsList = [];
  final offsetsStream = StreamController<List<List<Offset>>>();

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
            child: GestureDetector(
              onPanStart: (details) {
                offsetsList.add([details.localPosition]);
              },
              onPanUpdate: ((details) {
                offsetsList.last.add(details.localPosition);
                offsetsStream.add(offsetsList);
              }),
              child: StreamBuilder<List<List<Offset>>>(
                  stream: offsetsStream.stream,
                  builder: (context, snapshot) {
                    return CustomPaint(
                      size: const Size(400, 200),
                      painter: _ScratcherPainter(
                        imageLoaded.data!,
                        snapshot.data ?? [],
                      ),
                    );
                  }),
            ),
          );
        },
      ),
    );
  }
}

class _ScratcherPainter extends CustomPainter {
  final ui.Image image;
  final List<List<Offset>> pointsList;

  _ScratcherPainter(this.image, this.pointsList);

  @override
  void paint(Canvas canvas, Size size) {
    final outputRect = Offset.zero & size;
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final sizes = applyBoxFit(BoxFit.cover, imageSize, outputRect.size);
    final Rect inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect outputSubrect =
        Alignment.center.inscribe(sizes.destination, outputRect);

    canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());

    canvas.saveLayer(null, Paint());

    canvas.drawRect(outputRect, Paint()..color = Colors.blueAccent);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..blendMode = BlendMode.src
      ..color = Colors.transparent;

    final path = Path();

    for (var i = 0; i < pointsList.length; i++) {
      final points = pointsList[i].toSet().toList();
      for (var j = 0; j < points.length; j++) {
        if (j == 0) {
          path.moveTo(points[j].dx, points[j].dy);
        } else {
          path.lineTo(points[j].dx, points[j].dy);
        }
      }
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScratcherPainter oldDelegate) {
    return true;
  }
}
