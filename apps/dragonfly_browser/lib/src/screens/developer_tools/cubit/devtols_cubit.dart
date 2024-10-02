import 'package:dragonfly_engine/dragonfly_engine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DevToolsCubit extends Cubit<DevToolsState> {
  DevToolsCubit()
      : super(const DevToolsState(
          selectedDomHash: -1,
          selectedCommonStyle: null,
        ));

  void selectDomNode(int? domHash) {
    emit(state.copyWith(selectedDomHash: domHash));
  }

  void setCommonStyle(CommonStyle? commonStyle) {
    emit(
      state.copyWith(
        selectedCommonStyle: () => commonStyle,
      ),
    );
  }
}

class DevToolsState {
  final int? selectedDomHash;
  final CommonStyle? selectedCommonStyle;

  const DevToolsState({
    required this.selectedDomHash,
    required this.selectedCommonStyle,
  });

  DevToolsState copyWith({
    int? selectedDomHash,
    CommonStyle? Function()? selectedCommonStyle,
  }) {
    return DevToolsState(
      selectedDomHash: selectedDomHash ?? this.selectedDomHash,
      selectedCommonStyle: (selectedCommonStyle != null)
          ? selectedCommonStyle.call()
          : this.selectedCommonStyle,
    );
  }
}
