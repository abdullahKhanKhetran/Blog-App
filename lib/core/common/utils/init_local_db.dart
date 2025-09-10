import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<Database> openExistingDatabase() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final dbPath = join(docsDir.path, 'blog_app.db');

  final dbFile = File(dbPath);
  if (!await dbFile.exists()) {
    // Debug: copying pre-populated database from assets
    // ignore: avoid_print
    print('[LocalDB] Copying database from assets to: ' + dbPath);
    final bytes = await rootBundle.load('assets/database/blog_app.db');
    await dbFile.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
  }
  // Debug: opening database
  // ignore: avoid_print
  print('[LocalDB] Opening database at: ' + dbPath);
  return openDatabase(
    dbPath,
    onOpen: (db) {
      // ignore: avoid_print
      print('[LocalDB] Database opened OK');
    },
  );
}
