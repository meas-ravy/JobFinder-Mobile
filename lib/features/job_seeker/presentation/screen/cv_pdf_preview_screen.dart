import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/cv_template_factory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class CvPdfPreviewScreen extends StatelessWidget {
  final CvEntity cv;
  final String templateName;

  const CvPdfPreviewScreen({
    super.key,
    required this.cv,
    required this.templateName,
  });

  bool _hasNonLatinCharacters(CvEntity cv) {
    final allText = [
      cv.fullName,
      cv.summary,
      cv.address,
      ...cv.exp.map((e) => '${e.jobTitle} ${e.companyName} ${e.description}'),
      ...cv.edu.map((e) => '${e.degree} ${e.institution}'),
      ...cv.skills,
      ...cv.language,
      ...cv.ref.map((r) => '${r.name} ${r.position}'),
    ].join(' ');

    // Check if any character is outside the basic Latin / Latin-1 range
    return allText.runes.any((rune) => rune > 255);
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final hasUnicode = _hasNonLatinCharacters(cv);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (hasUnicode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber.shade900,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.pdfLanguageWarning,
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                      backgroundColor: colorTheme.primary,
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
      final fileName = '${cv.fullName.replaceAll(' ', '_')}_CV.pdf';
      final filePath = await _resolveDownloadPath(fileName);

      if (filePath == null) {
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Storage permission denied. Please allow storage access in Settings.',
          );
        }
        return;
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        _showDownloadSuccessSheet(context, fileName, filePath);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error downloading PDF: $e');
      }
    }
  }

  Future<String?> _resolveDownloadPath(String fileName) async {
    if (Platform.isAndroid) {
      // Android 10+ (API 29+): Scoped Storage — no permission needed for own files,
      // but public Downloads requires MANAGE_EXTERNAL_STORAGE or MediaStore.
      const publicDownloads = '/storage/emulated/0/Download';
      final dir = Directory(publicDownloads);

      if (await dir.exists()) {
        return '$publicDownloads/$fileName';
      }

      // Fallback: request legacy storage permission (Android 9 and below)
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return '$publicDownloads/$fileName';
      }

      // Last resort: app-specific external directory
      final fallback = await getExternalStorageDirectory();
      if (fallback != null) return '${fallback.path}/$fileName';

      return null;
    } else {
      // iOS: use Documents directory
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/$fileName';
    }
  }

  void _showDownloadSuccessSheet(
    BuildContext context,
    String fileName,
    String filePath,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const successGreen = Color(0xFF22D38A);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: successGreen.withValues(alpha: 0.15)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Glowing success icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: successGreen.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: successGreen.withValues(alpha: 0.25),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: successGreen,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'PDF Downloaded!',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Your CV has been saved successfully.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 16),

            // File name pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 18,
                    color: successGreen,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      fileName,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Open File button (gradient)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      successGreen,
                      successGreen.withValues(alpha: 0.75),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: successGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    OpenFile.open(filePath);
                  },
                  icon: const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Open File',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Back button (subtle)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(
                  'Back to CV',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
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
