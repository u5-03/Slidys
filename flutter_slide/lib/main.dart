import 'package:flutter/material.dart';
import 'package:flutter_slide/components/svg_path_widget.dart';
import 'package:flutter_slide/widgets/calendar_ui/calendar_ui_widget.dart';
import 'package:flutter_slide/widgets/path_animation/flight_route_animation_widget.dart';
import 'package:flutter_slide/widgets/piano_ui/piano_widget.dart';
import 'package:flutter_slide/widgets/radial/circle_music_note_widget.dart';

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
    }
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
