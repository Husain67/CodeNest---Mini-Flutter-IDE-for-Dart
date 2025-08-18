import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CloudEmulatorScreen extends StatefulWidget {
  const CloudEmulatorScreen({super.key});

  @override
  State<CloudEmulatorScreen> createState() => _CloudEmulatorScreenState();
}

class _CloudEmulatorScreenState extends State<CloudEmulatorScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // The public key provided by the user
  final String appetizePublicKey = 'tok_g6hzvp5zb7nezwmfzuaoppxt64';

  @override
  void initState() {
    super.initState();

    final String embedUrl = 'https://appetize.io/embed/$appetizePublicKey?device=pixel_7_pro&osVersion=13.0&scale=75';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Emulator'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
