import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageTest {
  static Future<void> testStorageConnection() async {
    try {
      debugPrint('Testing Firebase Storage connection...');
      final storage = FirebaseStorage.instance;
      debugPrint('Storage instance created: $storage');
      debugPrint('Storage bucket: ${storage.bucket}');

      // Test creating a reference
      final ref = storage.ref().child('test/connection_test.txt');
      debugPrint('Test reference created: ${ref.fullPath}');

      debugPrint('Firebase Storage connection test: SUCCESS');
    } catch (e) {
      debugPrint('Firebase Storage connection test: FAILED - $e');
    }
  }
}
