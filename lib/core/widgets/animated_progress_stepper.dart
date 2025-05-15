// lib/core/widgets/animated_progress_stepper.dart
import 'package:flutter/material.dart';
import 'package:megapdf_flutter_client/core/theme/app_theme.dart';

class ProgressStep {
  final String title;
  final IconData icon;
  final Widget content;

  ProgressStep({
    required this.title,
    required this.icon,
    required this.content,
  });
}

class AnimatedProgressStepper extends StatefulWidget {
  final List<ProgressStep> steps;
  final int currentStep;
  final Function(int) onStepTapped;
  final Function() onContinue;
  final Function() onCancel;
  final bool canContinue;

  const AnimatedProgressStepper({
    Key? key,
    required this.steps,
    required this.currentStep,
    required this.onStepTapped,
    required this.onContinue,
    required this.onCancel,
    this.canContinue = true,
  }) : super(key: key);

  @override
  _AnimatedProgressStepperState createState() =>
      _AnimatedProgressStepperState();
}

class _AnimatedProgressStepperState extends State<AnimatedProgressStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedProgressStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStepper(),
        Expanded(
          child: FadeTransition(
            opacity: _animation,
            child: widget.steps[widget.currentStep].content,
          ),
        ),
        _buildControls(),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      height: 100,
      child: Row(
        children: List.generate(widget.steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            return Expanded(
              child: _buildStep(stepIndex),
            );
          } else {
            return _buildLine((index ~/ 2) < widget.currentStep);
          }
        }),
      ),
    );
  }

  Widget _buildStep(int index) {
    final isActive = index == widget.currentStep;
    final isCompleted = index < widget.currentStep;

    final Color color = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : Colors.grey;

    return GestureDetector(
      onTap: () => widget.onStepTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(isActive || isCompleted ? 1.0 : 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white)
                  : Icon(widget.steps[index].icon, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.steps[index].title,
            style: TextStyle(
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 2,
      color: isActive ? AppColors.success : Colors.grey.withOpacity(0.3),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.currentStep > 0)
            OutlinedButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          if (widget.currentStep < widget.steps.length - 1)
            ElevatedButton.icon(
              onPressed: widget.canContinue ? widget.onContinue : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: widget.canContinue ? widget.onContinue : null,
              icon: const Icon(Icons.check),
              label: const Text('Finish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
