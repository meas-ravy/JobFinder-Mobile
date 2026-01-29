import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/cv/widget/resume_pdf_builder.dart';
import 'package:printing/printing.dart';

class ProfessionalTemplate extends StatelessWidget {
  final CvEntity cv;

  const ProfessionalTemplate({super.key, required this.cv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final pdfBytes = await generateProfessionalResumePdf(cv);
              await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(),

                const Divider(height: 40, thickness: 1, color: Colors.black12),

                // Profile Section
                if (cv.summary?.isNotEmpty ?? false) ...[
                  _buildSection('PROFILE', _buildProfile()),
                  const SizedBox(height: 32),
                ],

                // Work Experience Section
                if (cv.exp.isNotEmpty) ...[
                  _buildSection('WORK EXPERIENCE', _buildWorkExperience()),
                  const SizedBox(height: 32),
                ],

                // Education and Skills Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Education Column
                    if (cv.edu.isNotEmpty)
                      Expanded(
                        child: _buildSection('EDUCATION', _buildEducation()),
                      ),

                    const SizedBox(width: 32),

                    // Skills Column
                    if (cv.skills.isNotEmpty)
                      Expanded(child: _buildSection('SKILLS', _buildSkills())),
                  ],
                ),

                // Certifications Section (if you add it to CvEntity later)
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Name
        Text(
          cv.fullName.toUpperCase(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Job Title (using first experience job title or summary)
        Text(
          cv.exp.isNotEmpty ? cv.exp.first.jobTitle : 'Professional',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Contact Info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cv.phone,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('/', style: TextStyle(color: Colors.black26)),
            ),
            Text(
              cv.email,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            if (cv.website?.isNotEmpty ?? false) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('/', style: TextStyle(color: Colors.black26)),
              ),
              Text(
                cv.website!,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildProfile() {
    return Text(
      cv.summary ?? '',
      style: const TextStyle(fontSize: 12, height: 1.6, color: Colors.black87),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildWorkExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cv.exp.map((exp) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title
              Text(
                exp.jobTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              // Company and Date
              Text(
                '${exp.companyName} | ${_formatDate(exp.startDate)} - ${_formatDate(exp.endDate)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              // Description with bullet points
              ...exp.description.split('\n').map((line) {
                if (line.trim().isEmpty) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(
                          line.trim(),
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                edu.institution,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${edu.startDate.year} - ${edu.endDate.year}',
                style: const TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                edu.degree,
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cv.skills.map((skill) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(
                  skill,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
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
}
