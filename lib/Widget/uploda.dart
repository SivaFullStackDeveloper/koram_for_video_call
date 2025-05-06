import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ImageUpload{
  Future uploadImage(File imageFile) async {
 
  final file = File(imageFile.path);
  final uri = Uri.parse('http://24.199.85.25:4300/upload');

  var request = http.MultipartRequest('POST', uri);
  request.files.add(
    await http.MultipartFile.fromPath(
      'image', // must match `name="image"` in your form
      file.path,
      filename: basename(file.path),
    ),
  );

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      print('Uploaded successfully: $responseData');
      return responseData;
    } else {
      print('Upload failed with status: ${response.statusCode}');
    }
  } catch (e) {
    print('Upload error: $e');
  }
}
}
