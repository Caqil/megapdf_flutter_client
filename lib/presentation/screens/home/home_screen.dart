import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:megapdf_flutter_client/core/constants/theme_constants.dart';
import 'package:megapdf_flutter_client/presentation/router/route_names.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Tools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteNames.settingsPath),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDF Operations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const _OperationsGrid(),
            const SizedBox(height: 32),
            Text(
              'Recent Operations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const _RecentOperations(),
          ],
        ),
      ),
    );
  }
}

class _OperationsGrid extends StatelessWidget {
  const _OperationsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _OperationCard(
          title: 'Compress PDF',
          icon: Icons.compress,
          color: AppColors.primary,
          onTap: () => context.push(RouteNames.compressPath),
        ),
        _OperationCard(
          title: 'Convert PDF',
          icon: Icons.transform,
          color: AppColors.secondary,
          onTap: () => context.push(RouteNames.convertPath),
        ),
        _OperationCard(
          title: 'Merge PDFs',
          icon: Icons.merge_type,
          color: Colors.green,
          onTap: () => context.push(RouteNames.mergePath),
        ),
        _OperationCard(
          title: 'Split PDF',
          icon: Icons.call_split,
          color: Colors.orange,
          onTap: () => context.push(RouteNames.splitPath),
        ),
        _OperationCard(
          title: 'Protect PDF',
          icon: Icons.lock_outline,
          color: Colors.purple,
          onTap: () => context.push(RouteNames.protectPath),
        ),
        _OperationCard(
          title: 'Unlock PDF',
          icon: Icons.lock_open,
          color: Colors.teal,
          onTap: () => context.push(RouteNames.unlockPath),
        ),
        _OperationCard(
          title: 'Repair PDF',
          icon: Icons.build,
          color: Colors.red,
          onTap: () => context.push(RouteNames.repairPath),
        ),
        _OperationCard(
          title: 'Sign PDF',
          icon: Icons.draw,
          color: Colors.blue,
          onTap: () => context.push(RouteNames.signPath),
        ),
      ],
    );
  }
}

class _OperationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OperationCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentOperations extends StatelessWidget {
  const _RecentOperations();

  @override
  Widget build(BuildContext context) {
    // This would normally fetch from a provider or service
    // For now, we'll use a placeholder
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      child: const Center(
        child: Text("You don't have any recent operations"),
      ),
    );
  }
}
