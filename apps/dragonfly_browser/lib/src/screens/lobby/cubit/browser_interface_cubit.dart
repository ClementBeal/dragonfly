import 'package:flutter_bloc/flutter_bloc.dart';

enum RedockableInterface { devtools, tabBar, searchBar, bookmarks }

typedef RedockingData = (RedockableInterface interface, int index, Dock dock);

enum Dock { top, bottom, left, right }

class BrowserInterfaceState {
  final bool showDevtools;
  final bool showMobileViewPort;
  final double viewportWidth;
  final double viewportHeight;
  final RedockingData? currentRedockingDock;
  final List<RedockableInterface> topDocks;
  final List<RedockableInterface> leftDocks;
  final List<RedockableInterface> bottomDocks;
  final List<RedockableInterface> rightDocks;

  BrowserInterfaceState({
    required this.showDevtools,
    required this.showMobileViewPort,
    required this.viewportWidth,
    required this.viewportHeight,
    this.currentRedockingDock,
    required this.topDocks,
    required this.leftDocks,
    required this.bottomDocks,
    required this.rightDocks,
  });

  factory BrowserInterfaceState.initial() => BrowserInterfaceState(
        showDevtools: false,
        showMobileViewPort: false,
        viewportHeight: 800,
        viewportWidth: 420,
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
    bool? showMobileViewPort,
    double? viewportHeight,
    double? viewportWidth,
    RedockingData? Function()? currentRedockingDock,
    List<RedockableInterface>? topDocks,
    List<RedockableInterface>? leftDocks,
    List<RedockableInterface>? bottomDocks,
    List<RedockableInterface>? rightDocks,
  }) {
    return BrowserInterfaceState(
      showDevtools: showDevtools ?? this.showDevtools,
      showMobileViewPort: showMobileViewPort ?? this.showMobileViewPort,
      viewportHeight: viewportHeight ?? this.viewportHeight,
      viewportWidth: viewportWidth ?? this.viewportWidth,
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

  void startToRedockInterface(RedockableInterface interface, Dock dock) {
    final a = state.topDocks.indexWhere((e) => e == interface);
    final b = state.leftDocks.indexWhere((e) => e == interface);
    final c = state.bottomDocks.indexWhere((e) => e == interface);
    final d = state.rightDocks.indexWhere((e) => e == interface);

    final index = (a >= 0)
        ? a
        : (b >= 0)
            ? b
            : (c >= 0)
                ? c
                : d;

    emit(
      state.copyWith(
        currentRedockingDock: () => (interface, index, dock),
      ),
    );
  }

  void resetToRedockInterface() {
    emit(
      state.copyWith(
        currentRedockingDock: () => null,
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

  void addToDock(Dock dock, RedockableInterface interface, int index) {
    state.topDocks.remove(interface);
    state.bottomDocks.remove(interface);
    state.leftDocks.remove(interface);
    state.rightDocks.remove(interface);

    print(index);

    switch (dock) {
      case Dock.top:
        if (state.topDocks.length <= index) {
          state.topDocks.add(interface);
        } else {
          state.topDocks.insert(index, interface);
        }

      case Dock.bottom:
        if (state.bottomDocks.length <= index) {
          state.bottomDocks.add(interface);
        } else {
          state.bottomDocks.insert(index, interface);
        }

      case Dock.left:
        if (state.leftDocks.length <= index) {
          state.leftDocks.add(interface);
        } else {
          state.leftDocks.insert(index, interface);
        }

      case Dock.right:
        if (state.rightDocks.length <= index) {
          state.rightDocks.add(interface);
        } else {
          state.rightDocks.insert(index, interface);
        }
    }
    emit(state.copyWith());
  }

  void openMobileViewPort() {
    emit(
      state.copyWith(
        showMobileViewPort: true,
      ),
    );
  }

  void closeMobileViewPort() {
    emit(
      state.copyWith(
        showMobileViewPort: false,
      ),
    );
  }

  void setDeviceViewport(double width, double height) {
    emit(
      state.copyWith(
        viewportWidth: width,
        viewportHeight: height,
      ),
    );
  }
}
