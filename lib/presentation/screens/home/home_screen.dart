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
            // Top row of buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TopButton(label: 'All', isSelected: true),
                _TopButton(label: 'Organize', isSelected: false),
                _TopButton(label: 'Optimize', isSelected: false),
                _TopButton(label: 'Convert', isSelected: false),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'PDF Operations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const _OperationsGrid(),
          ],
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _TopButton({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.red : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
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
      crossAxisCount: 3, // Updated to 3 columns as per the image
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1, // Make the cards more square
      children: [
        _OperationCard(
          title: 'IMG to PDF',
          icon: Icons.image_outlined,
          color: Colors.red,
          onTap: () =>
              context.push(RouteNames.convertPath), // Update path as needed
        ),
        _OperationCard(
          title: 'Office to PDF',
          icon: Icons.description_outlined,
          color: Colors.blue,
          onTap: () => context.push(RouteNames.convertPath),
        ),
        _OperationCard(
          title: 'Compress PDF',
          icon: Icons.compress,
          color: Colors.green,
          onTap: () => context.push(RouteNames.compressPath),
        ),
        _OperationCard(
          title: 'Merge PDF',
          icon: Icons.merge_type,
          color: Colors.purple,
          onTap: () => context.push(RouteNames.mergePath),
        ),
        _OperationCard(
          title: 'PDF to JPG',
          icon: Icons.image_outlined,
          color: Colors.orange,
          onTap: () => context.push(RouteNames.convertPath),
        ),
        _OperationCard(
          title: 'Split PDF',
          icon: Icons.call_split,
          color: Colors.teal,
          onTap: () => context.push(RouteNames.splitPath),
        ),
        _OperationCard(
          title: 'Recognize Text (OCR)',
          icon: Icons.text_fields,
          color: Colors.indigo,
          onTap: () => context.push(RouteNames.convertPath),
        ),
        _OperationCard(
          title: 'Annotate PDF',
          icon: Icons.edit_outlined,
          color: Colors.pink,
          onTap: () => context.push(RouteNames.signPath),
        ),
        _OperationCard(
          title: 'Organize PDF',
          icon: Icons.sort,
          color: Colors.cyan,
          onTap: () => context.push(RouteNames.mergePath),
        ),
        _OperationCard(
          title: 'Unlock PDF',
          icon: Icons.lock_open,
          color: Colors.redAccent,
          onTap: () => context.push(RouteNames.unlockPath),
        ),
        _OperationCard(
          title: 'Sign PDF',
          icon: Icons.draw,
          color: Colors.blueAccent,
          onTap: () => context.push(RouteNames.signPath),
        ),
        _OperationCard(
          title: 'Watermark PDF',
          icon: Icons.water_drop_outlined,
          color: Colors.grey,
          onTap: () => context.push(RouteNames.protectPath),
        ),
        _OperationCard(
          title: 'Rotate PDF',
          icon: Icons.rotate_right,
          color: Colors.amber,
          onTap: () => context.push(RouteNames.rotatePath),
        ),
        _OperationCard(
          title: 'Protect PDF',
          icon: Icons.lock_outline,
          color: Colors.greenAccent,
          onTap: () => context.push(RouteNames.protectPath),
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
        borderRadius: BorderRadius.circular(12), // Slightly smaller radius
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 24, // Smaller icon size to match the image
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12, // Smaller font size
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
