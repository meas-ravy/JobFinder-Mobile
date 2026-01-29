import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';

class CvPreviewScreen extends StatelessWidget {
  final CvEntity? cv;

  const CvPreviewScreen({super.key, this.cv});

  @override
  Widget build(BuildContext context) {
    final cvData = cv;
    if (cvData == null) {
      return const Scaffold(body: Center(child: Text('No CV Data')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('CV Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalDetails(cvData),
            const SizedBox(height: 24),
            _buildSectionTitle('Summary'),
            const SizedBox(height: 8),
            Text(cvData.summary ?? ''),
            const SizedBox(height: 24),
            _buildSectionTitle('Experience'),
            const SizedBox(height: 8),
            _buildExperienceList(cvData.exp),
            const SizedBox(height: 24),
            _buildSectionTitle('Education'),
            const SizedBox(height: 8),
            _buildEducationList(cvData.edu),
            const SizedBox(height: 24),
            _buildSectionTitle('Skills'),
            const SizedBox(height: 8),
            _buildSkillsGrid(cvData.skills),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetails(CvEntity details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.fullName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(details.email),
        Text(details.phone),
        Text(details.address),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildExperienceList(List<ExpEntity> experiences) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final experience = experiences[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${experience.jobTitle} at ${experience.companyName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${experience.startDate} - ${experience.endDate}'),
              const SizedBox(height: 4),
              Text(experience.description),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEducationList(List<EduEntity> educations) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: educations.length,
      itemBuilder: (context, index) {
        final education = educations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                education.degree,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(education.institution),
              Text('${education.startDate} - ${education.endDate}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillsGrid(List<String> skills) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: skills.map((skill) => Chip(label: Text(skill))).toList(),
    );
  }
}
