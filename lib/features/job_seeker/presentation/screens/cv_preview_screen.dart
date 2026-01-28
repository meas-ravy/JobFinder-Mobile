import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_data.dart';

class CvPreviewScreen extends StatelessWidget {
  const CvPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for preview
    final cvData = CvData(
      personalDetails: PersonalDetails(
        name: 'John Doe',
        email: 'john.doe@example.com',
        phoneNumber: '+1234567890',
        address: '123 Main Street, Anytown, USA',
      ),
      summary:
          'A highly motivated and experienced software developer with a passion for creating innovative solutions. Proficient in various programming languages and technologies.',
      experiences: [
        Experience(
          jobTitle: 'Senior Software Engineer',
          companyName: 'Tech Solutions Inc.',
          startDate: 'Jan 2020',
          endDate: 'Present',
          description:
              '- Led the development of a new mobile application.\n- Mentored junior developers.',
        ),
        Experience(
          jobTitle: 'Software Engineer',
          companyName: 'Web Services LLC',
          startDate: 'Jun 2017',
          endDate: 'Dec 2019',
          description:
              '- Developed and maintained web applications.\n- Collaborated with cross-functional teams.',
        ),
      ],
      educations: [
        Education(
          degree: 'Master of Science in Computer Science',
          institution: 'University of Technology',
          startDate: '2015',
          endDate: '2017',
        ),
        Education(
          degree: 'Bachelor of Science in Computer Science',
          institution: 'State University',
          startDate: '2011',
          endDate: '2015',
        ),
      ],
      skills: ['Flutter', 'Dart', 'Firebase', 'Python', 'JavaScript'],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Preview'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPersonalDetails(cvData.personalDetails),
            const SizedBox(height: 24),
            _buildSectionTitle('Summary'),
            const SizedBox(height: 8),
            Text(cvData.summary),
            const SizedBox(height: 24),
            _buildSectionTitle('Experience'),
            const SizedBox(height: 8),
            _buildExperienceList(cvData.experiences),
            const SizedBox(height: 24),
            _buildSectionTitle('Education'),
            const SizedBox(height: 8),
            _buildEducationList(cvData.educations),
            const SizedBox(height: 24),
            _buildSectionTitle('Skills'),
            const SizedBox(height: 8),
            _buildSkillsGrid(cvData.skills),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetails(PersonalDetails details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          details.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(details.email),
        Text(details.phoneNumber),
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

  Widget _buildExperienceList(List<Experience> experiences) {
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

  Widget _buildEducationList(List<Education> educations) {
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
      children: skills
          .map((skill) => Chip(
                label: Text(skill),
              ))
          .toList(),
    );
  }
}
