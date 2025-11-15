import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class SupabaseStorageService {
  static SupabaseClient get _client => Supabase.instance.client;

  static Future<String> uploadProfileImage(
      File imageFile, String userId) async {
    final fileName =
        'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$fileName';

    final storage = _client.storage.from(SupabaseConfig.profileImagesBucket);
    try {
      await storage.upload(
        path,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '31536000',
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );
    } on StorageException catch (e) {
      throw Exception('Supabase upload failed (${e.statusCode}): ${e.message}');
    }

    // Return a long-lived signed URL so it works for private buckets too
    try {
      final signedUrl = await storage.createSignedUrl(
          path, const Duration(days: 3650).inSeconds);
      return signedUrl;
    } on StorageException catch (e) {
      throw Exception(
          'Supabase signed URL failed (${e.statusCode}): ${e.message}');
    }
  }

  static Future<List<String>> uploadProductImages(
      List<File> images, String productId) async {
    final storage = _client.storage.from(SupabaseConfig.productImagesBucket);
    final List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      final fileName =
          'image_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$productId/$fileName';
      await storage.upload(
        path,
        images[i],
        fileOptions: const FileOptions(
          cacheControl: '31536000',
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );
      final signedUrl = await storage.createSignedUrl(
          path, const Duration(days: 3650).inSeconds);
      urls.add(signedUrl);
    }
    return urls;
  }

  static Future<void> deleteByPublicUrl(String url) async {
    // Extract bucket path from URL: this assumes standard public URL format.
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    // Formats:
    // - /storage/v1/object/public/<bucket>/<path...>
    // - /storage/v1/object/sign/<bucket>/<path...>
    int markerIndex = segments.indexOf('public');
    if (markerIndex == -1) {
      markerIndex = segments.indexOf('sign');
    }
    final bucketIndex = markerIndex + 1;
    if (bucketIndex <= 0 || bucketIndex >= segments.length) return;
    final bucket = segments[bucketIndex];
    final objectPath = segments.sublist(bucketIndex + 1).join('/');
    await Supabase.instance.client.storage.from(bucket).remove([objectPath]);
  }
}
