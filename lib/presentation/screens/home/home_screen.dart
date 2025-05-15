// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:megapdf_flutter_client/core/theme/app_theme.dart';
import 'package:megapdf_flutter_client/core/widgets/feature_card.dart';
import 'package:megapdf_flutter_client/presentation/router/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:megapdf_flutter_client/data/models/pdf_file.dart';
import 'package:megapdf_flutter_client/providers/file_service_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFiles = ref.watch(recentFilesProvider);
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom app bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("MegaPDF"),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -20,
                      child: Opacity(
                        opacity: 0.2,
                        child: Icon(
                          Icons.picture_as_pdf,
                          size: 200,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Powerful PDF Tools",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push(RouteNames.settingsPath),
              ),
            ],
          ),

          // Welcome section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "What would you like to do today?",
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Select an operation to get started with your PDF files",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // PDF Operations grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: mediaQuery.size.width > 600 ? 3 : 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 600),
                    columnCount: mediaQuery.size.width > 600 ? 3 : 2,
                    child: SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(
                        child: _buildFeatureCard(context, index),
                      ),
                    ),
                  );
                },
                childCount: 8,
              ),
            ),
          ),

          // Recent activity section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Activity",
                        style: theme.textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history),
                        label: const Text("View all"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Recent files list
          SliverToBoxAdapter(
            child: recentFiles.when(
              data: (files) {
                if (files.isEmpty) {
                  return Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/empty_box.json',
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No recent files",
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your recent files will appear here",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 180,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      final file = files[index];
                      return _RecentFileCard(file: file);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text("Error loading recent files: $error"),
              ),
            ),
          ),

          // Some space at the bottom
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Show a bottom sheet with quick actions
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            builder: (context) => _QuickActionsBottomSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Quick Action"),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, int index) {
    final features = [
      {
        'title': 'Compress PDF',
        'description': 'Reduce file size while maintaining quality',
        'icon': Icons.compress,
        'color': Colors.blue,
        'route': RouteNames.compressPath,
        'heroTag': 'compress-card',
      },
      {
        'title': 'Convert PDF',
        'description': 'Convert to and from multiple formats',
        'icon': Icons.transform,
        'color': Colors.purple,
        'route': RouteNames.convertPath,
        'heroTag': 'convert-card',
      },
      {
        'title': 'Merge PDFs',
        'description': 'Combine multiple PDFs into one',
        'icon': Icons.merge_type,
        'color': Colors.green,
        'route': RouteNames.mergePath,
        'heroTag': 'merge-card',
      },
      {
        'title': 'Split PDF',
        'description': 'Extract pages or split into multiple files',
        'icon': Icons.call_split,
        'color': Colors.orange,
        'route': RouteNames.splitPath,
        'heroTag': 'split-card',
      },
      {
        'title': 'Protect PDF',
        'description': 'Add password and encryption',
        'icon': Icons.lock_outline,
        'color': Colors.red,
        'route': RouteNames.protectPath,
        'heroTag': 'protect-card',
      },
      {
        'title': 'Repair PDF',
        'description': 'Fix corrupted PDF files',
        'icon': Icons.build,
        'color': Colors.teal,
        'route': RouteNames.repairPath,
        'heroTag': 'repair-card',
      },
      {
        'title': 'Sign PDF',
        'description': 'Add signatures to documents',
        'icon': Icons.draw,
        'color': Colors.indigo,
        'route': RouteNames.signPath,
        'heroTag': 'sign-card',
      },
      {
        'title': 'OCR PDF',
        'description': 'Make scanned documents searchable',
        'icon': Icons.document_scanner,
        'color': Colors.amber,
        'route': RouteNames.ocrPath,
        'heroTag': 'ocr-card',
      },
    ];

    final feature = features[index];

    return FeatureCard(
      title: feature['title'] as String,
      description: feature['description'] as String,
      icon: feature['icon'] as IconData,
      accentColor: feature['color'] as Color,
      heroTag: feature['heroTag'] as String,
      onTap: () => context.push(feature['route'] as String),
    );
  }
}

class _RecentFileCard extends StatelessWidget {
  final PdfFile file;

  const _RecentFileCard({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            context.push(
              RouteNames.fileViewerPath,
              extra: {
                'fileUrl': file.path,
                'fileName': file.name,
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.extension?.toUpperCase() ?? 'PDF',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  file.name,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  file.formattedSize,
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  _getFormattedDate(file.lastModified),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class _QuickActionsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Text(
            "Quick Actions",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickActionItem(
                icon: Icons.picture_as_pdf,
                label: "Open PDF",
                color: Colors.blue,
                onTap: () {
                  // Logic to open PDF
                  Navigator.pop(context);
                },
              ),
              _QuickActionItem(
                icon: Icons.compress,
                label: "Compress",
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.compressPath);
                },
              ),
              _QuickActionItem(
                icon: Icons.merge_type,
                label: "Merge",
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.mergePath);
                },
              ),
              _QuickActionItem(
                icon: Icons.call_split,
                label: "Split",
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  context.push(RouteNames.splitPath);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
