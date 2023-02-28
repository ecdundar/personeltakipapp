import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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
                  sharePdf();
                },
                child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.share, color: Colors.white)))
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
