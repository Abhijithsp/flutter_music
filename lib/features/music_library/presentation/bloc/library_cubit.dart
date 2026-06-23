import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/permissions/permission_service.dart';
import '../../domain/usecases/get_all_songs.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final GetAllSongs _getAllSongs;
  final PermissionService _permissionService;

  LibraryCubit({
    required this._getAllSongs,
    required this._permissionService,
  }) : super(const LibraryState());

  Future<void> loadSongs() async {
    emit(state.copyWith(status: LibraryStatus.loading));

    final hasPermission = await _permissionService.requestStoragePermission();
    if (!hasPermission) {
      emit(state.copyWith(status: LibraryStatus.permissionDenied));
      return;
    }

    try {
      final songs = await _getAllSongs();
      emit(state.copyWith(
        status: LibraryStatus.success,
        songs: songs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LibraryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
