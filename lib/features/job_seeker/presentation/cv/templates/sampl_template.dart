import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/cv/widget/resume_pdf_builder.dart';
import 'package:printing/printing.dart';

class SampleTemplate extends StatelessWidget {
  final CvEntity cv;

  const SampleTemplate({super.key, required this.cv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final pdfBytes = await generateResumePdf(cv);
              await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Side stripe accent
              Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.cyan.shade600],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Simple Clean Header
                    _buildHeader(),

                    const Divider(height: 48, thickness: 1),

                    // Profile Summary
                    if (cv.summary?.isNotEmpty ?? false) ...[
                      _buildSectionTitle('Professional Summary'),
                      const SizedBox(height: 12),
                      _buildProfile(),
                      const SizedBox(height: 32),
                    ],

                    // Work Experience
                    if (cv.exp.isNotEmpty) ...[
                      _buildSectionTitle('Work Experience'),
                      const SizedBox(height: 16),
                      _buildWorkExperience(),
                      const SizedBox(height: 32),
                    ],

                    // Education
                    if (cv.edu.isNotEmpty) ...[
                      _buildSectionTitle('Education'),
                      const SizedBox(height: 16),
                      _buildEducation(),
                      const SizedBox(height: 32),
                    ],

                    // Skills
                    if (cv.skills.isNotEmpty) ...[
                      _buildSectionTitle('Skills'),
                      const SizedBox(height: 16),
                      _buildSkills(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cv.fullName,
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: Colors.teal.shade800,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cv.exp.isNotEmpty ? cv.exp.first.jobTitle : 'Professional',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildContactItem(Icons.email_outlined, cv.email),
            const SizedBox(width: 24),
            _buildContactItem(Icons.phone_outlined, cv.phone),
          ],
        ),
        if (cv.website?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildContactItem(Icons.language_outlined, cv.website!),
          ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.teal.shade700),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.teal.shade600, width: 4)),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.teal.shade800,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.shade200, width: 1),
      ),
      child: Text(
        cv.summary ?? '',
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildWorkExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cv.exp.map((exp) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.jobTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exp.companyName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exp.startDate.year} - ${exp.endDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                exp.description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cv.edu.map((edu) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.teal.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edu.degree,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      edu.institution,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${edu.startDate.year} - ${edu.endDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkills() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: cv.skills.map((skill) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.teal.shade200, width: 1),
            ),
            child: Text(
              skill,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.teal.shade900,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
