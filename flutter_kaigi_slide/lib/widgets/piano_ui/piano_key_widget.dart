import 'package:flutter/material.dart';
import 'package:flutter_kaigi_slide/widgets/piano_ui/aspect_ratio_constants.dart';
import 'package:flutter_kaigi_slide/widgets/piano_ui/piano_key.dart';
import 'package:flutter_kaigi_slide/widgets/piano_ui/piano_key_stroke.dart';

final class PianoKeyWidget {
  const PianoKeyWidget._();
  static const double keyCornerRadius = 4;
  static const Duration strokeSleepDuration = Duration(milliseconds: 100);

  static Widget white({
    required PianoKey pianoKey,
    required KeyStrokedType keyStrokedType,
    void Function(PianoKeyStroke)? didTriggerKeyStrokeEvent,
  }) {
    return _WhitePianoKeyWidget(
      pianoKey: pianoKey,
      keyStrokedType: keyStrokedType,
      didTriggerKeyStrokeEvent: didTriggerKeyStrokeEvent,
    );
  }

  static Widget black({
    required PianoKey pianoKey,
    required KeyStrokedType keyStrokedType,
    void Function(PianoKeyStroke)? didTriggerKeyStrokeEvent,
  }) {
    return _BlackPianoKeyWidget(
      pianoKey: pianoKey,
      keyStrokedType: keyStrokedType,
      didTriggerKeyStrokeEvent: didTriggerKeyStrokeEvent,
    );
  }
}

final class _WhitePianoKeyWidget extends StatefulWidget {
  const _WhitePianoKeyWidget({
    required this.pianoKey,
    required this.keyStrokedType,
    this.didTriggerKeyStrokeEvent,
  });
  final PianoKey pianoKey;
  final KeyStrokedType keyStrokedType;
  final void Function(PianoKeyStroke)? didTriggerKeyStrokeEvent;

  @override
  _WhitePianoKeyWidgetState createState() => _WhitePianoKeyWidgetState();
}

final class _WhitePianoKeyWidgetState extends State<_WhitePianoKeyWidget> {
  bool isStroked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _triggerKeyStroke(isOn: true),
      onTapUp: (_) => _triggerKeyStroke(isOn: false),
      child: AspectRatio(
        aspectRatio: AspectRatioConstants.whiteKeyAspectRatio,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(PianoKeyWidget.keyCornerRadius),
              bottomRight: Radius.circular(PianoKeyWidget.keyCornerRadius),
            ),
          ),
          child: Stack(
            children: [
              if (widget.keyStrokedType.isStroked)
                _buildStrokeOverlay(
                  Theme.of(context).primaryColor.withOpacity(
                        widget.keyStrokedType.velocityPercent / 100.0,
                      ),
                ),
              if (isStroked)
                _buildStrokeOverlay(
                  Theme.of(context).primaryColor.withOpacity(
                        widget.keyStrokedType.velocityPercent / 100.0,
                      ),
                ),
              if (widget.pianoKey.isC || _shouldShowSoundKey())
                _buildKeyLabel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeOverlay(Color color) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(PianoKeyWidget.keyCornerRadius),
            bottomRight: Radius.circular(PianoKeyWidget.keyCornerRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyLabel() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          widget.pianoKey.keyDisplayValue(
            KeyDisplayType.english,
          ), // or any other type
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  bool _shouldShowSoundKey() {
    // Example logic to replace AppStorage:
    return true; // Replace with your actual condition
  }

  void _triggerKeyStroke({required bool isOn}) {
    widget.didTriggerKeyStrokeEvent?.call(
      PianoKeyStroke(
        key: widget.pianoKey,
        velocity: 64, // Example default value, replace with appropriate logic
        timestampNanoSecond: DateTime.now().microsecondsSinceEpoch * 1000,
        isOn: isOn,
      ),
    );
    setState(() {
      isStroked = isOn;
    });
  }
}

final class _BlackPianoKeyWidget extends StatefulWidget {
  const _BlackPianoKeyWidget({
    required this.pianoKey,
    required this.keyStrokedType,
    this.didTriggerKeyStrokeEvent,
  });
  final PianoKey pianoKey;
  final KeyStrokedType keyStrokedType;
  final void Function(PianoKeyStroke)? didTriggerKeyStrokeEvent;

  @override
  _BlackPianoKeyWidgetState createState() => _BlackPianoKeyWidgetState();
}

class _BlackPianoKeyWidgetState extends State<_BlackPianoKeyWidget> {
  bool isStroked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _triggerKeyStroke(isOn: true),
      onTapUp: (_) => _triggerKeyStroke(isOn: false),
      child: AspectRatio(
        aspectRatio: AspectRatioConstants.blackKeyAspectRatio,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(PianoKeyWidget.keyCornerRadius),
              bottomRight: Radius.circular(PianoKeyWidget.keyCornerRadius),
            ),
          ),
          child: Stack(
            children: [
              if (widget.keyStrokedType.isStroked)
                _buildStrokeOverlay(
                  Colors.grey.withOpacity(
                    widget.keyStrokedType.velocityPercent / 100.0,
                  ),
                ),
              if (isStroked)
                _buildStrokeOverlay(
                  Colors.grey.withOpacity(
                    widget.keyStrokedType.velocityPercent / 100.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrokeOverlay(Color color) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(PianoKeyWidget.keyCornerRadius),
            bottomRight: Radius.circular(PianoKeyWidget.keyCornerRadius),
          ),
        ),
      ),
    );
  }

  void _triggerKeyStroke({required bool isOn}) {
    widget.didTriggerKeyStrokeEvent?.call(
      PianoKeyStroke(
        key: widget.pianoKey,
        velocity: 64, // Example default value, replace with appropriate logic
        timestampNanoSecond: DateTime.now().microsecondsSinceEpoch * 1000,
        isOn: isOn,
      ),
    );
    setState(() {
      isStroked = isOn;
    });
  }
}
