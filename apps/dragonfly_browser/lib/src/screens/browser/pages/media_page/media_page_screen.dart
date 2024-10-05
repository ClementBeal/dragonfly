import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:dragonfly/src/constants/file_constants.dart';
import 'package:flutter/material.dart';
import 'package:dragonfly_engine/dragonfly_engine.dart';

class MediaPageScreen extends StatelessWidget {
  const MediaPageScreen({super.key, required this.page});

  final MediaPage page;

  @override
  Widget build(BuildContext context) {
    final fileExtension = page.uri.toFilePath().split(".").last;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black87,
      ),
      child: Builder(builder: (context) {
        if (imageExtensions.contains(fileExtension)) {
          return ImageMediaPage(
            page: page,
          );
        } else if (audioExtensions.contains(fileExtension)) {
          return AudioMediaPage(page: page);
        }

        return ImageMediaPage(
          page: page,
        );
      }),
    );
  }
}

class ImageMediaPage extends StatefulWidget {
  const ImageMediaPage({super.key, required this.page});

  final MediaPage page;

  @override
  State<ImageMediaPage> createState() => _ImageMediaPageState();
}

class _ImageMediaPageState extends State<ImageMediaPage> {
  bool isZooming = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _zoomAtPosition(TapUpDetails details) {
    final tapPosition = details.localPosition;

    final newScrollY =
        (tapPosition.dy * _scrollController.position.maxScrollExtent) /
            context.size!.height;

    _scrollController.jumpTo(newScrollY);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          isZooming ? SystemMouseCursors.zoomOut : SystemMouseCursors.zoomIn,
      child: GestureDetector(
        onTapUp: (details) {
          setState(() {
            isZooming = !isZooming;
          });

          if (isZooming) {
            WidgetsBinding.instance.addPostFrameCallback(
              (timeStamp) {
                _zoomAtPosition(details);
              },
            );
          }
        },
        child: (isZooming)
            ? SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.file(
                      File.fromUri(widget.page.uri),
                    ),
                  ],
                ),
              )
            : Image.file(
                File.fromUri(widget.page.uri),
              ),
      ),
    );
  }
}

class AudioMediaPage extends StatefulWidget {
  const AudioMediaPage({super.key, required this.page});

  final MediaPage page;

  @override
  State<AudioMediaPage> createState() => _AudioMediaPageState();
}

class _AudioMediaPageState extends State<AudioMediaPage> {
  late AudioPlayer audioPlayer;

  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  bool _isMuted = false;

  late StreamSubscription? _onPositionChanged;
  late StreamSubscription? _onPlayerStateChanged;
  late StreamSubscription? _onDurationChanged;

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer()
      ..setSourceDeviceFile(widget.page.uri.toFilePath())
      ..resume();

    _onPlayerStateChanged = audioPlayer.onPlayerStateChanged.listen(
      (event) {
        setState(() {
          _isPlaying = event == PlayerState.playing;
        });
      },
    );

    _onPositionChanged = audioPlayer.onPositionChanged.listen(
      (event) {
        setState(() {
          _currentPosition = event;
        });
      },
    );

    _onDurationChanged = audioPlayer.onDurationChanged.listen(
      (event) {
        setState(() {
          _duration = event;
        });
      },
    );
  }

  @override
  void dispose() {
    _onPositionChanged?.cancel();
    _onPlayerStateChanged?.cancel();
    _onDurationChanged?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    return "${duration.inMinutes}:${duration.inSeconds % 60}";
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200, maxHeight: 80),
          child: SizedBox(
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (audioPlayer.state == PlayerState.playing) {
                          audioPlayer.pause();
                        } else {
                          audioPlayer.resume();
                        }
                      },
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentPosition.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (double value) {
                          audioPlayer.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Text(
                      "${_formatDuration(_currentPosition)} / ${_formatDuration(_duration)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: (_volume == 0.0)
                              ? null
                              : () {
                                  setState(() {
                                    audioPlayer
                                        .setVolume(_isMuted ? _volume : 0.0);

                                    audioPlayer.setVolume(0.0);
                                    _isMuted = !_isMuted;
                                  });
                                },
                          icon: const Icon(Icons.volume_mute),
                        ),
                        SizedBox(width: 8),
                        Slider(
                          value: (_isMuted) ? 0.0 : _volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (!_isMuted)
                              ? (double value) async {
                                  await audioPlayer.setVolume(value);

                                  setState(() {
                                    _volume = value;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
