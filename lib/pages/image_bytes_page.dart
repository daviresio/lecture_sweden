import 'package:flutter/material.dart';
import 'package:sweden_lecture/helpers/image_helper.dart';
import 'package:image/image.dart' as img_lib;

class ImageBytesPage extends StatefulWidget {
  const ImageBytesPage({Key? key}) : super(key: key);

  @override
  State<ImageBytesPage> createState() => _ImageBytesPageState();
}

class _ImageBytesPageState extends State<ImageBytesPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      child: FutureBuilder<img_lib.Image>(
        future: ImageHelper.loadlibImage(
          assetPath: 'assets/images/dash.png',
          screenWidth: size.width,
        ),
        builder: (context, imageLoaded) {
          if (!imageLoaded.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: CustomPaint(
              size: Size(size.height, size.width),
              painter: _ImageBytesPainter(imageLoaded.data!),
            ),
          );
        },
      ),
    );
  }
}

class _ImageBytesPainter extends CustomPainter {
  final img_lib.Image image;

  _ImageBytesPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final width = image.width;
    final height = image.height;
    final bytes = image.getBytes().toList();

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixelPosition = (y * image.width + x) * 4;

        final red = bytes[pixelPosition];
        final green = bytes[pixelPosition + 1];
        final blue = bytes[pixelPosition + 2];
        final alpha = bytes[pixelPosition + 3];

        final avg = (red + green + blue) ~/ 3;

        final paint = Paint()
          ..color = Color.fromARGB(
            alpha,
            avg,
            avg,
            avg,
          )
          ..style = PaintingStyle.fill;

        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
