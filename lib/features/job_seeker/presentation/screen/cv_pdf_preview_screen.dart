import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/cv_template_factory.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/jobb_seeker_document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

class CvPdfPreviewScreen extends StatelessWidget {
  final CvEntity cv;
  final String templateName;

  const CvPdfPreviewScreen({
    super.key,
    required this.cv,
    required this.templateName,
  });

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Preview'),
        centerTitle: true,
        elevation: 0,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.white),
              child: PdfPreviewCustom(
                scrollViewDecoration: BoxDecoration(color: colorTheme.surface),
                pdfPreviewPageDecoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                build: (format) => _generatePdf(format),
                previewPageMargin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                shouldRepaint: false,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    onPressed: () => _sharePdf(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.download),
                    label: const Text("Download"),
                    onPressed: () => _downloadPdf(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// Generate PDF from CV data
  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // Use Strategy Pattern to build the PDF logic
    try {
      final strategy = CvTemplateFactory.getStrategy(templateName);
      await strategy.build(pdf, cv);
    } catch (e) {
      debugPrint('Error building PDF: $e');
      // Add a fallback page so pdf.save() doesn't throw RangeError
      pdf.addPage(
        pw.Page(
          build: (context) =>
              pw.Center(child: pw.Text('Error generating PDF: $e')),
        ),
      );
    }

    return pdf.save();
  }

  /// Download PDF to device
  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = await _generatePdf(PdfPageFormat.a4);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${cv.fullName.replaceAll(' ', '_')}_CV.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: Text('PDF downloaded successfully to:\n$fileName'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyDocumentPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      OpenFile.open(filePath);
                    },
                    child: const Text('View'),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Share PDF via Share Sheet
  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = await _generatePdf(PdfPageFormat.a4);
      final fileName = '${cv.fullName.replaceAll(' ', '_')}_CV.pdf';

      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
