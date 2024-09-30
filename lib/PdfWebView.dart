import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfWebView extends StatefulWidget {
  final String pdfUrl;

  const PdfWebView({super.key, required this.pdfUrl});

  @override
  _PdfWebViewState createState() => _PdfWebViewState();
}

class _PdfWebViewState extends State<PdfWebView> {
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(
          "https://docs.google.com/gview?embedded=true&url=${widget.pdfUrl}"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
