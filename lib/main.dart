import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/locator/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/music_library/presentation/bloc/library_cubit.dart';
import 'features/music_library/presentation/pages/library_page.dart';
import 'features/player/presentation/bloc/player_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI service locator (audio handler, permissions, cubits)
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LibraryCubit>(
          create: (context) => getIt<LibraryCubit>(),
        ),
        BlocProvider<PlayerCubit>(
          create: (context) => getIt<PlayerCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Octave Music Player',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LibraryPage(),
      ),
    );
  }
}
