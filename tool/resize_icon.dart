import 'dart:io';
import 'package:image/image.dart' as img;

/// Resizes app_logo.png to 60% of its canvas size (adds 20% padding each side)
/// so the adaptive icon foreground doesn't fill the entire circle.
void main() {
  final inputFile = File('assets/app_logo.png');
  final outputFile = File('assets/app_logo_padded.png');

  final original = img.decodePng(inputFile.readAsBytesSync())!;

  // New canvas = original size, logo scaled to 60% centered
  final canvasSize = original.width; // keep same canvas
  final logoSize = (canvasSize * 0.60).round();
  final offset = ((canvasSize - logoSize) / 2).round();

  // Resize the logo down
  final resized = img.copyResize(original, width: logoSize, height: logoSize);

  // Create transparent canvas and composite logo centered
  final canvas = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0)); // transparent
  img.compositeImage(canvas, resized, dstX: offset, dstY: offset);

  outputFile.writeAsBytesSync(img.encodePng(canvas));
  print('Done → ${outputFile.path} (${canvasSize}x${canvasSize}, logo at 60%)');
}
