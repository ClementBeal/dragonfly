import 'package:flutter_bloc/flutter_bloc.dart';

enum RedockableInterface { devtools, tabBar, searchBar, bookmarks }

enum Dock { top, bottom, left, right }

class BrowserInterfaceState {
  final bool showDevtools;
  final RedockableInterface? currentRedockingDock;
  final List<RedockableInterface> topDocks;
  final List<RedockableInterface> leftDocks;
  final List<RedockableInterface> bottomDocks;
  final List<RedockableInterface> rightDocks;

  BrowserInterfaceState({
    required this.showDevtools,
    this.currentRedockingDock,
    required this.topDocks,
    required this.leftDocks,
    required this.bottomDocks,
    required this.rightDocks,
  });

  factory BrowserInterfaceState.initial() => BrowserInterfaceState(
        showDevtools: false,
        currentRedockingDock: null,
        topDocks: [
          RedockableInterface.tabBar,
          RedockableInterface.searchBar,
          RedockableInterface.bookmarks,
        ],
        leftDocks: [],
        bottomDocks: [],
        rightDocks: [
          RedockableInterface.devtools,
        ],
      );

  BrowserInterfaceState copyWith({
    bool? showDevtools,
    RedockableInterface? Function()? currentRedockingDock,
    List<RedockableInterface>? topDocks,
    List<RedockableInterface>? leftDocks,
    List<RedockableInterface>? bottomDocks,
    List<RedockableInterface>? rightDocks,
  }) {
    return BrowserInterfaceState(
      showDevtools: showDevtools ?? this.showDevtools,
      currentRedockingDock: (currentRedockingDock != null)
          ? currentRedockingDock()
          : this.currentRedockingDock,
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
        currentRedockingDock: () => interface,
      ),
    );
  }

  void endToRedockInterface() {
    emit(
      state.copyWith(
        currentRedockingDock: () => null,
      ),
    );
  }

  void addToDock(Dock dock, RedockableInterface interface) {
    state.topDocks.remove(interface);
    state.bottomDocks.remove(interface);
    state.leftDocks.remove(interface);
    state.rightDocks.remove(interface);

    switch (dock) {
      case Dock.top:
        state.topDocks.add(interface);

      case Dock.bottom:
        state.bottomDocks.add(interface);

      case Dock.left:
        state.leftDocks.add(interface);

      case Dock.right:
        state.rightDocks.add(interface);
    }
    emit(state.copyWith());
  }
}
