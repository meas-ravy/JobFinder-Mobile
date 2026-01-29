import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/presentation/screens/cv_preview_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/cv/templates/professional_template.dart';
import 'package:job_finder/features/job_seeker/presentation/cv/templates/modern_template.dart';
import 'package:job_finder/features/job_seeker/presentation/cv/templates/sampl_template.dart';

class TemplateSelectionScreen extends StatelessWidget {
  final CvEntity cv;

  const TemplateSelectionScreen({super.key, required this.cv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Template')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
        children: [
          _buildTemplateCard(context, 'Normal', Icons.description, Colors.blue),
          _buildTemplateCard(
            context,
            'Professional',
            Icons.business_center,
            Colors.green,
          ),
          _buildTemplateCard(
            context,
            'Modern',
            Icons.auto_awesome,
            Colors.purple,
          ),
          _buildTemplateCard(context, 'Sample', Icons.article, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    String name,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                // Route to the appropriate template
                switch (name) {
                  case 'Professional':
                    return ProfessionalTemplate(cv: cv);
                  case 'Modern':
                    return ModernTemplate(cv: cv);
                  case 'Sample':
                    return SampleTemplate(cv: cv);
                  case 'Normal':
                  default:
                    return CvPreviewScreen(cv: cv);
                }
              },
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _getTemplateDescription(name),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTemplateDescription(String name) {
    switch (name) {
      case 'Normal':
        return 'Classic layout';
      case 'Professional':
        return 'Clean & minimal';
      case 'Modern':
        return 'Colorful & dynamic';
      case 'Sample':
        return 'Simple & clean';
      default:
        return '';
    }
  }
}
