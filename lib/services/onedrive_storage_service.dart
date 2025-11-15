import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// OneDrive (Microsoft Graph) storage helper.
///
/// Requires a valid OAuth access token with scopes:
/// - Files.ReadWrite
/// - offline_access
///
/// Usage:
///   final url = await OneDriveStorageService(accessToken).uploadSmallFile(
///     file: imageFile,
///     remotePath: '/smartmart/profile_images/$userId/profile.jpg',
///     createAnonymousShareLink: true,
///   );
class OneDriveStorageService {
  OneDriveStorageService(this.accessToken);

  final String accessToken;

  Map<String, String> get _authHeaders => <String, String>{
        'Authorization': 'Bearer $accessToken',
      };

  /// Upload files smaller than 4 MB in a single request.
  Future<Map<String, dynamic>> _uploadSimple({
    required File file,
    required String remotePath,
  }) async {
    final uri = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/root:$remotePath:/content');
    final resp = await http.put(
      uri,
      headers: <String, String>{
        ..._authHeaders,
        'Content-Type': 'application/octet-stream',
      },
      body: await file.readAsBytes(),
    );
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
          'OneDrive simple upload failed: ${resp.statusCode} ${resp.body}');
    }
    return json.decode(resp.body) as Map<String, dynamic>;
  }

  /// For larger files, create an upload session and PUT in chunks.
  Future<Map<String, dynamic>> _uploadLarge({
    required File file,
    required String remotePath,
    int chunkSizeBytes = 2 * 1024 * 1024, // 2 MB chunks
  }) async {
    final createSessionUri = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/root:$remotePath:/createUploadSession');
    final create = await http.post(
      createSessionUri,
      headers: <String, String>{
        ..._authHeaders,
        'Content-Type': 'application/json',
      },
      body: json.encode(<String, dynamic>{
        'item': <String, dynamic>{'name': remotePath.split('/').last}
      }),
    );
    if (create.statusCode < 200 || create.statusCode >= 300) {
      throw Exception(
          'OneDrive createUploadSession failed: ${create.statusCode} ${create.body}');
    }
    final session = json.decode(create.body) as Map<String, dynamic>;
    final uploadUrl = session['uploadUrl'] as String;

    final raf = await file.open();
    try {
      final fileSize = await file.length();
      int uploaded = 0;
      while (uploaded < fileSize) {
        final remaining = fileSize - uploaded;
        final bytesThisChunk =
            remaining > chunkSizeBytes ? chunkSizeBytes : remaining;
        final bytes = await raf.read(bytesThisChunk);
        final start = uploaded;
        final end = uploaded + bytes.length - 1;
        final contentRange = 'bytes $start-$end/$fileSize';
        final chunkResp = await http.put(
          Uri.parse(uploadUrl),
          headers: <String, String>{
            'Content-Length': bytes.length.toString(),
            'Content-Range': contentRange,
          },
          body: bytes,
        );
        if (chunkResp.statusCode == 200 || chunkResp.statusCode == 201) {
          // Completed; returns driveItem
          return json.decode(chunkResp.body) as Map<String, dynamic>;
        }
        if (chunkResp.statusCode < 200 || chunkResp.statusCode >= 300) {
          throw Exception(
              'OneDrive chunk upload failed: ${chunkResp.statusCode} ${chunkResp.body}');
        }
        uploaded = end + 1;
      }
      throw Exception('Upload session ended unexpectedly');
    } finally {
      await raf.close();
    }
  }

  /// Upload and optionally create an anonymous share link.
  Future<String> uploadFile({
    required File file,
    required String remotePath,
    bool createAnonymousShareLink = true,
  }) async {
    final fileSize = await file.length();
    final Map<String, dynamic> driveItem = fileSize < 4 * 1024 * 1024
        ? await _uploadSimple(file: file, remotePath: remotePath)
        : await _uploadLarge(file: file, remotePath: remotePath);

    final String itemId = (driveItem['id'] as String?) ?? '';
    if (itemId.isEmpty) {
      throw Exception('OneDrive upload returned no item id');
    }

    if (!createAnonymousShareLink) {
      return driveItem['webUrl'] as String? ?? itemId;
    }

    final shareUri = Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/items/$itemId/createLink');
    final shareResp = await http.post(
      shareUri,
      headers: <String, String>{
        ..._authHeaders,
        'Content-Type': 'application/json',
      },
      body: json.encode(<String, dynamic>{
        'type': 'view',
        'scope': 'anonymous',
      }),
    );
    if (shareResp.statusCode < 200 || shareResp.statusCode >= 300) {
      throw Exception(
          'OneDrive createLink failed: ${shareResp.statusCode} ${shareResp.body}');
    }
    final data = json.decode(shareResp.body) as Map<String, dynamic>;
    final linkObj = data['link'] as Map<String, dynamic>?;
    final url = linkObj?['webUrl'] as String?;
    if (url == null || url.isEmpty) {
      return driveItem['webUrl'] as String? ?? itemId;
    }
    return url;
  }
}
