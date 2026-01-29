import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

extension FileExtensions on File {
  Future<void> remove() async {
    if (await exists()) {
      try {
        await delete();
        debugPrint('File deleted from cache: ${basename(path)}');
      } catch (e) {
        debugPrint('Error deleting file from cache: ${basename(path)}');
      }
    }
  }
}
