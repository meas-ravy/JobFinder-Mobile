import 'dart:io';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/repos/cv_template_strategy.dart';

class SampleTemplatePdf implements CvTemplateStrategy {
  @override
  Future<void> build(pw.Document pdf, CvEntity cv) async {
    // Load profile image if available
    pw.MemoryImage? profileImage;
    if (cv.imgurl.isNotEmpty) {
      try {
        final file = File(cv.imgurl);
        if (await file.exists()) {
          profileImage = pw.MemoryImage(await file.readAsBytes());
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error loading profile image: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- LEFT COLUMN ---
              pw.Container(
                width: 185,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    if (profileImage != null)
                      pw.Container(
                        width: 170,
                        height: 170,
                        decoration: pw.BoxDecoration(
                          image: pw.DecorationImage(
                            image: profileImage,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      pw.Container(
                        width: 170,
                        height: 170,
                        color: PdfColors.grey300,
                      ),

                    pw.SizedBox(height: 32),

                    // CONTACT
                    _buildLeftSectionTitle('CONTACT'),
                    pw.SizedBox(height: 14),
                    pw.Text(cv.phone, style: const pw.TextStyle(fontSize: 13)),
                    pw.SizedBox(height: 4),
                    pw.Text(cv.email, style: const pw.TextStyle(fontSize: 13)),
                    if (cv.website?.isNotEmpty ?? false) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        cv.website!,
                        style: const pw.TextStyle(fontSize: 13),
                      ),
                    ],

                    pw.SizedBox(height: 32),

                    // EDUCATION
                    if (cv.edu.isNotEmpty) ...[
                      _buildLeftSectionTitle('EDUCATION'),
                      pw.SizedBox(height: 12),
                      ...cv.edu.map(
                        (edu) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 20),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                edu.degree,
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                edu.institution,
                                style: const pw.TextStyle(fontSize: 13),
                              ),
                              pw.SizedBox(height: 7),
                              pw.Text(
                                '${edu.startDate.year} - ${edu.endDate.year}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    pw.SizedBox(height: 24),

                    // SKILLS
                    if (cv.skills.isNotEmpty) ...[
                      _buildLeftSectionTitle('SKILLS'),
                      pw.SizedBox(height: 12),
                      ...cv.skills.map(
                        (skill) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Text(
                            skill,
                            style: const pw.TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],

                    pw.SizedBox(height: 32),

                    // REFERENCES
                    _buildLeftSectionTitle('REFERENCES'),
                    pw.SizedBox(height: 12),
                    if (cv.ref.isNotEmpty)
                      ...cv.ref.map(
                        (ref) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                ref.name,
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                ref.position,
                                style: const pw.TextStyle(fontSize: 13),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                ref.phone,
                                style: const pw.TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      pw.Text(
                        'Provided upon request.',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),

              pw.SizedBox(width: 40),

              // --- RIGHT COLUMN ---
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Name & Title
                    pw.SizedBox(height: 10),
                    pw.Text(
                      cv.fullName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 36,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      (cv.exp.isNotEmpty
                          ? cv.exp.first.jobTitle
                          : 'UX Designer'),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),

                    pw.SizedBox(height: 40),

                    // SUMMARY
                    _buildRightSectionTitle('SUMMARY'),
                    pw.SizedBox(height: 12),
                    pw.Text(
                      cv.summary ?? '',
                      style: const pw.TextStyle(fontSize: 12, height: 1.5),
                    ),

                    pw.SizedBox(height: 40),

                    // WORK EXPERIENCE
                    if (cv.exp.isNotEmpty) ...[
                      _buildRightSectionTitle('WORK EXPERIENCE'),
                      pw.SizedBox(height: 18),
                      ...cv.exp.map(
                        (exp) => pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 24),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                exp.jobTitle.toUpperCase(),
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                exp.companyName,
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Text(
                                '${exp.startDate.year} - ${exp.endDate.year == DateTime.now().year ? "Present" : exp.endDate.year}',
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                              pw.SizedBox(height: 8),
                              ...exp.description
                                  .split('\n')
                                  .where((s) => s.trim().isNotEmpty)
                                  .map((line) {
                                    // Clean user input: remove manually typed bullets/dashes
                                    String cleanLine = line.trim();
                                    if (cleanLine.startsWith('•') ||
                                        cleanLine.startsWith('-') ||
                                        cleanLine.startsWith('*')) {
                                      cleanLine = cleanLine.substring(1).trim();
                                    }

                                    return pw.Padding(
                                      padding: const pw.EdgeInsets.only(
                                        bottom: 5,
                                      ),
                                      child: pw.Row(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.only(
                                              top: 5,
                                              right: 8,
                                            ),
                                            child: pw.Container(
                                              width: 3.5,
                                              height: 3.5,
                                              decoration:
                                                  const pw.BoxDecoration(
                                                    color: PdfColors.black,
                                                    shape: pw.BoxShape.circle,
                                                  ),
                                            ),
                                          ),
                                          pw.Expanded(
                                            child: pw.Text(
                                              cleanLine,
                                              style: const pw.TextStyle(
                                                fontSize: 12,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  pw.Widget _buildLeftSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2.5,
          ),
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  pw.Widget _buildRightSectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 2.5,
          ),
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }
}
