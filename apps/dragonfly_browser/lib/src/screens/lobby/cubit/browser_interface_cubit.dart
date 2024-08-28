import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserInterfaceState {
  final bool showDevtools;

  BrowserInterfaceState({required this.showDevtools});

  BrowserInterfaceState copyWith({bool? showDevtools}) {
    return BrowserInterfaceState(
      showDevtools: showDevtools ?? this.showDevtools,
    );
  }
}

class BrowserInterfaceCubit extends Cubit<BrowserInterfaceState> {
  BrowserInterfaceCubit()
      : super(
          BrowserInterfaceState(showDevtools: false),
        );

  void openDevTools() {
    emit(state.copyWith(showDevtools: true));
  }

  void closeDevTools() {
    emit(state.copyWith(showDevtools: false));
  }
}
