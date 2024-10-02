import 'package:flutter_bloc/flutter_bloc.dart';

class DevToolsCubit extends Cubit<DevToolsState> {
  DevToolsCubit() : super(const DevToolsState(selectedDomHash: -1));

  void selectDomNode(int? domHash) {
    emit(state.copyWith(selectedDomHash: domHash));
  }
}

class DevToolsState {
  final int? selectedDomHash;

  const DevToolsState({required this.selectedDomHash});

  DevToolsState copyWith({int? selectedDomHash}) {
    return DevToolsState(
      selectedDomHash: selectedDomHash ?? this.selectedDomHash,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevToolsState &&
          runtimeType == other.runtimeType &&
          selectedDomHash == other.selectedDomHash;

  @override
  int get hashCode => selectedDomHash.hashCode;

  @override
  String toString() {
    return 'DevToolsState{selectedDomHash: $selectedDomHash}';
  }
}
