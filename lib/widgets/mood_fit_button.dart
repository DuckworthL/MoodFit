import 'package:flutter/material.dart';
import 'package:moodfit/utils/design_system.dart';

enum MoodFitButtonType { primary, secondary, text }

class MoodFitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final MoodFitButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isDisabled;

  const MoodFitButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.type = MoodFitButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case MoodFitButtonType.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isDisabled || isLoading ? null : onPressed,
            style: MoodFitDesignSystem.primaryButtonStyle(context),
            child: _buildButtonContent(),
          ),
        );
      case MoodFitButtonType.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isDisabled || isLoading ? null : onPressed,
            style: MoodFitDesignSystem.secondaryButtonStyle(context),
            child: _buildButtonContent(),
          ),
        );
      case MoodFitButtonType.text:
        return TextButton(
          onPressed: isDisabled || isLoading ? null : onPressed,
          style: MoodFitDesignSystem.textButtonStyle(context),
          child: _buildButtonContent(),
        );
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == MoodFitButtonType.primary ? Colors.white : Colors.blue,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}
