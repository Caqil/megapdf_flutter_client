// lib/presentation/screens/user/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/constants/app_constants.dart';
import 'package:megapdf_flutter_client/core/utils/file_utils.dart';
import 'package:megapdf_flutter_client/core/widgets/app_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Settings theme state
enum AppThemeMode {
  system,
  light,
  dark,
}

// Provider for the app theme mode
final appThemeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.system;
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      // Fallback version if package info fails
      setState(() {
        _appVersion = AppConstants.appVersion;
      });
    }
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will remove all temporary files. Your saved files will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await FileUtils.cleanupTempFiles();
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy() async {
    final uri = Uri.parse('https://example.com/privacy-policy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openTermsOfService() async {
    final uri = Uri.parse('https://example.com/terms-of-service');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openHelpCenter() async {
    final uri = Uri.parse('https://example.com/help-center');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appThemeMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            child: Column(
              children: [
                _buildSettingsItem(
                  title: 'Theme',
                  subtitle: 'Change the app theme',
                  trailing: DropdownButton<AppThemeMode>(
                    value: appThemeMode,
                    underline: const SizedBox.shrink(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(appThemeModeProvider.notifier).state = value;
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: AppThemeMode.system,
                        child:
                            Text('System', style: theme.textTheme.bodyMedium),
                      ),
                      DropdownMenuItem(
                        value: AppThemeMode.light,
                        child: Text('Light', style: theme.textTheme.bodyMedium),
                      ),
                      DropdownMenuItem(
                        value: AppThemeMode.dark,
                        child: Text('Dark', style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Storage section
          _buildSectionHeader(context, 'Storage'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            child: Column(
              children: [
                _buildSettingsItem(
                  title: 'Clear Cache',
                  subtitle: 'Remove temporary files to free up space',
                  trailing: AppButton(
                    label: 'Clear',
                    onPressed: _clearCache,
                    type: AppButtonType.outline,
                    size: AppButtonSize.small,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Help & Support section
          _buildSectionHeader(context, 'Help & Support'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            child: Column(
              children: [
                _buildSettingsItem(
                  title: 'Help Center',
                  subtitle: 'View guides and tutorials',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _openHelpCenter,
                ),
                const Divider(),
                _buildSettingsItem(
                  title: 'Privacy Policy',
                  subtitle: 'View our privacy policy',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _openPrivacyPolicy,
                ),
                const Divider(),
                _buildSettingsItem(
                  title: 'Terms of Service',
                  subtitle: 'View our terms of service',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _openTermsOfService,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About section
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            child: Column(
              children: [
                _buildSettingsItem(
                  title: 'Version',
                  subtitle: _appVersion,
                  trailing: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: child,
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required String subtitle,
    required Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
