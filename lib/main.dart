import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:miniplayer/miniplayer.dart';
import 'utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

ValueNotifier<AudioObject?> currentlyPlaying = ValueNotifier(null);

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

const double playerMinHeight = 70;
const double playerMaxHeight = 370;
const miniplayerPercentageDeclaration = 0.2;

const webViewLink = 'https://pesoros.com';
const radioThumbnail =
    'https://i1.sndcdn.com/artworks-000126561252-y7v0b4-t500x500.jpg';
const radioArtist = 'Pesoros Radio';
const radioTitle = 'Digital Business Solution';
const radioUrl = 'https://s8-webradio.antenne.de/antenne?icy=https.mp3';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miniplayer Demo',
      theme: ThemeData(
        primaryColor: Colors.grey[50],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PageManager _pageManager;

  @override
  void initState() {
    super.initState();
    _pageManager = PageManager();
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebView(
            initialUrl: webViewLink,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              print('Page finished loading:');
            },
          ),
          ValueListenableBuilder<ButtonState>(
              valueListenable: _pageManager.buttonNotifier,
              builder: (_, value, __) {
                switch (value) {
                  case ButtonState.loading:
                    return Container(
                      margin: EdgeInsets.all(8.0),
                      width: 32.0,
                      height: 32.0,
                      child: CircularProgressIndicator(),
                    );
                  case ButtonState.paused:
                    return Miniplayer(
                      valueNotifier: playerExpandProgress,
                      minHeight: playerMinHeight,
                      maxHeight: playerMaxHeight,
                      controller: controller,
                      elevation: 4,
                      onDismissed: () => currentlyPlaying.value = null,
                      curve: Curves.easeOut,
                      builder: (height, percentage) {
                        final bool miniplayer =
                            percentage < miniplayerPercentageDeclaration;
                        final double width = MediaQuery.of(context).size.width;
                        final maxImgSize = width * 0.4;

                        final img = Image.network(radioThumbnail);
                        final text = Text(radioTitle);
                        final buttonPause = IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: _pageManager.play,
                        );

                        //Declare additional widgets (eg. SkipButton) and variables
                        if (!miniplayer) {
                          var percentageExpandedPlayer =
                              percentageFromValueInRange(
                                  min: playerMaxHeight *
                                          miniplayerPercentageDeclaration +
                                      playerMinHeight,
                                  max: playerMaxHeight,
                                  value: height);
                          if (percentageExpandedPlayer < 0)
                            percentageExpandedPlayer = 0;
                          final paddingVertical = valueFromPercentageInRange(
                              min: 0,
                              max: 10,
                              percentage: percentageExpandedPlayer);
                          final double heightWithoutPadding =
                              height - paddingVertical * 2;
                          final double imageSize =
                              heightWithoutPadding > maxImgSize
                                  ? maxImgSize
                                  : heightWithoutPadding;
                          final paddingLeft = valueFromPercentageInRange(
                                min: 0,
                                max: width - imageSize,
                                percentage: percentageExpandedPlayer,
                              ) /
                              2;
                          final buttonPauseExpanded = IconButton(
                            icon: Icon(Icons.play_circle_filled),
                            iconSize: 50,
                            onPressed: _pageManager.play,
                          );

                          return Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: paddingLeft,
                                      top: paddingVertical,
                                      bottom: paddingVertical),
                                  child: SizedBox(
                                    height: imageSize,
                                    child: img,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 33),
                                  child: Opacity(
                                    opacity: percentageExpandedPlayer,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        text,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            buttonPauseExpanded,
                                          ],
                                        ),
                                        Container(),
                                        Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        //Miniplayer
                        final percentageMiniplayer = percentageFromValueInRange(
                            min: playerMinHeight,
                            max: playerMaxHeight *
                                    miniplayerPercentageDeclaration +
                                playerMinHeight,
                            value: height);

                        final elementOpacity = 1 - 1 * percentageMiniplayer;

                        return Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: maxImgSize),
                                    child: img,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Opacity(
                                        opacity: elementOpacity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(radioArtist,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .copyWith(fontSize: 16)),
                                            Text(
                                              radioTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      color: Colors.black
                                                          .withOpacity(0.55)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.fullscreen),
                                      onPressed: () {
                                        controller.animateToHeight(
                                            state: PanelState.MAX);
                                      }),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Opacity(
                                      opacity: elementOpacity,
                                      child: buttonPause,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  case ButtonState.playing:
                    return Miniplayer(
                      valueNotifier: playerExpandProgress,
                      minHeight: playerMinHeight,
                      maxHeight: playerMaxHeight,
                      controller: controller,
                      elevation: 4,
                      onDismissed: () => currentlyPlaying.value = null,
                      curve: Curves.easeOut,
                      builder: (height, percentage) {
                        final bool miniplayer =
                            percentage < miniplayerPercentageDeclaration;
                        final double width = MediaQuery.of(context).size.width;
                        final maxImgSize = width * 0.4;

                        final img = Image.network(radioThumbnail);
                        final text = Text(radioTitle);
                        final buttonPlay = IconButton(
                          icon: Icon(Icons.pause),
                          onPressed: _pageManager.pause,
                        );

                        //Declare additional widgets (eg. SkipButton) and variables
                        if (!miniplayer) {
                          var percentageExpandedPlayer =
                              percentageFromValueInRange(
                                  min: playerMaxHeight *
                                          miniplayerPercentageDeclaration +
                                      playerMinHeight,
                                  max: playerMaxHeight,
                                  value: height);
                          if (percentageExpandedPlayer < 0)
                            percentageExpandedPlayer = 0;
                          final paddingVertical = valueFromPercentageInRange(
                              min: 0,
                              max: 10,
                              percentage: percentageExpandedPlayer);
                          final double heightWithoutPadding =
                              height - paddingVertical * 2;
                          final double imageSize =
                              heightWithoutPadding > maxImgSize
                                  ? maxImgSize
                                  : heightWithoutPadding;
                          final paddingLeft = valueFromPercentageInRange(
                                min: 0,
                                max: width - imageSize,
                                percentage: percentageExpandedPlayer,
                              ) /
                              2;
                          final buttonPlayExpanded = IconButton(
                            icon: Icon(Icons.pause_circle_filled),
                            iconSize: 50,
                            onPressed: _pageManager.pause,
                          );

                          return Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: paddingLeft,
                                      top: paddingVertical,
                                      bottom: paddingVertical),
                                  child: SizedBox(
                                    height: imageSize,
                                    child: img,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 33),
                                  child: Opacity(
                                    opacity: percentageExpandedPlayer,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        text,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            buttonPlayExpanded,
                                          ],
                                        ),
                                        Container(),
                                        Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        //Miniplayer
                        final percentageMiniplayer = percentageFromValueInRange(
                            min: playerMinHeight,
                            max: playerMaxHeight *
                                    miniplayerPercentageDeclaration +
                                playerMinHeight,
                            value: height);

                        final elementOpacity = 1 - 1 * percentageMiniplayer;

                        return Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: maxImgSize),
                                    child: img,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Opacity(
                                        opacity: elementOpacity,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(radioArtist,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText2!
                                                    .copyWith(fontSize: 16)),
                                            Text(
                                              radioTitle,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2!
                                                  .copyWith(
                                                      color: Colors.black
                                                          .withOpacity(0.55)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.fullscreen),
                                      onPressed: () {
                                        controller.animateToHeight(
                                            state: PanelState.MAX);
                                      }),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 3),
                                    child: Opacity(
                                      opacity: elementOpacity,
                                      child: buttonPlay,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                }
              }),
        ],
      ),
    );
  }
}

class PageManager {
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.playing);

  late AudioPlayer _audioPlayer;

  PageManager() {
    _init();
  }

  void _init() async {
    // initialize the song
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setUrl(radioUrl);
    _audioPlayer.play();

    // listen for changes in player state
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });

    // listen for changes in play position
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    // listen for changes in the buffered position
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    // listen for changes in the total audio duration
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play() async {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }
