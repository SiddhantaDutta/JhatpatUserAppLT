import 'package:flutter/material.dart';
import 'package:jhatpat/constants/app_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: WebView(
          initialUrl: AppConstants.termsAndConditionUrl,
          zoomEnabled: false,
        ),
      ),
    );
  }
}
