import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';

Future<Uint8List> generateResumePdf(CvEntity cv) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(cv),
            pw.SizedBox(height: 40),
            _buildSection(
              title: 'PROFILE',
              content: _buildProfile(cv.summary ?? ''),
            ),
            pw.SizedBox(height: 40),
            _buildSection(
              title: 'WORK EXPERIENCE',
              content: _buildWorkExperience(cv.exp),
            ),
            pw.SizedBox(height: 40),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _buildSection(
                    title: 'EDUCATION',
                    content: _buildEducation(cv.edu),
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: _buildSection(
                    title: 'SKILLS',
                    content: _buildSkills(cv.skills),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 40),
            _buildSection(
              title: 'CERTIFICATIONS',
              content: _buildCertifications(),
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader(CvEntity cv) {
  return pw.Column(
    children: [
      pw.Text(
        cv.fullName.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 32,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 8,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        cv.title,
        style: pw.TextStyle(
          fontSize: 14,
          letterSpacing: 2,
          color: PdfColors.grey900,
        ),
      ),
      pw.SizedBox(height: 16),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          _buildContactItem(cv.phone),
          _buildSeparator(),
          _buildContactItem(cv.email),
          if (cv.website != null) ...[
            _buildSeparator(),
            _buildContactItem(cv.website!),
          ],
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Container(height: 1, color: PdfColors.grey300),
    ],
  );
}

pw.Widget _buildContactItem(String text) {
  return pw.Text(
    text,
    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
  );
}

pw.Widget _buildSeparator() {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8),
    child: pw.Text(
      '|',
      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
    ),
  );
}

pw.Widget _buildSection({required String title, required pw.Widget content}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 3,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 16),
      content,
    ],
  );
}

pw.Widget _buildProfile(String summary) {
  return pw.Text(
    summary,
    style: const pw.TextStyle(
      fontSize: 12,
      lineSpacing: 1.6,
      color: PdfColors.grey900,
    ),
  );
}

pw.Widget _buildWorkExperience(List<ExpEntity> experiences) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: experiences
        .map(
          (exp) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 16.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  exp.jobTitle.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  exp.companyName,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${exp.startDate.year} - ${exp.endDate.year}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  exp.description,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey900,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

pw.Widget _buildBulletPoint(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '. ',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey900),
        ),
        pw.Expanded(
          child: pw.Text(
            text,
            style: const pw.TextStyle(
              fontSize: 11,
              lineSpacing: 1.5,
              color: PdfColors.grey900,
            ),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildEducation(List<EduEntity> educations) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: educations
        .map(
          (edu) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  edu.degree,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  edu.institution,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey900,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  '${edu.startDate.year} - ${edu.endDate.year}',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

pw.Widget _buildSkills(List<String> skills) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: skills.map((skill) => _buildBulletPoint(skill)).toList(),
  );
}

pw.Widget _buildCertifications() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _buildBulletPoint('Licensed Real Estate Agent'),
      _buildBulletPoint('Certified Real Estate Negotiator'),
      _buildBulletPoint('Top Sales Agent Award 2016'),
    ],
  );
}

// ============================================
// PROFESSIONAL TEMPLATE PDF GENERATOR
// ============================================

Future<Uint8List> generateProfessionalResumePdf(CvEntity cv) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            _buildProfessionalHeader(cv),

            pw.Divider(thickness: 0.5, color: PdfColors.grey300),
            pw.SizedBox(height: 24),

            // Profile
            if (cv.summary?.isNotEmpty ?? false) ...[
              _buildProfessionalSection(
                'PROFILE',
                _buildProfessionalProfile(cv.summary!),
              ),
              pw.SizedBox(height: 20),
            ],

            // Work Experience
            if (cv.exp.isNotEmpty) ...[
              _buildProfessionalSection(
                'WORK EXPERIENCE',
                _buildProfessionalExperience(cv.exp),
              ),
              pw.SizedBox(height: 20),
            ],

            // Education and Skills Row
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (cv.edu.isNotEmpty)
                  pw.Expanded(
                    child: _buildProfessionalSection(
                      'EDUCATION',
                      _buildProfessionalEducation(cv.edu),
                    ),
                  ),

                pw.SizedBox(width: 24),

                if (cv.skills.isNotEmpty)
                  pw.Expanded(
                    child: _buildProfessionalSection(
                      'SKILLS',
                      _buildProfessionalSkills(cv.skills),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildProfessionalHeader(CvEntity cv) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      // Name
      pw.Text(
        cv.fullName.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 28,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 3,
        ),
        textAlign: pw.TextAlign.center,
      ),

      pw.SizedBox(height: 6),

      // Job Title
      pw.Text(
        cv.exp.isNotEmpty ? cv.exp.first.jobTitle : 'Professional',
        style: const pw.TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          color: PdfColors.grey700,
        ),
        textAlign: pw.TextAlign.center,
      ),

      pw.SizedBox(height: 12),

      // Contact Info
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            cv.phone,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6),
            child: pw.Text(
              '/',
              style: const pw.TextStyle(color: PdfColors.grey400),
            ),
          ),
          pw.Text(
            cv.email,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          if (cv.website?.isNotEmpty ?? false) ...[
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6),
              child: pw.Text(
                '/',
                style: const pw.TextStyle(color: PdfColors.grey400),
              ),
            ),
            pw.Text(
              cv.website!,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ],
      ),

      pw.SizedBox(height: 16),
    ],
  );
}

pw.Widget _buildProfessionalSection(String title, pw.Widget content) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      pw.SizedBox(height: 10),
      content,
    ],
  );
}

pw.Widget _buildProfessionalProfile(String summary) {
  return pw.Text(
    summary,
    style: const pw.TextStyle(
      fontSize: 10,
      height: 1.5,
      color: PdfColors.grey800,
    ),
    textAlign: pw.TextAlign.justify,
  );
}

pw.Widget _buildProfessionalExperience(List<ExpEntity> experiences) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: experiences.map((exp) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 14),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Job Title
            pw.Text(
              exp.jobTitle.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),

            pw.SizedBox(height: 3),

            // Company and Date
            pw.Text(
              '${exp.companyName} | ${_formatPdfDate(exp.startDate)} - ${_formatPdfDate(exp.endDate)}',
              style: pw.TextStyle(
                fontSize: 9,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),

            pw.SizedBox(height: 6),

            // Description with bullets
            ...exp.description
                .split('\n')
                .where((line) => line.trim().isNotEmpty)
                .map((line) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 12, bottom: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
                        pw.Expanded(
                          child: pw.Text(
                            line.trim(),
                            style: const pw.TextStyle(fontSize: 9, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                // ignore: unnecessary_to_list_in_spreads
                .toList(),
          ],
        ),
      );
    }).toList(),
  );
}

pw.Widget _buildProfessionalEducation(List<EduEntity> education) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: education.map((edu) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 12),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              edu.institution,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              '${edu.startDate.year} - ${edu.endDate.year}',
              style: pw.TextStyle(
                fontSize: 8,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey600,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(edu.degree, style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      );
    }).toList(),
  );
}

pw.Widget _buildProfessionalSkills(List<String> skills) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: skills.map((skill) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ', style: const pw.TextStyle(fontSize: 10)),
            pw.Expanded(
              child: pw.Text(skill, style: const pw.TextStyle(fontSize: 9)),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

String _formatPdfDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
