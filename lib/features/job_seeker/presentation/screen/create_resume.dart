import 'package:flutter/material.dart';

class BuildTemplate extends StatefulWidget {
  const BuildTemplate({super.key});
  @override
  State<BuildTemplate> createState() => _BuildTemplateState();
}

class _BuildTemplateState extends State<BuildTemplate>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          "Select Template",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: colorScheme.primary,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          labelStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Modern"),
            Tab(text: "Professional"),
            Tab(text: "Creative"),
            Tab(text: "Minimal"),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for a template...",
                  prefixIcon: const Icon(Icons.search),
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // Template Grid
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  5,
                  (tabIndex) => GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return _TemplateCard(
                        title: "Template ${tabIndex * 10 + index + 1}",
                        onTap: () {
                          // Navigate to CV builder with this template
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Selected Template ${tabIndex * 10 + index + 1}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Template Preview
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              // Template Name
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
