import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RedockableInterface { devtools }

class BrowserInterfaceState {
  final bool showDevtools;
  final RedockableInterface? currentRedockingInterface;

  BrowserInterfaceState({
    required this.showDevtools,
    this.currentRedockingInterface,
  });

  factory BrowserInterfaceState.initial() => BrowserInterfaceState(
        showDevtools: false,
        currentRedockingInterface: null,
      );

  BrowserInterfaceState copyWith({
    bool? showDevtools,
    RedockableInterface? Function()? currentRedockingInterface,
  }) {
    return BrowserInterfaceState(
      showDevtools: showDevtools ?? this.showDevtools,
      currentRedockingInterface: (currentRedockingInterface != null)
          ? currentRedockingInterface()
          : this.currentRedockingInterface,
    );
  }
}

class BrowserInterfaceCubit extends Cubit<BrowserInterfaceState> {
  BrowserInterfaceCubit()
      : super(
          BrowserInterfaceState.initial(),
        );

  void openDevTools() {
    emit(state.copyWith(showDevtools: true));
  }

  void closeDevTools() {
    emit(state.copyWith(showDevtools: false));
  }

  void toggleDevTools() {
    emit(state.copyWith(showDevtools: !state.showDevtools));
  }

  void startToRedockInterface(RedockableInterface interface) {
    emit(
      state.copyWith(
        currentRedockingInterface: () => interface,
      ),
    );
  }

  void endToRedockInterface() {
    emit(
      state.copyWith(
        currentRedockingInterface: () => null,
      ),
    );
  }
}
