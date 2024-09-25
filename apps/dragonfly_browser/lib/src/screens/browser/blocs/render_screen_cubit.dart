import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RenderScreenState {
  final String? hoveredLink;

  const RenderScreenState({this.hoveredLink});

  RenderScreenState copyWith({
    String? Function()? hoveredLink,
  }) {
    return RenderScreenState(
      hoveredLink: (hoveredLink != null) ? hoveredLink() : this.hoveredLink,
    );
  }
}

class RenderScreenCubit extends Cubit<RenderScreenState> {
  RenderScreenCubit() : super(const RenderScreenState());

  /// Sets the hovered link in the state.
  ///
  /// [link] is the URL of the hovered link.
  void setHoveredLink(String link) {
    emit(state.copyWith(hoveredLink: () => link));
  }

  /// Clears the hovered link in the state.
  void clearHoveredLink() {
    emit(state.copyWith(hoveredLink: () => null));
  }
}
