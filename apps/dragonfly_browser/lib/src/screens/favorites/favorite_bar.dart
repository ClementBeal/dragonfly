import 'package:dragonfly/src/screens/browser/blocs/browser_cubit.dart';
import 'package:dragonfly_browservault/dragonfly_browservault.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BrowserFavorites {
  // Implement your favorites logic here (e.g., using SQLite)
  void addFavorite(String name, String url) {}
  void createFolder(String name) {}
}

class FavoriteTabBar extends StatefulWidget {
  const FavoriteTabBar({super.key});

  @override
  State<FavoriteTabBar> createState() => _FavoriteTabBarState();
}

class _FavoriteTabBarState extends State<FavoriteTabBar> {
  // Sample favorites data (replace with your actual data)
  final List<Favorite> _favorites = [
    Favorite(name: 'Google', link: Uri.parse('https://www.google.com')),
    Favorite(name: 'Flutter', link: Uri.parse('https://flutter.dev')),
    Favorite(name: 'Perdu', link: Uri.parse('https://perdu.com')),
    Favorite(id: 4, name: 'Dev', isFolder: true),
    Favorite(name: 'Flutter', isFolder: false, parentId: 4),
    Favorite(
        name: 'Dart',
        link: Uri.parse("https://dart.dev/"),
        isFolder: false,
        parentId: 4),
    Favorite(
        name: 'Python',
        link: Uri.parse("https://www.python.org/"),
        isFolder: false,
        parentId: 4),
    Favorite(id: 5, name: 'Secret', isFolder: true, parentId: 4),
    Favorite(name: 'Secret 1', isFolder: false, parentId: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          spacing: 16,
          children: _favorites
              .where(
                (e) => e.parentId == null,
              )
              .map((favorite) => FavoriteChip(
                    favorite: favorite,
                    allFavorites: _favorites,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class FavoriteChip extends StatefulWidget {
  const FavoriteChip({
    super.key,
    required this.favorite,
    required this.allFavorites,
  });

  final Favorite favorite;
  final List<Favorite> allFavorites;

  @override
  State<FavoriteChip> createState() => _FavoriteChipState();
}

class _FavoriteChipState extends State<FavoriteChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.favorite.link != null) {
          context.read<BrowserCubit>().navigateToPage(widget.favorite.link!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => setState(() => _isHovered = true),
        onExit: (event) => setState(() => _isHovered = false),
        child: DecoratedBox(
          decoration: const BoxDecoration(
              // color: (_isHovered) ? Theme.of(context).primaryColor : null,
              ),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: switch (widget.favorite.isFolder) {
                true => MenuAnchor(
                    menuChildren: widget.allFavorites
                        .where(
                          (e) => e.parentId == widget.favorite.id,
                        )
                        .map(
                          (e) => DecoratedBox(
                            decoration: const BoxDecoration(
                                // color: Color(0xff444244),
                                ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth:
                                    MediaQuery.sizeOf(context).width * 0.2,
                              ),
                              child: MenuItemButton(
                                onPressed: () {
                                  if (!e.isFolder) {
                                    context
                                        .read<BrowserCubit>()
                                        .navigateToPage(e.link!);
                                  }
                                },
                                child: FavoriteChip(
                                  favorite: e,
                                  allFavorites: widget.allFavorites,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    builder: (context, controller, child) {
                      return GestureDetector(
                        onTap: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: FavoriteIconName(favorite: widget.favorite),
                      );
                    },
                  ),
                false => Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      if (widget.favorite.isFolder)
                        const Icon(Icons.folder_open),
                      Text(
                        widget.favorite.name,
                        // style: const TextStyle(
                        //   color: Colors.white,
                        // ),
                      ),
                    ],
                  ),
              }),
        ),
      ),
    );
  }
}

class FavoriteIconName extends StatelessWidget {
  const FavoriteIconName({
    super.key,
    required this.favorite,
    this.lightColor = false,
  });

  final Favorite favorite;
  final bool lightColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (favorite.isFolder) const Icon(Icons.folder_open),
        Text(
          favorite.name,
          // style: const TextStyle(
          //   color: Colors.white,
          // ),
        ),
      ],
    );
  }
}
