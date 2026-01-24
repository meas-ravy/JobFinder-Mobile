import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecruiterProfilePage extends StatelessWidget {
  const RecruiterProfilePage({super.key});

  static const List<_ProfileMenuItem> _menuItems = [
    _ProfileMenuItem(
      title: 'Notification',
      icon: Icons.notifications_none_rounded,
      isHighlight: true,
    ),
    // _ProfileMenuItem(title: 'Summary', icon: Icons.insert_drive_file_outlined),
    _ProfileMenuItem(title: 'Swich Role', icon: Icons.settings_outlined),
    _ProfileMenuItem(title: 'Privacy Policy', icon: Icons.privacy_tip_outlined),
    _ProfileMenuItem(title: 'Support', icon: Icons.support_agent_rounded),
    _ProfileMenuItem(title: 'Logout', icon: Icons.logout_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = scheme.surfaceContainerHighest;
    final cardBorder = scheme.outlineVariant.withValues(
      alpha: isDark ? 0.6 : 0.4,
    );
    final textPrimary = scheme.onSurface;
    final textMuted = scheme.onSurface.withValues(alpha: isDark ? 0.6 : 0.7);
    final highlight = scheme.primary;
    final highlightText = scheme.onPrimary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Profile',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ProfileCard(
                cardColor: cardColor,
                cardBorder: cardBorder,
                textPrimary: textPrimary,
                textMuted: textMuted,
                accent: highlight,
                accentText: highlightText,
                showShadow: !isDark,
              ),
              const SizedBox(height: 18),
              ..._menuItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MenuTile(
                    item: item,
                    cardColor: cardColor,
                    cardBorder: cardBorder,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    highlight: highlight,
                    highlightText: highlightText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.cardColor,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
    required this.accentText,
    required this.showShadow,
  });

  final Color cardColor;
  final Color cardBorder;
  final Color textPrimary;
  final Color textMuted;
  final Color accent;
  final Color accentText;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorder),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: accent),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Akibur Rahman',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Product Designer',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'akiburrrahman@example.com',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 16,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                'A',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.cardColor,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.highlight,
    required this.highlightText,
  });

  final _ProfileMenuItem item;
  final Color cardColor;
  final Color cardBorder;
  final Color textPrimary;
  final Color textMuted;
  final Color highlight;
  final Color highlightText;

  @override
  Widget build(BuildContext context) {
    final isHighlight = item.isHighlight;
    final background = isHighlight ? highlight : cardColor;
    final iconColor = isHighlight ? highlightText : highlight;
    final arrowColor = isHighlight ? highlightText : textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isHighlight
                  ? highlightText.withValues(alpha: 0.2)
                  : highlight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: arrowColor),
        ],
      ),
    );
  }
}

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.title,
    required this.icon,
    this.isHighlight = false,
  });

  final String title;
  final IconData icon;
  final bool isHighlight;
}
