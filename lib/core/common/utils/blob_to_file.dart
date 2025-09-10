import 'dart:io';
import 'dart:typed_data';

Future<File> blobToFile(Uint8List data, String filePath) async {
  final file = File(filePath);
  return await file.writeAsBytes(data);
}
