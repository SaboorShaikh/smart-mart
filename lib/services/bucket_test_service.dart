import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class BucketTestService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Test if the store-logos bucket exists and is accessible
  static Future<bool> testStoreLogosBucket() async {
    try {
      print('Testing store-logos bucket...');

      // Try to list files in the bucket
      final files =
          await _supabase.storage.from(SupabaseConfig.storeLogosBucket).list();

      print('Store-logos bucket exists and is accessible');
      print('Files in bucket: ${files.length}');

      return true;
    } catch (e) {
      print('Store-logos bucket test failed: $e');
      print('Error type: ${e.runtimeType}');

      if (e.toString().contains('not found') ||
          e.toString().contains('does not exist')) {
        print(
            'Bucket "store-logos" does not exist. Please create it in Supabase Storage.');
      } else if (e.toString().contains('permission') ||
          e.toString().contains('403')) {
        print('Bucket exists but RLS policies are blocking access.');
      }

      return false;
    }
  }

  /// Test all required buckets
  static Future<void> testAllBuckets() async {
    print('=== Testing Supabase Storage Buckets ===');

    final buckets = [
      SupabaseConfig.profileImagesBucket,
      SupabaseConfig.productImagesBucket,
      SupabaseConfig.storeLogosBucket,
    ];

    for (final bucket in buckets) {
      print('\n--- Testing bucket: $bucket ---');
      try {
        final files = await _supabase.storage.from(bucket).list();
        print('✅ $bucket: Accessible (${files.length} files)');
      } catch (e) {
        print('❌ $bucket: Failed - $e');
      }
    }

    print('\n=== Bucket Test Complete ===');
  }
}
