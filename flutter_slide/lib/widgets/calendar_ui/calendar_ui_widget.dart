import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slide/extensions/list.dart';
import 'package:flutter_slide/extensions/string.dart';

enum CalendarEventType {
  working,
  private,
  family,
  public;

  Color get backgroundColor {
    switch (this) {
      case CalendarEventType.working:
        return Colors.orange;
      case CalendarEventType.private:
        return Colors.purple;
      case CalendarEventType.family:
        return Colors.pink;
      case CalendarEventType.public:
        return Colors.green;
    }
  }
}

sealed class CalendarColumnType {
  const CalendarColumnType();

  factory CalendarColumnType.single() = CalendarSingleColumnType;
  factory CalendarColumnType.multi({
    required int columnCount,
    required int columnIndex,
  }) = CalendarMultiColumnType;

  int get columnCount {
    switch (this) {
      case CalendarSingleColumnType():
        return 1;
      case CalendarMultiColumnType(:final columnCount, columnIndex: final _):
        return columnCount;
    }
  }

  int get columnIndex {
    switch (this) {
      case CalendarSingleColumnType():
        return 0;
      case CalendarMultiColumnType(columnCount: final _, :final columnIndex):
        return columnIndex;
    }
  }
}

final class CalendarSingleColumnType extends CalendarColumnType {
  const CalendarSingleColumnType();
}

final class CalendarMultiColumnType extends CalendarColumnType {
  CalendarMultiColumnType({
    required this.columnCount,
    required this.columnIndex,
  });

  @override
  final int columnCount;
  @override
  final int columnIndex;
}

final class CalendarItem {
  const CalendarItem({
    required this.id,
    required this.title,
    required this.from,
    required this.to,
    required this.zIndex,
    required this.eventType,
    CalendarColumnType? columnType,
  }) : columnType = columnType ?? const CalendarSingleColumnType();

  final String id;
  final String title;
  final DateTime from;
  final DateTime to;
  final int zIndex;
  final CalendarEventType eventType;
  final CalendarColumnType columnType;

  double get widthCoefficient => max(0, 1 - (zIndex / 32));
}

final class CalendarUiWidget extends StatefulWidget {
  CalendarUiWidget({super.key});

  final List<CalendarItem> calendarItems = [
    CalendarItem(
      id: StringExt.random(10),
      title: 'オフィス出社',
      from: DateTime(2024, 11, 20, 9),
      to: DateTime(2024, 11, 20, 18),
      zIndex: 0,
      eventType: CalendarEventType.family,
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'オフィス出社',
      from: DateTime(2024, 11, 20, 10),
      to: DateTime(2024, 11, 20, 16),
      zIndex: 1,
      eventType: CalendarEventType.private,
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'Daily Meeting',
      from: DateTime(2024, 11, 20, 13, 30),
      to: DateTime(2024, 11, 20, 14),
      zIndex: 2,
      eventType: CalendarEventType.working,
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'エンジニア勉強会',
      from: DateTime(2024, 11, 20, 14, 30),
      to: DateTime(2024, 11, 20, 15, 30),
      zIndex: 2,
      eventType: CalendarEventType.working,
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'FlutterKaigi移動',
      from: DateTime(2024, 11, 20, 15),
      to: DateTime(2024, 11, 20, 16),
      zIndex: 3,
      eventType: CalendarEventType.private,
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'Daily Meeting',
      from: DateTime(2024, 11, 20, 16),
      to: DateTime(2024, 11, 20, 16, 30),
      zIndex: 3,
      eventType: CalendarEventType.working,
      columnType: CalendarMultiColumnType(columnCount: 2, columnIndex: 0),
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'Daily Meeting',
      from: DateTime(2024, 11, 20, 16, 30),
      to: DateTime(2024, 11, 20, 17),
      zIndex: 3,
      eventType: CalendarEventType.working,
      columnType: CalendarMultiColumnType(columnCount: 2, columnIndex: 0),
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'デザイン定例',
      from: DateTime(2024, 11, 20, 17),
      to: DateTime(2024, 11, 20, 17, 30),
      zIndex: 3,
      eventType: CalendarEventType.working,
      columnType: CalendarMultiColumnType(columnCount: 2, columnIndex: 0),
    ),
    CalendarItem(
      id: StringExt.random(10),
      title: 'FlutterKaigi登壇準備・登壇・参加',
      from: DateTime(2024, 11, 20, 16),
      to: DateTime(2024, 11, 20, 20),
      zIndex: 3,
      eventType: CalendarEventType.private,
      columnType: CalendarMultiColumnType(columnCount: 2, columnIndex: 1),
    ),
  ].sorted((e) => e.zIndex, order: SortOrder.ascending);

  @override
  State<CalendarUiWidget> createState() => _CalendarUiWidgetState();
}

final class _CalendarUiWidgetState extends State<CalendarUiWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<String> hours = List.generate(24, (index) => '$index:00');
  static const double timeWidth = 40;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        height: _CalendarLayoutDelegate.hourHeight * 24,
        child: Stack(
          children: [
            // 0時から24時までの24時間のリスト
            _DayCalendarGrid(),
            Padding(
              padding: const EdgeInsets.only(left: timeWidth),
              child: CustomMultiChildLayout(
                delegate: _CalendarLayoutDelegate(
                  calendarItems: widget.calendarItems,
                ),
                children: widget.calendarItems.map((item) {
                  return LayoutId(
                    id: item.id,
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: item.eventType.backgroundColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(),
                          // border: Border.all(color: Colors.black),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(item.title),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _CalendarLayoutDelegate extends MultiChildLayoutDelegate {
  _CalendarLayoutDelegate({
    required this.calendarItems,
  });

  final List<CalendarItem> calendarItems;

  static const double dayWidth = 30;
  static const double hourHeight = 60;

  @override
  void performLayout(Size size) {
    for (final calendarItem in calendarItems) {
      if (!hasChild(calendarItem.id)) continue;
      final baseWidth = size.width * calendarItem.widthCoefficient;
      final width = baseWidth / calendarItem.columnType.columnCount;
      final height = (calendarItem.to.hour +
                  calendarItem.to.customMinuteFraction) *
              hourHeight -
          (calendarItem.from.hour + calendarItem.from.customMinuteFraction) *
              hourHeight;
      layoutChild(
        calendarItem.id,
        BoxConstraints(
          minWidth: width,
          maxWidth: width,
          minHeight: height,
          maxHeight: height,
        ),
      );
      positionChild(
        calendarItem.id,
        Offset(
          size.width - baseWidth + width * calendarItem.columnType.columnIndex,
          (calendarItem.from.hour + calendarItem.from.customMinuteFraction) *
              hourHeight,
        ),
      );
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => false;
}

extension on DateTime {
  double get customMinuteFraction {
    return minute / 60;
  }
}

class _DayCalendarGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 0時から24時までの24時間をリストに格納
    final hours = List<String>.generate(24, (index) => '$index:00');

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: hours.map((hour) {
        return Container(
          height: _CalendarLayoutDelegate.hourHeight, // 各時間枠の高さを設定
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey, // 下部に区切り線
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // 時刻を表示する部分
              Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: _CalendarUiWidgetState.timeWidth, // 左側に表示する時刻の幅
                  child: Text(
                    hour,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.left, // 右揃え
                  ),
                ),
              ),
              // 時刻の右側のスペース（カレンダーの内容が入る部分）
              Expanded(
                child: Container(
                  color: Colors.transparent, // 背景色を指定可能（ここでは透明）
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
