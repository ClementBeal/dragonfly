import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RedockableInterface { devtools, tabBar, searchBar, bookmarks }

class BrowserInterfaceState {
  final bool showDevtools;
  final RedockableInterface? currentRedockingInterface;
  final List<RedockableInterface> topDocks;
  final List<RedockableInterface> leftDocks;
  final List<RedockableInterface> bottomDocks;
  final List<RedockableInterface> rightDocks;

  BrowserInterfaceState({
    required this.showDevtools,
    this.currentRedockingInterface,
    required this.topDocks,
    required this.leftDocks,
    required this.bottomDocks,
    required this.rightDocks,
  });

  factory BrowserInterfaceState.initial() => BrowserInterfaceState(
        showDevtools: false,
        currentRedockingInterface: null,
        topDocks: [
          RedockableInterface.tabBar,
          RedockableInterface.searchBar,
          RedockableInterface.bookmarks,
        ],
        leftDocks: [
          RedockableInterface.tabBar,
        ],
        bottomDocks: [],
        rightDocks: [
          RedockableInterface.devtools,
        ],
      );

  BrowserInterfaceState copyWith({
    bool? showDevtools,
    RedockableInterface? Function()? currentRedockingInterface,
    List<RedockableInterface>? topDocks,
    List<RedockableInterface>? leftDocks,
    List<RedockableInterface>? bottomDocks,
    List<RedockableInterface>? rightDocks,
  }) {
    return BrowserInterfaceState(
      showDevtools: showDevtools ?? this.showDevtools,
      currentRedockingInterface: (currentRedockingInterface != null)
          ? currentRedockingInterface()
          : this.currentRedockingInterface,
      topDocks: topDocks ?? this.topDocks,
      leftDocks: leftDocks ?? this.leftDocks,
      bottomDocks: bottomDocks ?? this.bottomDocks,
      rightDocks: rightDocks ?? this.rightDocks,
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
