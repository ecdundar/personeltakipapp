import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PDFViewerScreen extends StatefulWidget {
  final String PdfUrl;
  const PDFViewerScreen({super.key, required this.PdfUrl});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState(PdfUrl);
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final String PdfUrl;
  _PDFViewerScreenState(this.PdfUrl);
  bool isLoading = true;
  PDFDocument? document = null;

  loadDocument() async {
    document = await PDFDocument.fromURL(PdfUrl);
    setState(() => isLoading = false);
  }

  //Fix
  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  void downloadAndSharePdf() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = "${dir.path}/test.pdf";

    await Dio().download(PdfUrl, path);

    var file = new XFile(path);
    var files = List<XFile>.empty(growable: true);
    files.add(file);

    Share.shareXFiles(files,
        subject: 'Aydınlatma Metni', text: 'Sözleşme Metni');
  }

  void sharePdf() {
    Share.share(PdfUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("PDF Viewer"),
          actions: [
            GestureDetector(
                onTap: () {
                  //sharePdf(); TEXT STRING olarak paylaşım yapıyor.
                  downloadAndSharePdf();
                },
                child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: FaIcon(
                      FontAwesomeIcons.share,
                      size: 20,
                      color: Colors.white,
                    )))
          ],
        ),
        body: Container(
            child: isLoading || document == null
                ? Center(child: CircularProgressIndicator())
                : PDFViewer(
                    document: document!,
                    lazyLoad: false,
                    zoomSteps: 1,
                    numberPickerConfirmWidget: const Text(
                      "Confirm",
                    ))));
  }
}
