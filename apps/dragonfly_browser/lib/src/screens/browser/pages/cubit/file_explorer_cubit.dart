import 'package:flutter_bloc/flutter_bloc.dart';

class FileExplorerState {
  final Map<String, bool> showHiddenFiles;

  const FileExplorerState({required this.showHiddenFiles});

  FileExplorerState copyWith({
    Map<String, bool>? showHiddenFiles,
  }) {
    return FileExplorerState(
      showHiddenFiles: showHiddenFiles ?? this.showHiddenFiles,
    );
  }
}

class FileExplorerCubit extends Cubit<FileExplorerState> {
  FileExplorerCubit() : super(const FileExplorerState(showHiddenFiles: {}));

  void toggleShowHiddenFiles(String tabGuid) {
    emit(
      state.copyWith(
        showHiddenFiles: {
          ...state.showHiddenFiles,
          tabGuid: !state.showHiddenFiles.containsKey(tabGuid) ||
              !state.showHiddenFiles[tabGuid]!,
        },
      ),
    );
  }
}
