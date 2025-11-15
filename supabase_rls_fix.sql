-- Supabase RLS Policy Fix for SmartMart App
-- Run these commands in your Supabase SQL Editor

-- 1. Enable RLS on storage.objects table (if not already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 2. Create policy to allow authenticated users to upload to store-logos bucket
CREATE POLICY "Allow authenticated users to upload store logos" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'store-logos' 
  AND auth.role() = 'authenticated'
);

-- 3. Create policy to allow authenticated users to read store logos
CREATE POLICY "Allow authenticated users to read store logos" ON storage.objects
FOR SELECT USING (
  bucket_id = 'store-logos' 
  AND auth.role() = 'authenticated'
);

-- 4. Create policy to allow authenticated users to update their own store logos
CREATE POLICY "Allow users to update their own store logos" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'store-logos' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. Create policy to allow authenticated users to delete their own store logos
CREATE POLICY "Allow users to delete their own store logos" ON storage.objects
FOR DELETE USING (
  bucket_id = 'store-logos' 
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- 6. Create similar policies for profile-images bucket
CREATE POLICY "Allow authenticated users to upload profile images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-images' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Allow authenticated users to read profile images" ON storage.objects
FOR SELECT USING (
  bucket_id = 'profile-images' 
  AND auth.role() = 'authenticated'
);

-- 7. Create similar policies for product-images bucket
CREATE POLICY "Allow authenticated users to upload product images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'product-images' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Allow authenticated users to read product images" ON storage.objects
FOR SELECT USING (
  bucket_id = 'product-images' 
  AND auth.role() = 'authenticated'
);

-- 8. Alternative: If you want to allow public access (less secure but simpler)
-- Uncomment the lines below and comment out the policies above

-- DROP POLICY IF EXISTS "Allow authenticated users to upload store logos" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow authenticated users to read store logos" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow users to update their own store logos" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow users to delete their own store logos" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow authenticated users to upload profile images" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow authenticated users to read profile images" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow authenticated users to upload product images" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow authenticated users to read product images" ON storage.objects;

-- CREATE POLICY "Allow public access to store-logos" ON storage.objects
-- FOR ALL USING (bucket_id = 'store-logos');

-- CREATE POLICY "Allow public access to profile-images" ON storage.objects
-- FOR ALL USING (bucket_id = 'profile-images');

-- CREATE POLICY "Allow public access to product-images" ON storage.objects
-- FOR ALL USING (bucket_id = 'product-images');
