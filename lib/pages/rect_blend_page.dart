import 'package:flutter/material.dart';

class RectBlendPage extends StatefulWidget {
  const RectBlendPage({Key? key}) : super(key: key);

  @override
  State<RectBlendPage> createState() => _RectBlendPageState();
}

class _RectBlendPageState extends State<RectBlendPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2));

  late final animation =
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut);

  late final animationValue =
      Tween<double>(begin: 0.0, end: 285.0).animate(animation);

  @override
  void initState() {
    super.initState();

    animationController
        .forward()
        .whenComplete(() => animationController.repeat());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (_, __) {
            return CustomPaint(
              painter: _RectBlendPainter(animationValue.value),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

class _RectBlendPainter extends CustomPainter {
  final double positionX;

  _RectBlendPainter(this.positionX);

  @override
  void paint(Canvas canvas, Size size) {
    final rectPaint = Paint()..color = Colors.black;
    const bgRect = Rect.fromLTWH(100, 200, 200, 100);
    canvas.clipRect(bgRect);

    canvas.drawRect(bgRect, rectPaint);

    const text = TextSpan(
      text: 'Click here',
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter =
        TextPainter(text: text, textDirection: TextDirection.ltr);

    textPainter.layout();

    textPainter.paint(canvas, const Offset(120, 250));

    const rect = Rect.fromLTWH(120, 200, 70, 300);

    var path = Path()..addRect(rect);

    final transform = Matrix4.identity();
    transform.rotateZ(0.5);
    transform.translate(positionX, -250.0);

    path = path.transform(transform.storage);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.difference,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
