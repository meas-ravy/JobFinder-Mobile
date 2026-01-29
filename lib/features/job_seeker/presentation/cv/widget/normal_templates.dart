import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/presentation/cv/widget/resume_pdf_builder.dart';
import 'package:printing/printing.dart';

import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';

class NormalTemplates extends StatelessWidget {
  final CvEntity cv;

  const NormalTemplates({super.key, required this.cv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pdfBytes = await generateResumePdf(cv);
          await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
        },
        child: const Icon(Icons.picture_as_pdf),
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeader(cv),

                const SizedBox(height: 40),

                // Profile Section
                _buildSection(
                  title: 'PROFILE',
                  content: _buildProfile(cv.summary ?? ''),
                ),

                const SizedBox(height: 40),

                // Work Experience Section
                _buildSection(
                  title: 'WORK EXPERIENCE',
                  content: _buildWorkExperience(cv.exp),
                ),

                const SizedBox(height: 40),

                // Education and Skills Section (Two Columns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildSection(
                        title: 'EDUCATION',
                        content: _buildEducation(cv.edu),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 1,
                      child: _buildSection(
                        title: 'SKILLS',
                        content: _buildSkills(cv.skills),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Certifications Section
                _buildSection(
                  title: 'CERTIFICATIONS',
                  content: _buildCertifications(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CvEntity cv) {
    return Column(
      children: [
        // Name
        Text(
          cv.fullName.toUpperCase(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Title
        Text(
          cv.title,
          style: const TextStyle(
            fontSize: 14,
            letterSpacing: 2,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Contact Info
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(height: 20),

        // Divider
        Container(height: 1, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildContactItem(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, color: Colors.black54),
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text('|', style: TextStyle(fontSize: 11, color: Colors.black54)),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildProfile(String summary) {
    return Text(
      summary,
      style: const TextStyle(fontSize: 12, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildWorkExperience(List<ExpEntity> experiences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: experiences
          .map(
            (exp) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.jobTitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exp.companyName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exp.startDate.year} - ${exp.endDate.year}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exp.description,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              text,
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
  }

  Widget _buildEducation(List<EduEntity> educations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: educations
          .map(
            (edu) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    edu.degree,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    edu.institution,
                    style: const TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${edu.startDate.year} - ${edu.endDate.year}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSkills(List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skills.map((skill) => _buildBulletPoint(skill)).toList(),
    );
  }

  Widget _buildCertifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint('Licensed Real Estate Agent'),
        _buildBulletPoint('Certified Real Estate Negotiator'),
        _buildBulletPoint('Top Sales Agent Award 2016'),
      ],
    );
  }
}
