import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<File> networkImageToFile(String imageUrl, String fileName) async {
  // Download image bytes
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName';

    // Write bytes to file
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  } else {
    throw Exception('Failed to download image');
  }
}
