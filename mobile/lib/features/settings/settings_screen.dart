import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeTile(
            context,
            ref,
            title: 'Light',
            icon: Icons.light_mode,
            mode: ThemeMode.light,
            currentMode: themeNotifier.themeMode,
          ),
          _buildThemeTile(
            context,
            ref,
            title: 'Dark',
            icon: Icons.dark_mode,
            mode: ThemeMode.dark,
            currentMode: themeNotifier.themeMode,
          ),
          _buildThemeTile(
            context,
            ref,
            title: 'System',
            icon: Icons.brightness_auto,
            mode: ThemeMode.system,
            currentMode: themeNotifier.themeMode,
          ),
          const Divider(),
          _buildSectionHeader('Accessibility'),
          _buildFontSizeSection(context, ref, themeNotifier.fontSize),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.contrast),
            title: const Text('High Contrast'),
            subtitle: const Text('Increase color contrast for better visibility'),
            value: themeNotifier.highContrast,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setHighContrast(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.animation),
            title: const Text('Reduce Animations'),
            subtitle: const Text('Minimize motion effects throughout the app'),
            value: themeNotifier.reduceAnimations,
            onChanged: (value) {
              ref.read(themeProvider.notifier).setReduceAnimations(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    return RadioListTile<ThemeMode>(
      secondary: Icon(icon),
      title: Text(title),
      value: mode,
      groupValue: currentMode,
      onChanged: (value) {
        if (value != null) {
          ref.read(themeProvider.notifier).setThemeMode(value);
        }
      },
      activeColor: AppColors.primary,
    );
  }

  Widget _buildFontSizeSection(
    BuildContext context,
    WidgetRef ref,
    double currentFontSize,
  ) {
    String sizeLabel;
    if (currentFontSize <= 0.85) {
      sizeLabel = 'Small';
    } else if (currentFontSize >= 1.15) {
      sizeLabel = 'Large';
    } else {
      sizeLabel = 'Medium';
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.text_fields),
          title: const Text('Font Size'),
          subtitle: Text(sizeLabel),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('A', style: TextStyle(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: currentFontSize,
                  min: 0.85,
                  max: 1.15,
                  divisions: 2,
                  label: sizeLabel,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).setFontSize(value);
                  },
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40),
            _buildSizeLabel('Small', currentFontSize <= 0.85),
            const Spacer(),
            _buildSizeLabel('Medium', currentFontSize > 0.85 && currentFontSize < 1.15),
            const Spacer(),
            _buildSizeLabel('Large', currentFontSize >= 1.15),
            const SizedBox(width: 40),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeLabel(String label, bool isActive) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: isActive ? AppColors.primary : AppColors.textHint,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
