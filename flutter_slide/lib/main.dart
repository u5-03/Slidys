import 'package:flutter/material.dart';
import 'package:flutter_slide/components/svg_path_widget.dart';
import 'package:flutter_slide/widgets/calendar_ui/calendar_ui_widget.dart';
import 'package:flutter_slide/widgets/icon_move_tab/icon_move_tab_widget.dart';
import 'package:flutter_slide/widgets/path_animation/flight_route_animation_widget.dart';
import 'package:flutter_slide/widgets/path_animation/icon_path_animation_widget.dart';
import 'package:flutter_slide/widgets/piano_ui/piano_widget.dart';
import 'package:flutter_slide/widgets/radial/circle_music_note_widget.dart';
import 'package:flutter_slide/widgets/symbol_quiz/symbol_quiz_widget.dart';

void main() {
  runApp(const MyApp());
}

enum PageType {
  circle,
  piano,
  calendar,
  circleAnimation,
  flightRouter,
  icon,
  waveFixedLength,
  iconMove,
  moveTab,
  symbolQuiz1,
  symbolQuiz2,
  ;

  String get routeName => '/$name';

  Widget get widget {
    switch (this) {
      case PageType.circle:
        return CircleMusicNoteView.demo();
      case PageType.piano:
        return PianoWidget();
      case PageType.calendar:
        return CalendarUiWidget();
      case PageType.circleAnimation:
        return CircleMusicNoteView.demoWithAnimation();
      case PageType.flightRouter:
        return const FlightRouteAnimationWidget();
      case PageType.icon:
        return AnimatedSvgPathWidget(
          pathSource: PathSourceType.assetPath('assets/images/icon.svg'),
          animationType: PathAnimationType.progressiveDraw(),
          duration: const Duration(seconds: 5),
          loop: true,
        );
      case PageType.waveFixedLength:
        return AnimatedSvgPathWidget(
          pathSource: PathSourceType.path(_generateWavePath(const Size(100, 20),
              waveHeight: 30, waveCount: 5)),
          animationType: PathAnimationType.fixedRatioMove(0.2),
          duration: const Duration(seconds: 5),
          loop: true,
        );
      case PageType.iconMove:
        return const IconPathAnimationWidget();
      case PageType.moveTab:
        return const IconMoveTabWidget();
      case PageType.symbolQuiz1:
        return SymbolQuizWidget(
          pathSource: PathSourceType.assetPath(
            'assets/images/origami.svg',
          ),
          animationType: PathAnimationType.progressiveDraw(),
          duration: const Duration(seconds: 30),
          loop: true,
          strokeColor: Colors.white,
        );
      case PageType.symbolQuiz2:
        return SymbolQuizWidget(
          pathSource: PathSourceType.text('ToyosuMarket', 50),
          animationType: PathAnimationType.progressiveDraw(),
          duration: const Duration(seconds: 30),
          loop: true,
          strokeColor: Colors.white,
        );
    }
  }

  Path _generateWavePath(Size size,
      {double waveHeight = 20, int waveCount = 2}) {
    final path = Path();
    final waveWidth = size.width / waveCount;

    path.moveTo(0, size.height / 2); // 開始点

    for (int i = 0; i < waveCount; i++) {
      final startX = i * waveWidth;
      final midX = startX + waveWidth / 2;
      final endX = startX + waveWidth;

      path.quadraticBezierTo(
        midX, size.height / 2 - waveHeight, // 上方向へのカーブ
        endX, size.height / 2, // 終点（水平線に戻る）
      );
    }

    return path;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SizedBox.shrink(),
        debugShowCheckedModeBanner: false,
        routes: {
          for (var page in PageType.values)
            page.routeName: (context) => Scaffold(
                  extendBodyBehindAppBar: true,
                  backgroundColor: Colors.transparent,
                  body: page.widget,
                )
        });
  }
}
