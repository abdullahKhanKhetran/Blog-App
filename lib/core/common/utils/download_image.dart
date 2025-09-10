import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<File> getImage(String imageUrl) async {
  final url = Uri.parse(imageUrl);
  final response = await http.get(url);
  if (response.statusCode == 200) {
    // Get temporary directory
    final tempDir = await getTemporaryDirectory();

    // Create a unique file name
    final file = File('${tempDir.path}/downloaded_image.jpg');

    // Write the bytes to the file
    await file.writeAsBytes(response.bodyBytes);

    return file;
  } else {
    throw Exception('Failed to load image');
  }
}
