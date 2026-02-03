import '../repos/cv_template_strategy.dart';
import '../../presentation/cv/templates/sampl_template.dart';
import '../../presentation/cv/templates/professional_template_pdf.dart';

class CvTemplateFactory {
  static CvTemplateStrategy getStrategy(String name) {
    switch (name) {
      case 'Professional':
        return ProfessionalTemplatePdf();
      case 'Normal':
      default:
        return SampleTemplatePdf();
    }
  }
}
