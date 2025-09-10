import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> fileToBlob(File file) async {
  return await file.readAsBytes();
}
