import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generateResumePdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            pw.SizedBox(height: 40),
            _buildSection(title: 'PROFILE', content: _buildProfile()),
            pw.SizedBox(height: 40),
            _buildSection(
              title: 'WORK EXPERIENCE',
              content: _buildWorkExperience(),
            ),
            pw.SizedBox(height: 40),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _buildSection(
                    title: 'EDUCATION',
                    content: _buildEducation(),
                  ),
                ),
                pw.SizedBox(width: 40),
                pw.Expanded(
                  child: _buildSection(
                    title: 'SKILLS',
                    content: _buildSkills(),
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

pw.Widget _buildHeader() {
  return pw.Column(
    children: [
      pw.Text(
        'CONNOR HAMILTON',
        style: pw.TextStyle(
          fontSize: 32,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 8,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 8),
      pw.Text(
        'Real Estate Agent',
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
          _buildContactItem('123-456-7890'),
          _buildSeparator(),
          _buildContactItem('hello@reallygreatsite.com'),
          _buildSeparator(),
          _buildContactItem('reallygreatsite.com'),
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

pw.Widget _buildProfile() {
  return pw.Text(
    'I am an experienced Real Estate Agent with a passion for helping clients find their dream homes. I have extensive experience in the industry, including more than 5 years working as a real estate agent. I am knowledgeable about the latest market trends and understand the nuances of the real estate market. I pride myself on my ability to negotiate the best deals for my clients and to navigate complex real estate agreements. I am highly organized, detail-oriented, and have strong communication skills.',
    style: const pw.TextStyle(
      fontSize: 12,
      lineSpacing: 1.6,
      color: PdfColors.grey900,
    ),
  );
}

pw.Widget _buildWorkExperience() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'REAL ESTATE AGENT',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Really Great Company',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'June 2015 - Present',
        style: pw.TextStyle(
          fontSize: 11,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey600,
        ),
      ),
      pw.SizedBox(height: 12),
      _buildBulletPoint(
        'Negotiate contracts and complex real estate transactions',
      ),
      _buildBulletPoint('Provide excellent customer service to clients'),
      _buildBulletPoint('Update and maintain client files'),
      _buildBulletPoint('Research and monitor the local real estate market'),
      _buildBulletPoint('Develop marketing campaigns for properties'),
      _buildBulletPoint('Utilize social media platforms to market properties'),
      _buildBulletPoint('Participate in open houses and home tours'),
    ],
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

pw.Widget _buildEducation() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'University',
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey900,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        '2010 - 2014',
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'B.A. in Business Administration',
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey900),
      ),
    ],
  );
}

pw.Widget _buildSkills() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _buildBulletPoint('Knowledge of the local real estate market'),
      _buildBulletPoint('Communication skills'),
      _buildBulletPoint('Negotiation skills'),
      _buildBulletPoint('Problem-solving skills'),
      _buildBulletPoint('Organizational and time management skills'),
    ],
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
