import 'package:flutter/material.dart';
import 'package:hef/src/data/constants/style_constants.dart';
import 'package:hef/src/interface/components/loading_indicator/loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:hef/src/data/constants/color_constants.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final Color color;
  const WebViewScreen({
    Key? key,
    required this.url,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: kSmallTitleM,
        ),
        backgroundColor: widget.color,
        foregroundColor: kWhite,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: LoadingAnimation()
            ),
        ],
      ),
    );
  }
}
