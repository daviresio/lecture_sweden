import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img_lib;

class ImageHelper {
  static Future<img_lib.Image> loadlibImage({
    required String assetPath,
    required double screenWidth,
  }) async {
    final data = await rootBundle.load(assetPath);
    final list = Uint8List.view(data.buffer);
    final img = img_lib.decodeImage(list);

    final resizedImage = img_lib.copyResize(img!, width: screenWidth.toInt());

    return resizedImage;
  }

  static Future<ui.Image> loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final list = Uint8List.view(data.buffer);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }
}
