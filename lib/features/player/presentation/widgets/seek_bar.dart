import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/custom_slider.dart';
import '../bloc/player_cubit.dart';

class SeekBar extends StatelessWidget {
  final Duration duration;

  const SeekBar({
    super.key,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();

    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final displayPosition = position > duration ? duration : position;

        return Column(
          children: [
            CustomSlider(
              value: displayPosition.inMilliseconds.toDouble(),
              max: duration.inMilliseconds.toDouble(),
              onChanged: (value) {
                playerCubit.seek(Duration(milliseconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DurationFormatter.format(displayPosition),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    DurationFormatter.format(duration),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
