import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:koram_app/Helper/Helper.dart';

class StoryItem extends StatelessWidget {
  // const StatusItem({ Key? key }) : super(key: key);
  final image;

  StoryItem(this.image);

  @override
  Widget build(BuildContext context) {
    // var im = base64Decode(image.toString().substring(0, 100));
    // var file = File("decodedBezkoder.png");
    print(image);
    return CustomPaint(
        painter: StatusPainter(false),
        child: CircleAvatar(
            radius: 27,
            backgroundImage: NetworkImage(G.HOST + "api/v1/images/" + image))

        // AssetImage("assets/$image")),
        );
  }
}

degreeToAngle(double degree) {
  return degree * pi / 180;
}

class StatusPainter extends CustomPainter {
  final bool view;

  StatusPainter(this.view);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 8
      ..color = Colors.greenAccent.shade700
      ..style = PaintingStyle.stroke;
    drawArc(canvas, size, paint);
  }

  void drawArc(Canvas canvas, Size size, Paint paint) {
    double degree = -90;
    double arc = 360 / 6;

    for (int i = 0; i < 10; i++) {
      paint.color = Colors.orange;
      canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
          degreeToAngle(degree + 4), degreeToAngle(arc - 8), false, paint);
      degree += arc;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
