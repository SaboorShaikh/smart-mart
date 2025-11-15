import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';

class SupabaseTestService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Test if the store-logos bucket exists and is accessible
  static Future<bool> testStoreLogosBucket() async {
    try {
      print('Testing store-logos bucket...');

      // Try to list files in the bucket (this will fail if bucket doesn't exist)
      final response =
          await _supabase.storage.from(SupabaseConfig.storeLogosBucket).list();

      print(
          'Store-logos bucket is accessible. Files count: ${response.length}');
      return true;
    } catch (e) {
      print('Store-logos bucket test failed: $e');
      if (e.toString().contains('not found') ||
          e.toString().contains('does not exist')) {
        print(
            'ERROR: The "store-logos" bucket does not exist in your Supabase Storage.');
        print('Please create it in your Supabase dashboard:');
        print('1. Go to your Supabase project dashboard');
        print('2. Navigate to Storage');
        print('3. Create a new bucket named "store-logos"');
        print('4. Make it public');
      }
      return false;
    }
  }

  /// Test if the profile-images bucket exists and is accessible
  static Future<bool> testProfileImagesBucket() async {
    try {
      print('Testing profile-images bucket...');

      final response = await _supabase.storage
          .from(SupabaseConfig.profileImagesBucket)
          .list();

      print(
          'Profile-images bucket is accessible. Files count: ${response.length}');
      return true;
    } catch (e) {
      print('Profile-images bucket test failed: $e');
      return false;
    }
  }

  /// Test if the product-images bucket exists and is accessible
  static Future<bool> testProductImagesBucket() async {
    try {
      print('Testing product-images bucket...');

      final response = await _supabase.storage
          .from(SupabaseConfig.productImagesBucket)
          .list();

      print(
          'Product-images bucket is accessible. Files count: ${response.length}');
      return true;
    } catch (e) {
      print('Product-images bucket test failed: $e');
      return false;
    }
  }

  /// Test all required buckets
  static Future<Map<String, bool>> testAllBuckets() async {
    print('Testing all Supabase Storage buckets...');

    final results = <String, bool>{};

    results['store-logos'] = await testStoreLogosBucket();
    results['profile-images'] = await testProfileImagesBucket();
    results['product-images'] = await testProductImagesBucket();

    print('Bucket test results: $results');
    return results;
  }
}
