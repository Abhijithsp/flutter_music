import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';

class PlayerControls extends StatefulWidget {
  final double iconSize;

  const PlayerControls({
    super.key,
    this.iconSize = 32,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _isShuffle = false;
  bool _isRepeat = false;

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();
    final theme = Theme.of(context);

    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle Button
            IconButton(
              icon: Icon(
                Icons.shuffle_rounded,
                size: widget.iconSize * 0.75,
                color: _isShuffle ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              onPressed: () {
                setState(() {
                  _isShuffle = !_isShuffle;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isShuffle ? 'Shuffle enabled' : 'Shuffle disabled'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                  ),
                );
              },
            ),

            // Skip Previous Button
            IconButton(
              icon: Icon(
                Icons.skip_previous_rounded,
                size: widget.iconSize * 1.1,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => playerCubit.previous(),
            ),

            // Play / Pause Glass Orb Button
            GestureDetector(
              onTap: () => playerCubit.togglePlay(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: state.isPlaying ? 20 : 12,
                      spreadRadius: state.isPlaying ? 2 : 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      key: ValueKey<bool>(state.isPlaying),
                      size: widget.iconSize * 1.3,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),

            // Skip Next Button
            IconButton(
              icon: Icon(
                Icons.skip_next_rounded,
                size: widget.iconSize * 1.1,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => playerCubit.next(),
            ),

            // Repeat Button
            IconButton(
              icon: Icon(
                Icons.repeat_rounded,
                size: widget.iconSize * 0.75,
                color: _isRepeat ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              onPressed: () {
                setState(() {
                  _isRepeat = !_isRepeat;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isRepeat ? 'Repeat enabled' : 'Repeat disabled'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
