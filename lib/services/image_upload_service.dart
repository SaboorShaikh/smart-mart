import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class ImageUploadService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload an image to Supabase Storage
  /// Returns the public URL of the uploaded image
  static Future<String?> uploadImage({
    required File imageFile,
    required String bucketName,
    required String fileName,
  }) async {
    try {
      print('=== STARTING IMAGE UPLOAD ===');
      print('Bucket name: $bucketName');
      print('File name: $fileName');
      print('File path: ${imageFile.path}');
      print('Supabase client URL: ${_supabase.rest.url}');

      // Check if file exists
      if (!await imageFile.exists()) {
        print('ERROR: File does not exist at path: ${imageFile.path}');
        return null;
      }

      // Read the image file as bytes
      final bytes = await imageFile.readAsBytes();
      print('File size: ${bytes.length} bytes');

      if (bytes.isEmpty) {
        print('ERROR: File is empty');
        return null;
      }

      // Test bucket access first
      print('Testing bucket access...');
      try {
        final testList = await _supabase.storage.from(bucketName).list();
        print(
            'Bucket access test successful. Files in bucket: ${testList.length}');
      } catch (e) {
        print('ERROR: Cannot access bucket "$bucketName": $e');
        return null;
      }

      // Upload to Supabase Storage
      print('Starting upload...');
      final response = await _supabase.storage
          .from(bucketName)
          .uploadBinary(fileName, bytes);

      print('Upload response: $response');

      if (response.isNotEmpty) {
        // Get the public URL
        final publicUrl =
            _supabase.storage.from(bucketName).getPublicUrl(fileName);

        print('Public URL: $publicUrl');
        print('Bucket name used: $bucketName');
        print('File name used: $fileName');
        print('URL contains bucket name: ${publicUrl.contains(bucketName)}');
        print(
            'Expected URL format: https://vfuapjquijpungnnhxef.supabase.co/storage/v1/object/public/$bucketName/$fileName');
        print(
            'URL matches expected format: ${publicUrl.contains('https://vfuapjquijpungnnhxef.supabase.co/storage/v1/object/public/')}');
        return publicUrl;
      }

      print('Upload failed - empty response');
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      print('Error type: ${e.runtimeType}');
      if (e.toString().contains('bucket')) {
        print(
            'Bucket "$bucketName" might not exist. Please create it in Supabase Storage.');
      }
      return null;
    }
  }

  /// Upload a store logo using the same method as profile pictures
  static Future<String?> uploadStoreLogo({
    required File imageFile,
    required String storeId,
  }) async {
    try {
      print('=== UPLOADING STORE LOGO ===');
      print('Store ID: $storeId');
      print('File path: ${imageFile.path}');

      final fileName =
          '${storeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$storeId/$fileName';

      print('Upload path: $path');

      final storage = _supabase.storage.from(SupabaseConfig.storeLogosBucket);

      // Upload using the same method as profile pictures
      await storage.upload(
        path,
        imageFile,
        fileOptions: const FileOptions(
          cacheControl: '31536000',
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );

      print('Upload successful, creating signed URL...');

      // Create signed URL (same as profile pictures)
      final signedUrl = await storage.createSignedUrl(
          path, const Duration(days: 3650).inSeconds);

      print('Signed URL created: $signedUrl');
      return signedUrl;
    } catch (e) {
      print('Error uploading store logo: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Upload a profile image
  static Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      imageFile: imageFile,
      bucketName: SupabaseConfig.profileImagesBucket,
      fileName: fileName,
    );
  }

  /// Upload a product image
  static Future<String?> uploadProductImage({
    required File imageFile,
    required String productId,
    int? imageIndex,
  }) async {
    final suffix = imageIndex != null ? '_$imageIndex' : '';
    final fileName =
        '$productId${suffix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return uploadImage(
      imageFile: imageFile,
      bucketName: SupabaseConfig.productImagesBucket,
      fileName: fileName,
    );
  }

  /// Delete an image from Supabase Storage
  static Future<bool> deleteImage({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      await _supabase.storage.from(bucketName).remove([fileName]);
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
