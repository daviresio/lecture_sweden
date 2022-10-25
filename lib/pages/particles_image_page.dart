import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sweden_lecture/helpers/image_helper.dart';
import 'package:image/image.dart' as img_lib;

class ParticlesImagePage extends StatefulWidget {
  const ParticlesImagePage({Key? key}) : super(key: key);

  @override
  State<ParticlesImagePage> createState() => _ParticlesImagePageState();
}

class _ParticlesImagePageState extends State<ParticlesImagePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation =
      AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();

    animation.forward().whenComplete(() => animation.repeat());
  }

  var particles = <_Particle>[];
  final Map<int, Map<int, double>> mappedImage = {};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: Colors.black87,
      child: FutureBuilder<img_lib.Image>(
        future: ImageHelper.loadlibImage(
            assetPath: 'assets/images/dash.png', screenWidth: size.width),
        builder: (context, imageLoaded) {
          if (!imageLoaded.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final bytes = imageLoaded.data!.getBytes().toList();

          return Center(
            child: AnimatedBuilder(
              animation: animation,
              builder: (_, __) {
                return CustomPaint(
                  isComplex: true,
                  size: Size(size.width, imageLoaded.data!.height.toDouble()),
                  painter: _ImageParticlesPainter(
                    img: imageLoaded.data!,
                    bytes: bytes,
                    particles: particles,
                    listenable: animation.value,
                    mappedImage: mappedImage,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ImageParticlesPainter extends CustomPainter {
  final img_lib.Image img;
  final List<int> bytes;
  final List<_Particle> particles;
  final double listenable;
  final Map<int, Map<int, double>> mappedImage;

  _ImageParticlesPainter({
    required this.img,
    required this.bytes,
    required this.particles,
    required this.listenable,
    required this.mappedImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) {
      for (var y = 0; y < img.height; y++) {
        mappedImage[y] = {};
        for (var x = 0; x < img.width; x++) {
          final red = bytes[(y * img.width + x) * 4];
          final green = bytes[(y * img.width + x) * 4 + 1];
          final blue = bytes[(y * img.width + x) * 4 + 2];
          final opacity = bytes[(y * img.width + x) * 4 + 3];

          final brightness = math.sqrt(red * red * 0.241 +
                  green * green * 0.691 +
                  blue * blue * 0.068) /
              100;
          mappedImage[y]![x] = opacity <= 0.2 ? 0.0 : brightness;
        }
      }

      for (var y = 0; y < mappedImage.keys.length; y++) {
        for (var x = 0; x < mappedImage[y]!.keys.length; x++) {
          final particle = _Particle();
          particle.init(size);

          particles.add(particle);
        }
      }
    }

    for (var particle in particles) {
      particle.update(mappedImage);
    }

    final particlesUniquePosition = <_Particle>{};

    for (var particle in particles) {
      particlesUniquePosition.add(particle);
    }

    for (var particle in particlesUniquePosition) {
      particle.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _Particle {
  late double x;
  late double y;
  late double speed;
  late double velocity;
  late double size;
  late Size screenSize;
  late double value;

  bool isInitialized = false;

  String get uniquePosition => '$x-$y';

  void init(Size screenSize) {
    this.screenSize = screenSize;

    final random = math.Random();

    x = random.nextInt(screenSize.width.toInt()).toDouble();

    velocity = random.nextDouble() * 0.5;
    size = random.nextDouble() * 3;
    speed = y = 0.8;

    isInitialized = true;
  }

  void update(Map<int, Map<int, double>> mappedImage) {
    value = mappedImage[y.toInt()]?[x.toInt()] ?? 0.0;
    speed += value == 0.0 ? 0.8 : velocity * 3.5;

    final movement = speed * velocity;

    y += movement;

    if (y > screenSize.height) {
      init(screenSize);
    }
  }

  void draw(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        x,
        y,
        x + 1,
        y + 1,
        const Radius.circular(1.0),
      ),
      Paint()..color = Colors.white.withOpacity((value * 0.5).clamp(0.1, 1.0)),
    );
  }
}
