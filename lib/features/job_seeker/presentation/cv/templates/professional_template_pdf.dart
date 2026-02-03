import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/repos/cv_template_strategy.dart';

class ProfessionalTemplatePdf implements CvTemplateStrategy {
  @override
  Future<void> build(pw.Document pdf, CvEntity cv) async {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Professional Header with Accent Color
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      cv.fullName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Icon(
                          const pw.IconData(0xe0be),
                          color: PdfColors.white,
                          size: 14,
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          cv.email,
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                        pw.SizedBox(width: 20),
                        pw.Icon(
                          const pw.IconData(0xe0cd),
                          color: PdfColors.white,
                          size: 14,
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          cv.phone,
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 24),

              if (cv.summary != null && cv.summary!.isNotEmpty) ...[
                _buildProfessionalSectionTitle('PROFESSIONAL SUMMARY'),
                pw.SizedBox(height: 8),
                pw.Text(cv.summary!, style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 20),
              ],

              pw.Text(
                'Other sections coming soon...',
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildProfessionalSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(width: 2, color: PdfColors.blue700),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blue700,
        ),
      ),
    );
  }
}
