import 'dart:ui' as ui;
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class SunburstChartScreen extends StatelessWidget {
  const SunburstChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Register the HTML view for the web platform
    ui.platformViewRegistry.registerViewFactory(
      'sunburst-chart-html',
      (int viewId) => IFrameElement()
        ..src = 'http://localhost:8000/sunburst-chart'
        ..style.border = 'none',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunburst Chart'),
      ),
      body: const HtmlElementView(viewType: 'sunburst-chart-html'),
    );
  }
}