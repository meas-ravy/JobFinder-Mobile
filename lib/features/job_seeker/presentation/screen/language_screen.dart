import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/l10n/app_localizations.dart';

class LanguageScreen extends HookWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final searchController = useTextEditingController();
    final searchQuery = useValueListenable(searchController);

    final suggestions = [
      (name: l10n.cambodia, flag: AppIcon.flagCambodia, code: 'km'),
      (name: l10n.englishUS, flag: AppIcon.flagUs, code: 'en'),
    ];

    final allLanguages = [
      (name: l10n.japan, flag: AppIcon.flagJapan, code: 'ja'),
      (name: l10n.korean, flag: AppIcon.flagKorean, code: 'ko'),
      (name: l10n.china, flag: AppIcon.flagChina, code: 'zh'),
      (name: l10n.malaysia, flag: AppIcon.flagMalasy, code: 'ms'),
      (name: l10n.laos, flag: AppIcon.flagLaos, code: 'lo'),
    ];

    final filteredAll = allLanguages
        .where(
          (l) => l.name.toLowerCase().contains(searchQuery.text.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colorScheme.onSurface),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseLanguage,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectLanguageSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),

            _SectionHeader(title: l10n.suggestion, textTheme: textTheme),
            const SizedBox(height: 12),
            ValueListenableBuilder<Locale?>(
              valueListenable: localeController,
              builder: (context, currentLocale, _) {
                final currentCode = currentLocale?.languageCode ?? 'en';
                return Column(
                  children: suggestions.map((lang) {
                    final isSelected = currentCode == lang.code;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LanguageTile(
                        name: lang.name,
                        flag: lang.flag,
                        isSelected: isSelected,
                        onTap: () =>
                            localeController.setLocale(Locale(lang.code)),
                        showBorder: isSelected,
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 12),
            _SectionHeader(title: l10n.allLanguagesLabel, textTheme: textTheme),
            const SizedBox(height: 16),

            // Search Bar
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: TextField(
                controller: searchController,
                textAlignVertical: TextAlignVertical.center,
                style: textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  prefixIcon: UnconstrainedBox(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 10),
                      child: SvgPicture.asset(
                        AppIcon.search,
                        width: 18,
                        height: 18,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onSurface.withValues(alpha: 0.4),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  suffixIcon: searchQuery.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () => searchController.clear(),
                          child: Icon(
                            Icons.cancel,
                            size: 20,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),
            ValueListenableBuilder<Locale?>(
              valueListenable: localeController,
              builder: (context, currentLocale, _) {
                final currentCode = currentLocale?.languageCode ?? 'en';
                return Column(
                  children: filteredAll.map((lang) {
                    final isSelected = currentCode == lang.code;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _LanguageTile(
                        name: lang.name,
                        flag: lang.flag,
                        isSelected: isSelected,
                        onTap: () =>
                            localeController.setLocale(Locale(lang.code)),
                        showBorder: isSelected,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final TextTheme textTheme;

  const _SectionHeader({required this.title, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String name;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBorder;

  const _LanguageTile({
    required this.name,
    required this.flag,
    required this.isSelected,
    required this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: showBorder
              ? Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: SvgPicture.asset(
                  flag,
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => Container(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                    child: const Icon(Icons.flag, size: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 22)
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
