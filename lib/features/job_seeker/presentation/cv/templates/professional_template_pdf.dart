import 'dart:io';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/format_special_character.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../domain/repos/cv_template_strategy.dart';

class ProfessionalTemplatePdf implements CvTemplateStrategy {
  static const darkBlue = PdfColor.fromInt(0xff2d3447);
  static const contactBarColor = PdfColor.fromInt(0xff727e91);
  static const white = PdfColors.white;
  static const black = PdfColors.black;
  static const grey = PdfColor.fromInt(0xff666666);
  static const lightGrey = PdfColor.fromInt(0xffe0e0e0);

  @override
  Future<void> build(pw.Document pdf, CvEntity cv) async {
    // Load Profile Image
    pw.MemoryImage? profileImage;
    if (cv.imgurl.isNotEmpty) {
      final file = File(cv.imgurl);
      if (await file.exists()) {
        profileImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // 1. Dark Background
              pw.Container(
                width: double.infinity,
                height: double.infinity,
                color: darkBlue,
              ),

              // 2. Main Layout
              pw.Column(
                children: [
                  // --- TOP AREA ---
                  pw.Container(
                    height: 320,
                    child: pw.Stack(
                      children: [
                        // Name & Title
                        pw.Positioned(
                          top: 60,
                          left: 40,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                cleanText(cv.fullName).toUpperCase(),
                                style: pw.TextStyle(
                                  color: white,
                                  fontSize: 42,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Text(
                                cleanText(
                                  cv.exp.isNotEmpty
                                      ? cv.exp.first.jobTitle
                                      : 'GRAPHIC DESIGNER',
                                ).toUpperCase(),
                                style: pw.TextStyle(
                                  color: white,
                                  fontSize: 14,
                                  letterSpacing: 4.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // PROFILE IMAGE
                        pw.Positioned(
                          top: 40,
                          right: 40,
                          child: pw.Container(
                            width: 190,
                            height: 225,
                            decoration: pw.BoxDecoration(
                              color: lightGrey,
                              borderRadius: const pw.BorderRadius.only(
                                topRight: pw.Radius.circular(40),
                              ),
                              image: profileImage != null
                                  ? pw.DecorationImage(
                                      image: profileImage,
                                      fit: pw.BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                        ),

                        // CONTACT STRIP
                        pw.Positioned(
                          top: 220,
                          left: 0,
                          right: 120,
                          child: pw.Container(
                            height: 70,
                            decoration: const pw.BoxDecoration(
                              color: contactBarColor,
                              borderRadius: pw.BorderRadius.only(
                                topRight: pw.Radius.circular(30),
                              ),
                            ),
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 70,
                            ),
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    _buildContactItem(
                                      cv.phone,
                                      AppIcon.phoneSvg,
                                    ),
                                    pw.SizedBox(height: 8),
                                    _buildContactItem(
                                      cv.email,
                                      AppIcon.emailSvg,
                                    ),
                                  ],
                                ),
                                pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    _buildContactItem(
                                      cv.website ?? 'www.site.com',
                                      AppIcon.webSvg,
                                    ),
                                    pw.SizedBox(height: 8),
                                    _buildContactItem(
                                      cv.address,
                                      AppIcon.locationSvg,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- WHITE BODY SECTION ---
                  pw.Expanded(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.only(left: 25, top: -30),
                      decoration: const pw.BoxDecoration(
                        color: white,
                        borderRadius: pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(30),
                          bottomLeft: pw.Radius.circular(30),
                        ),
                      ),
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(40),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 185,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Education'),
                                  ...cv.edu.map((edu) => _buildEduItem(edu)),
                                  _buildSectionTitle('Skills'),
                                  ...cv.skills.map(
                                    (skill) => _buildSkillItem(skill),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(width: 35),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('About me'),
                                  pw.Text(
                                    cleanText(cv.summary),
                                    style: const pw.TextStyle(
                                      fontSize: 11,
                                      height: 1.4,
                                    ),
                                  ),
                                  pw.SizedBox(height: 10),
                                  _buildSectionTitle('Experience'),
                                  ...cv.exp.map((exp) => _buildExpItem(exp)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- FOOTER SECTION ---
                  pw.Container(
                    height: 120,
                    padding: const pw.EdgeInsets.symmetric(horizontal: 60),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // Left Footer Column (Language)
                        pw.Container(
                          width: 180,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 10),

                              _buildFooterSectionTitle('Language'),
                              ...cv.language.map(
                                (lang) => pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 6),
                                  child: pw.Text(
                                    cleanText(lang),
                                    style: const pw.TextStyle(
                                      color: white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(width: 35),
                        // Right Footer Column (Reference)
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(height: 10),
                              _buildFooterSectionTitle('Reference'),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: cv.ref
                                    .take(2)
                                    .map(
                                      (ref) => pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          right: 30,
                                        ),
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text(
                                              '${cleanText(ref.name)} | ${cleanText(ref.position)}',
                                              style: pw.TextStyle(
                                                color: white,
                                                fontWeight: pw.FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                            pw.SizedBox(height: 2),
                                            pw.Text(
                                              ref.phone,
                                              style: const pw.TextStyle(
                                                color: white,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Helpers ---

  pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12, top: 10),
      child: pw.Row(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: black,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(child: pw.Container(height: 1, color: lightGrey)),
        ],
      ),
    );
  }

  pw.Widget _buildFooterSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: white,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Container(height: 1, color: const PdfColor(1, 1, 1, 0.2)),
          ),
        ],
      ),
    );
  }

  // Updated Contact Item using SVG Code Strings
  pw.Widget _buildContactItem(String text, String svgCode) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 14,
          height: 14,
          padding: const pw.EdgeInsets.all(2),
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: white, width: 0.8),
          ),
          child: pw.SvgImage(svg: svgCode),
        ),
        pw.SizedBox(width: 12),
        pw.Text(
          cleanText(text),
          style: const pw.TextStyle(color: white, fontSize: 11),
        ),
      ],
    );
  }

  pw.Widget _buildEduItem(EduEntity edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 13),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cleanText(edu.degree),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            cleanText(edu.institution),
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${edu.startDate.year}-${edu.endDate.year}',
            style: const pw.TextStyle(fontSize: 12, color: grey),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSkillItem(String skill) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Text(cleanText(skill), style: const pw.TextStyle(fontSize: 11)),
    );
  }

  pw.Widget _buildExpItem(ExpEntity exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                cleanText(exp.jobTitle),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                '${exp.startDate.year}-${exp.endDate.year}',
                style: const pw.TextStyle(fontSize: 9, color: grey),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            cleanText(exp.companyName),
            style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
          ),
          pw.SizedBox(height: 6),
          ...exp.description
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .map((line) => _buildBullet(cleanText(line))),
        ],
      ),
    );
  }

  pw.Widget _buildBullet(String text) {
    String cleanLine = text.trim();
    if (cleanLine.startsWith('•') ||
        cleanLine.startsWith('-') ||
        cleanLine.startsWith('*')) {
      cleanLine = cleanLine.substring(1).trim();
    }
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 3,
          height: 3,
          margin: const pw.EdgeInsets.only(top: 4, right: 6),
          decoration: const pw.BoxDecoration(
            color: black,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            cleanLine,
            style: const pw.TextStyle(fontSize: 10, height: 1.2),
          ),
        ),
      ],
    );
  }
}
