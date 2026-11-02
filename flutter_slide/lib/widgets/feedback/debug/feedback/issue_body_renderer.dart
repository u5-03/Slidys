import 'feedback_bundle.dart';
import 'feedback_draft.dart';

/// Issue 本文 (Markdown) を組み立てる純粋関数群。
///
/// iOS 版 `IssueSubmitter.renderIssueBody()` の移植。末尾に `<!-- runtime-feedback:v1 -->`
/// マーカーを付けることで、サーバ側 (GitHub Actions) がアプリ起票 Issue を判別できる。
class IssueBodyRenderer {
  const IssueBodyRenderer._();

  /// [draft] の種別に応じて bug / task テンプレートを使い分ける。
  static String render({
    required FeedbackDraft draft,
    required FeedbackBundle bundle,
    String? screenshotUrl,
  }) {
    switch (draft.issueKind) {
      case IssueKind.bug:
        return _renderBug(draft, bundle, screenshotUrl);
      case IssueKind.task:
        return _renderTask(draft, bundle, screenshotUrl);
    }
  }

  static String _renderBug(
    FeedbackDraft draft,
    FeedbackBundle bundle,
    String? screenshotUrl,
  ) {
    final lines = <String>[
      '## 概要',
      draft.title.isEmpty ? '(未記入)' : draft.title,
      '',
      '## 優先度',
      draft.bugPriority.rawValue,
      '',
      '## 詳細',
      draft.bugDetails.isEmpty ? '(未記入)' : draft.bugDetails,
      '',
      '## 再現手順',
      draft.bugReproSteps.isEmpty ? '(未記入)' : draft.bugReproSteps,
      '',
      '## 期待する結果',
      draft.bugExpectation.isEmpty ? '(未記入)' : draft.bugExpectation,
      '',
      '## 再現性',
      draft.bugReproducibility.rawValue,
      '',
      '## テストケース内/外',
      draft.bugTestCaseScope.rawValue,
      '',
    ];
    _appendCommonSections(
      lines,
      draft: draft,
      bundle: bundle,
      screenshotUrl: screenshotUrl,
      bugConfirmedDevice: draft.bugConfirmedDevice,
    );
    return lines.join('\n');
  }

  static String _renderTask(
    FeedbackDraft draft,
    FeedbackBundle bundle,
    String? screenshotUrl,
  ) {
    final lines = <String>[
      '## タイトル',
      draft.title.isEmpty ? '(未記入)' : draft.title,
      '',
      '## 現状の課題・わかりにくいところ',
      draft.taskCurrentIssue.isEmpty ? '(未記入)' : draft.taskCurrentIssue,
      '',
      '## 改善案 (任意)',
      draft.taskImprovement.isEmpty ? '(なし)' : draft.taskImprovement,
      '',
    ];
    _appendCommonSections(
      lines,
      draft: draft,
      bundle: bundle,
      screenshotUrl: screenshotUrl,
    );
    return lines.join('\n');
  }

  /// 環境・診断データ・選択 UI 要素・処理用マーカー (共通の末尾セクション)
  static void _appendCommonSections(
    List<String> lines, {
    required FeedbackDraft draft,
    required FeedbackBundle bundle,
    String? screenshotUrl,
    String? bugConfirmedDevice,
  }) {
    var env = bundle.renderIssueBodyEnvironmentSection();
    if (bugConfirmedDevice != null && bugConfirmedDevice.isNotEmpty) {
      env += '\n- 確認端末 (ユーザ確認): $bugConfirmedDevice';
    }
    lines
      ..add(env)
      ..add('');

    final selectedId = draft.selectedAccessibilityId;
    if (selectedId != null && selectedId.isNotEmpty) {
      lines
        ..add('## 対象 UI 要素')
        ..add('`$selectedId`')
        ..add('');
    }

    // Screenshot (バックエンド未接続時は URL が無いので注記のみ)
    lines
      ..add('## Screenshot')
      ..add('');
    if (screenshotUrl != null) {
      lines.add('![screenshot.png]($screenshotUrl)');
    } else {
      lines.add('_(バックエンド未接続のため未アップロード)_');
    }
    lines.add('');

    // 添付予定の診断データ (ON のものを列挙)
    final diagnostics = _enabledDiagnostics(draft);
    if (diagnostics.isNotEmpty) {
      lines
        ..add('## 診断データ (添付予定)')
        ..add('');
      for (final d in diagnostics) {
        lines.add('- $d');
      }
      lines.add('');
    }

    // ユーザ添付ファイル
    if (draft.attachments.isNotEmpty) {
      lines
        ..add('## ユーザ添付ファイル')
        ..add('');
      for (var i = 0; i < draft.attachments.length; i++) {
        final a = draft.attachments[i];
        lines
          ..add('### Attachment ${i + 1}: ${a.displayName}')
          ..add('_(バックエンド未接続のため未アップロード)_')
          ..add('');
      }
    }

    // AI 自動下調べ用の追加プロンプト (workflow が抽出して Claude に渡す)
    final aiPrompt = draft.aiPromptCustomText.trim();
    if (draft.requestAiAutoSearch && aiPrompt.isNotEmpty) {
      lines
        ..add('<details>')
        ..add('<summary>🤖 AI 追加プロンプト</summary>')
        ..add('')
        ..add('<!-- ai-prompt-extra:v1 -->')
        ..add('')
        ..add(aiPrompt)
        ..add('')
        ..add('<!-- /ai-prompt-extra -->')
        ..add('')
        ..add('</details>')
        ..add('');
    }

    lines.add('<!-- runtime-feedback:v1 -->');
  }

  static List<String> _enabledDiagnostics(FeedbackDraft draft) {
    return <String>[
      if (draft.includeStackTrace) 'スタックトレース (stack-trace.txt)',
      if (draft.includeViewHierarchy) 'Widget 階層 (view-hierarchy.txt)',
      if (draft.includeLogs) 'ログ (logs.json)',
      if (draft.includeDebugInfo) 'Debug Info (debug-info.txt)',
      if (draft.includeAppContext) 'App Context (app-context.json)',
    ];
  }

  /// Issue 作成時に同時付与する初期ラベル。
  /// `feedback:artifact-upload` は同時 `issues:labeled` イベントによる
  /// workflow の concurrency-cancel を避けるため、ここには含めず遅延付与する。
  static List<String> initialLabels(FeedbackDraft draft) {
    return <String>[
      'feedback:project-${draft.issueKind.rawValue}',
      if (draft.requestAiAutoSearch) 'ai-auto-search',
    ];
  }

  /// 作成完了後に遅延付与するラベル (iOS 版で 5 秒待ってから付与しているもの)。
  static const List<String> deferredLabels = <String>['feedback:artifact-upload'];
}
