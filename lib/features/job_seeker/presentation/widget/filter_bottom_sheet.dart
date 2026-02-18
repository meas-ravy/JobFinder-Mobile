import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/search_state.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/filter/chip_group.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/filter/filter_content_card.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/filter/location_salary_card.dart';

class FilterBottomSheet extends HookConsumerWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onApply;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    // All tabs
    final tabs = [
      'Location & Salary',
      'Work Type',
      'Job Level',
      'Employment Type',
      'Experience',
      'Education',
      'Job Function',
    ];

    final selectedTab = useState(0);
    final isExpanded = useState(true);

    final tabController = useTabController(initialLength: tabs.length);

    useEffect(() {
      void listener() {
        // Update selected tab immediately when the index changes
        if (selectedTab.value != tabController.index) {
          selectedTab.value = tabController.index;
          isExpanded.value = true;
        }
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    // Filter values
    final location = useState<String?>(currentFilters.location);
    final salaryRange = useState<RangeValues>(
      RangeValues(
        currentFilters.salaryMin ?? 0,
        currentFilters.salaryMax ?? 20000,
      ),
    );
    final salaryPeriod = useState<String>('per month');
    final workArrangement = useState<String?>(currentFilters.workArrangement);
    final experienceLevel = useState<String?>(currentFilters.experienceLevel);
    final employmentType = useState<String?>(currentFilters.employmentType);
    final category = useState<String?>(currentFilters.category);
    final experience = useState<String?>(null);
    final education = useState<String?>(null);

    void reset() {
      location.value = null;
      salaryRange.value = const RangeValues(0, 20000);
      salaryPeriod.value = 'per month';
      workArrangement.value = null;
      experienceLevel.value = null;
      employmentType.value = null;
      category.value = null;
      experience.value = null;
      education.value = null;
      isExpanded.value = true;
      tabController.animateTo(0);
    }

    // Build content for the selected tab
    Widget buildContent() {
      void toggle() => isExpanded.value = !isExpanded.value;

      switch (selectedTab.value) {
        case 0: // Location & Salary
          return LocationSalaryCard(
            isDark: isDark,
            colorScheme: colorScheme,
            location: location,
            salaryRange: salaryRange,
            salaryPeriod: salaryPeriod,
            isExpanded: isExpanded.value,
            onToggle: toggle,
          );
        case 1: // Work Type
          return FilterContentCard(
            isDark: isDark,
            title: 'Work Type',
            isExpanded: isExpanded.value,
            onToggle: toggle,
            child: ChipGroup(
              isDark: isDark,
              options: const ['OnSite', 'Remote', 'Hybrid'],
              selected: workArrangement.value,
              onSelected: (v) =>
                  workArrangement.value = workArrangement.value == v ? null : v,
            ),
          );
        case 2: // Job Level
          return FilterContentCard(
            isDark: isDark,
            title: 'Job Level',
            isExpanded: isExpanded.value,
            onToggle: toggle,
            child: ChipGroup(
              isDark: isDark,
              options: const [
                'Entry',
                'Mid',
                'Senior',
                'Lead',
                'Director',
                'Executive',
              ],
              selected: experienceLevel.value,
              onSelected: (v) =>
                  experienceLevel.value = experienceLevel.value == v ? null : v,
            ),
          );
        case 3: // Employment Type
          return FilterContentCard(
            isDark: isDark,
            title: 'Employment Type',
            isExpanded: isExpanded.value,
            onToggle: toggle,
            child: ChipGroup(
              isDark: isDark,
              options: const [
                'FullTime',
                'PartTime',
                'Contract',
                'Internship',
                'Freelance',
              ],
              selected: employmentType.value,
              onSelected: (v) =>
                  employmentType.value = employmentType.value == v ? null : v,
            ),
          );
        case 4: // Experience
          return FilterContentCard(
            isDark: isDark,
            title: 'Experience',
            isExpanded: isExpanded.value,
            onToggle: toggle,
            child: ChipGroup(
              isDark: isDark,
              options: const [
                '0-1 Years',
                '1-3 Years',
                '3-5 Years',
                '5-10 Years',
                '10+ Years',
              ],
              selected: experience.value,
              onSelected: (v) =>
                  experience.value = experience.value == v ? null : v,
            ),
          );
        case 5: // Education
          return FilterContentCard(
            isDark: isDark,
            title: 'Education',
            isExpanded: isExpanded.value,
            onToggle: toggle,
            child: ChipGroup(
              isDark: isDark,
              options: const [
                'High School',
                'Associate',
                'Bachelor',
                'Master',
                'Doctorate',
              ],
              selected: education.value,
              onSelected: (v) =>
                  education.value = education.value == v ? null : v,
            ),
          );
        case 6: // Job Function
          return FilterContentCard(
            isDark: isDark,
            title: 'Job Function',
            isExpanded: isExpanded.value,
            onToggle: toggle,
            child: ChipGroup(
              isDark: isDark,
              options: const [
                'Technology',
                'Healthcare',
                'Finance',
                'Education',
                'Marketing',
                'Sales',
                'Engineering',
                'Design',
                'CustomerService',
                'HumanResources',
                'Operations',
                'Legal',
                'Other',
              ],
              selected: category.value,
              onSelected: (v) =>
                  category.value = category.value == v ? null : v,
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColor.backgroundColorDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag Handle ──
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Options',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // ── Animated TabBar ──
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: tabController,
                    isScrollable: true,
                    physics: const BouncingScrollPhysics(),
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors.transparent,
                    indicatorColor: AppColor.primaryDark,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColor.primaryDark,
                    unselectedLabelColor: Colors.grey[500],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tabs: const [
                      Tab(text: 'Location & Salary'),
                      Tab(text: 'Work Type'),
                      Tab(text: 'Job Level'),
                      Tab(text: 'Employment Type'),
                      Tab(text: 'Experience'),
                      Tab(text: 'Education'),
                      Tab(text: 'Job Function'),
                    ],
                    onTap: (index) {
                      selectedTab.value = index;
                      isExpanded.value = true;
                    },
                  ),
                ),
              ),

              Divider(
                height: 1,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),

              // ── Tab Content ──
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: SizedBox(
                      key: ValueKey(selectedTab.value),
                      width: double.infinity,
                      child: buildContent(),
                    ),
                  ),
                ),
              ),

              // ── Bottom Buttons ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                decoration: BoxDecoration(
                  color: isDark ? AppColor.backgroundColorDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: reset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white
                              : Colors.black87,
                          side: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newFilters = SearchFilters(
                            location: location.value,
                            salaryMin: salaryRange.value.start > 0
                                ? salaryRange.value.start
                                : null,
                            salaryMax: salaryRange.value.end < 20000
                                ? salaryRange.value.end
                                : null,
                            workArrangement: workArrangement.value,
                            experienceLevel: experienceLevel.value,
                            employmentType: employmentType.value,
                            category: category.value,
                          );
                          onApply(newFilters);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryDark,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
