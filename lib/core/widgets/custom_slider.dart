import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomSlider({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliderTheme(
      data: theme.sliderTheme.copyWith(
        trackHeight: 6.0,
        activeTrackColor: theme.colorScheme.primary,
        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
        thumbColor: Colors.white,
        overlayColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
      ),
      child: Slider(
        min: 0.0,
        max: max,
        value: value.clamp(0.0, max),
        onChanged: onChanged,
      ),
    );
  }
}
