import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter/foundation.dart';

/// Lightweight OAuth helper for Microsoft identity platform using PKCE.
///
/// Configure these before using:
/// - clientId: Azure AD App registration Application (client) ID
/// - redirectUrl: must be registered in Azure (e.g., com.your.app://auth)
/// - tenant: 'common' for MSA + AAD, or your tenant id
/// - scopes: include 'offline_access' and Microsoft Graph scopes (e.g., 'Files.ReadWrite')
class MicrosoftOAuth {
  MicrosoftOAuth({
    required this.clientId,
    required this.redirectUrl,
    this.tenant = 'common',
    this.scopes = const <String>[
      'offline_access',
      'User.Read',
      'Files.ReadWrite'
    ],
  });

  final String clientId;
  final String redirectUrl;
  final String tenant;
  final List<String> scopes;

  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  String get _discoveryUrl =>
      'https://login.microsoftonline.com/$tenant/v2.0/.well-known/openid-configuration';

  Future<AuthorizationTokenResponse?> signInInteractive() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          serviceConfiguration: null,
          discoveryUrl: _discoveryUrl,
          scopes: scopes,
          preferEphemeralSession: false,
          allowInsecureConnections: false,
        ),
      );
      return result;
    } catch (e) {
      debugPrint('MicrosoftOAuth.signInInteractive error: $e');
      rethrow;
    }
  }

  Future<TokenResponse?> refreshToken({required String refreshToken}) async {
    try {
      final result = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          refreshToken: refreshToken,
          discoveryUrl: _discoveryUrl,
          scopes: scopes,
        ),
      );
      return result;
    } catch (e) {
      debugPrint('MicrosoftOAuth.refreshToken error: $e');
      rethrow;
    }
  }
}
