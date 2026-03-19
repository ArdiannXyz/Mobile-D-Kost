import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MidtransPage extends StatefulWidget {
  final String snapUrl;
  final String orderId;

  const MidtransPage({
    super.key,
    required this.snapUrl,
    required this.orderId,
  });

  @override
  State<MidtransPage> createState() => _MidtransScreenState();
}

class _MidtransScreenState extends State<MidtransPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          setState(() => _isLoading = false);
        },
        onNavigationRequest: (request) {
          final url = request.url;

          // Tangkap redirect setelah pembayaran selesai
          if (url.contains('payment/success') ||
              url.contains('transaction_status=settlement') ||
              url.contains('transaction_status=capture')) {
            Navigator.pop(context, 'success');
            return NavigationDecision.prevent;
          }

          if (url.contains('payment/pending') ||
              url.contains('transaction_status=pending')) {
            Navigator.pop(context, 'pending');
            return NavigationDecision.prevent;
          }

          if (url.contains('payment/failed') ||
              url.contains('transaction_status=deny') ||
              url.contains('transaction_status=cancel') ||
              url.contains('transaction_status=expire')) {
            Navigator.pop(context, 'failed');
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.snapUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, 'cancelled'),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}