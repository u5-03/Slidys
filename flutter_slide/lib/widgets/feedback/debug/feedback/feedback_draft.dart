/// アプリ内フィードバック (GitHub Issue 起票) の下書きモデル。
///
/// iOS 版 RuntimeAppFeedback の `FeedbackDraft.swift` を Flutter に移植したもの。
/// `IssueKind` に応じてフォームの中身が変わる:
///  - [IssueKind.bug]: qa-bug-template 準拠 (概要 / 詳細 / 再現手順 / 期待する結果 ...)
///  - [IssueKind.task]: タイトル + 現状の課題 + 改善案
library;

/// Issue 種別 (Project 振り分け用)
enum IssueKind {
  /// タスク管理 (Project V2 #2)
  task,

  /// バグ管理 (Project V2 #3)
  bug;

  /// GitHub label / body 生成に使う raw 値 (iOS 版と揃える)
  String get rawValue => name;

  String get displayName => switch (this) {
        IssueKind.task => 'タスク管理',
        IssueKind.bug => 'バグ管理',
      };
}

/// 優先度 (bug のみ)
enum BugPriority {
  blocker('Blocker'),
  critical('Critical'),
  major('Major'),
  minor('Minor');

  const BugPriority(this.rawValue);
  final String rawValue;
}

/// 再現性 (bug のみ)
enum Reproducibility {
  always('常に再現'),
  sometimes('時々再現'),
  never('再現しない');

  const Reproducibility(this.rawValue);
  final String rawValue;
}

/// テストケース内/外 (bug のみ)
enum TestCaseScope {
  inside('テストケース内'),
  outside('テストケース外'),
  unspecified('未指定');

  const TestCaseScope(this.rawValue);
  final String rawValue;
}

/// 添付ファイル (画像/動画/ドキュメント)。バックエンド未接続のため、
/// ここでは表示名と MIME だけを保持するシンプルなモデルにしている。
class PickedAttachment {
  PickedAttachment({
    required this.id,
    required this.displayName,
    required this.contentType,
  });

  final String id;
  final String displayName;
  final String contentType;

  bool get isImage => contentType.startsWith('image/');
  bool get isVideo => contentType.startsWith('video/');
}

/// Issue 起票時の編集モデル
class FeedbackDraft {
  FeedbackDraft({
    this.title = '',
    List<PickedAttachment>? attachments,
    this.issueKind = IssueKind.bug,
    this.selectedAccessibilityId,
    this.includeStackTrace = true,
    this.includeViewHierarchy = true,
    this.includeLogs = true,
    this.includeDebugInfo = true,
    this.includeAppContext = true,
    this.requestAiAutoSearch = false,
    this.aiPromptCustomText = '',
    this.taskCurrentIssue = '',
    this.taskImprovement = '',
    this.bugPriority = BugPriority.major,
    this.bugDetails = '',
    this.bugReproSteps = '',
    this.bugExpectation = '',
    this.bugReproducibility = Reproducibility.always,
    this.bugConfirmedDevice = '',
    this.bugTestCaseScope = TestCaseScope.unspecified,
  }) : attachments = attachments ?? <PickedAttachment>[];

  /// 添付件数上限
  static const int attachmentLimit = 5;

  // 共通フィールド
  String title;
  List<PickedAttachment> attachments;
  IssueKind issueKind;
  String? selectedAccessibilityId;
  bool includeStackTrace;
  bool includeViewHierarchy;
  bool includeLogs;
  bool includeDebugInfo;
  bool includeAppContext;
  bool requestAiAutoSearch;
  String aiPromptCustomText;

  // task 用フィールド
  String taskCurrentIssue;
  String taskImprovement;

  // bug 用フィールド (qa-bug-template 準拠)
  BugPriority bugPriority;
  String bugDetails;
  String bugReproSteps;
  String bugExpectation;
  Reproducibility bugReproducibility;
  String bugConfirmedDevice;
  TestCaseScope bugTestCaseScope;

  /// 送信可能か (種別ごとに必須項目が異なる)。iOS 版 `isValid` と同じロジック。
  bool get isValid {
    if (title.trim().isEmpty) return false;
    switch (issueKind) {
      case IssueKind.task:
        // task の必須: タイトル + 現状の課題
        return taskCurrentIssue.trim().isNotEmpty;
      case IssueKind.bug:
        // qa-bug-template の必須: 概要 (title) / 詳細 / 再現手順 / 期待
        return bugDetails.trim().isNotEmpty &&
            bugReproSteps.trim().isNotEmpty &&
            bugExpectation.trim().isNotEmpty;
    }
  }
}
