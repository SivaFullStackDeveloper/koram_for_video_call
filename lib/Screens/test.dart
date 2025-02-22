import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  final image;
  Test(this.image);

  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  getimage(image) {
    // image =
    //     "/9j/4QG1RXhpZgAATU0AKgAAAAgABwEQAAIAAAAaAAAAYgEAAAQAAAABAAAEOAEBAAQAAAABAAAHgAEyAAIAAAAUAAAAfAESAAMAAAABAAEAAIdpAAQAAAABAAAAlwEPAAIAAA==";
    Uint8List _bytesImage;
    _bytesImage = Base64Decoder().convert(image.toString());
    return _bytesImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.memory(getimage(widget.image)),
    );
  }
}
