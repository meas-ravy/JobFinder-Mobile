import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/presentation/templates/widget/resume_pdf_builder.dart';
import 'package:printing/printing.dart';

class NormalTemplates extends StatelessWidget {
  const NormalTemplates({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pdfBytes = await generateResumePdf();
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
                _buildHeader(),

                const SizedBox(height: 40),

                // Profile Section
                _buildSection(title: 'PROFILE', content: _buildProfile()),

                const SizedBox(height: 40),

                // Work Experience Section
                _buildSection(
                  title: 'WORK EXPERIENCE',
                  content: _buildWorkExperience(),
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
                        content: _buildEducation(),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 1,
                      child: _buildSection(
                        title: 'SKILLS',
                        content: _buildSkills(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Name
        const Text(
          'CONNOR HAMILTON',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // Title
        const Text(
          'Real Estate Agent',
          style: TextStyle(
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
            _buildContactItem('123-456-7890'),
            _buildSeparator(),
            _buildContactItem('hello@reallygreatsite.com'),
            _buildSeparator(),
            _buildContactItem('reallygreatsite.com'),
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

  Widget _buildProfile() {
    return const Text(
      'I am an experienced Real Estate Agent with a passion for helping clients find their dream homes. I have extensive experience in the industry, including more than 5 years working as a real estate agent. I am knowledgeable about the latest market trends and understand the nuances of the real estate market. I pride myself on my ability to negotiate the best deals for my clients and to navigate complex real estate agreements. I am highly organized, detail-oriented, and have strong communication skills.',
      style: TextStyle(fontSize: 12, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildWorkExperience() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REAL ESTATE AGENT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Really Great Company',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'June 2015 - Present',
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        _buildBulletPoint(
          'Negotiate contracts and complex real estate transactions',
        ),
        _buildBulletPoint('Provide excellent customer service to clients'),
        _buildBulletPoint('Update and maintain client files'),
        _buildBulletPoint('Research and monitor the local real estate market'),
        _buildBulletPoint('Develop marketing campaigns for properties'),
        _buildBulletPoint(
          'Utilize social media platforms to market properties',
        ),
        _buildBulletPoint('Participate in open houses and home tours'),
      ],
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

  Widget _buildEducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'University',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '2010 - 2014',
          style: TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        const Text(
          'B.A. in Business Administration',
          style: TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint('Knowledge of the local real estate market'),
        _buildBulletPoint('Communication skills'),
        _buildBulletPoint('Negotiation skills'),
        _buildBulletPoint('Problem-solving skills'),
        _buildBulletPoint('Organizational and time management skills'),
      ],
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
