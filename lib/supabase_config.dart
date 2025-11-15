class SupabaseConfig {
  static const String url = 'https://vfuapjquijpungnnhxef.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdWFwanF1aWpwdW5nbm5oeGVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgxMTQ2ODQsImV4cCI6MjA3MzY5MDY4NH0.mmC5ZAI2UogrnIUnnlt4MjdIaqw64rvv9PZoPrdHefk';

  // Buckets to use (create them in Supabase Storage):
  static const String profileImagesBucket = 'profile-images';
  static const String productImagesBucket = 'product-images';
  static const String storeLogosBucket = 'store-logos';
}
