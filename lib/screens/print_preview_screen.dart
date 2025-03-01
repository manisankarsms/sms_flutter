import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../utils/PrintUtil.dart';

class PrintPreviewScreen extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<String>> data;

  const PrintPreviewScreen({
    Key? key,
    required this.title,
    required this.headers,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Print Preview")),
      body: PdfPreview(
        build: (format) => PrintUtil.generatePdf(title: title, headers: headers, data: data),
      ),
    );
  }
}
