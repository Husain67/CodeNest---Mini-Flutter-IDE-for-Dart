import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:uni_links/uni_links.dart';

class GitHubService {
  // IMPORTANT: Replace with your actual GitHub OAuth App credentials.
  // You can get one for free from your GitHub developer settings.
  final String clientId = ''; // <-- PASTE YOUR GITHUB OAUTH CLIENT ID HERE
  final List<String> scopes = ['repo', 'user'];

  GitHub? _github;

  GitHub? get github => _github;
  bool get isAuthenticated => _github != null;

  Future<void> authenticate() async {
    final authUrl = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': clientId,
      'scope': scopes.join(' '),
      'redirect_uri': 'simple-app://oauth-callback',
    });

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl, webOnlyWindowName: '_self');
    } else {
      throw 'Could not launch $authUrl';
    }

    // Listen for the callback
    final completer = Completer<String>();
    final sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'simple-app' && uri.host == 'oauth-callback') {
        final code = uri.queryParameters['code'];
        if (code != null) {
          completer.complete(code);
        }
      }
    });

    await completer.future; // Wait for the callback, but we don't use the code
    sub.cancel();

    // Exchange code for an access token (simplified, no server-side component)
    // NOTE: In a real-world app, this exchange should happen on a secure server
    // to protect your clientSecret.
    // This is a simplified example for demonstration purposes.

    // As we cannot securely make the token exchange request from the client-side
    // without exposing the clientSecret, we'll stop here for this example.
    // A real implementation would require a backend service or a PKCE flow.

    // For now, the authentication process stops after getting the code.
    // A full implementation is required to make this functional.

    // Since we cannot proceed, we cannot create a GitHub instance.
    // _github = GitHub(auth: Authentication.withToken(accessToken));
  }

  // In a real app, you would add methods here to interact with the GitHub API,
  // such as committing and pushing files.
}
