import 'package:flutter/material.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/job_seeker/data/model/template_model.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/cv_form_screen.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/shared/widget/zomtap_animation.dart';
import 'package:job_finder/l10n/app_localizations.dart';

class BuildTemplate extends StatefulWidget {
  const BuildTemplate({super.key});
  @override
  State<BuildTemplate> createState() => _BuildTemplateState();
}

class _BuildTemplateState extends State<BuildTemplate> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<String> _getTabs(AppLocalizations l10n) => [
    l10n.allTab,
    l10n.simpleTab,
    l10n.professionalTab,
    l10n.minimalistTab,
    l10n.modernTab,
  ];

  final List<String> _categoryKey = [
    "All",
    "Simple",
    "Professional",
    "Minimalist",
    "Modern",
  ];

  @override
  void initState() {
    super.initState();
    filteredTemp = allTemp;
    _searchController.addListener(_filterTemp);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTemp);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTemp() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      final selectedCategory = _categoryKey[_selectedTabIndex];

      filteredTemp = allTemp.where((template) {
        final matchesSearch =
            template.displayName.toLowerCase().contains(query) ||
            template.category.toLowerCase().contains(query);
        final matchesCategory =
            selectedCategory == 'All' || template.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final tabs = _getTabs(l10n);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        //backgroundColor: colorScheme.surface,
        title: Text(
          l10n.chooseTemplate,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),

              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchTemplateHint,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  focusColor: colorScheme.onSurface,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: colorScheme.onSurface),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppSvgIcon(
                      assetName: AppIcon.search,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
            ),

            // Category Tabs
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 20),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isSelected = _selectedTabIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                            _filterTemp();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tab,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Template Grid
            Expanded(
              child: filteredTemp.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noTemplatesFound,
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.65,
                          ),
                      itemCount: filteredTemp.length,
                      itemBuilder: (context, index) {
                        final template = filteredTemp[index];
                        return _TemplateCard(
                          template: template,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CvFormScreen(selectedTemplate: template),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onTap});

  final TempModel template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ZomtapAnimation(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview Card Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.08,
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(template.icon, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
