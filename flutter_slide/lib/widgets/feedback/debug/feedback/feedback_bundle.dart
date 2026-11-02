/// 起票時の環境情報スナップショット。
///
/// iOS 版 `FeedbackBundle.swift` の移植。Issue 本文の `## Environment` セクションを組み立てる。
class FeedbackBundle {
  FeedbackBundle({
    required this.appVersion,
    required this.buildNumber,
    required this.scheme,
    required this.deviceModel,
    required this.osVersion,
    required this.locale,
    required this.capturedAt,
    this.sceneId,
    this.screenId,
    this.selectedAccessibilityId,
  });

  final String appVersion;
  final String buildNumber;
  final String scheme;
  final String deviceModel;
  final String osVersion;
  final String locale;
  final DateTime capturedAt;
  final String? sceneId;
  final String? screenId;
  final String? selectedAccessibilityId;

  /// Issue 本文の Environment セクションを生成する。
  String renderIssueBodyEnvironmentSection() {
    final selected = selectedAccessibilityId ?? '(not selected)';
    final screen = screenId ?? '(unknown)';
    final capturedIso = capturedAt.toUtc().toIso8601String();

    return <String>[
      '## Environment',
      '- App version: $appVersion ($buildNumber)',
      '- Scheme: $scheme',
      '- Device: $deviceModel, $osVersion',
      '- Locale: $locale',
      '- Selected element: `$selected`',
      '- Captured screen id: `$screen`',
      '- Captured at: $capturedIso',
    ].join('\n');
  }
}
