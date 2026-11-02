import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../slide_language.dart';

import 'element_picker.dart';
import 'feedback_bundle.dart';
import 'feedback_draft.dart';
import 'feedback_session.dart';
import 'github_config.dart';
import 'issue_submitter.dart';
import 'screen_replay_recorder.dart';

/// Composer の送信状態
sealed class _SubmissionState {
  const _SubmissionState();
}

class _Idle extends _SubmissionState {
  const _Idle();
}

class _Submitting extends _SubmissionState {
  const _Submitting();
}

class _Succeeded extends _SubmissionState {
  const _Succeeded(this.result);
  final IssueSubmissionResult result;
}

class _Failed extends _SubmissionState {
  const _Failed(this.error);
  final Object error;
}

/// アプリ内フィードバック (GitHub Issue) 起票画面。
///
/// iOS 版 `FeedbackComposerScreen.swift` の移植。フォームの構成・必須項目・
/// 診断データトグル・AI 自動下調べ・2 段階ラベル戦略はそのまま踏襲している。
class FeedbackComposerScreen extends StatefulWidget {
  const FeedbackComposerScreen({
    super.key,
    this.textScale = 1.0,
    this.recentClipDuration,
  });

  /// 文字の拡大率(発表のデモで会場から読めるように大きくする用途)
  final double textScale;

  /// 「直近の動画を添付」で書き出す長さ。null ならリングバッファの保持時間(60 秒)。
  /// 秒数・解像度・fps はプロジェクトに合わせて調整する前提。
  final Duration? recentClipDuration;

  static Future<void> show(
    BuildContext context, {
    double textScale = 1.0,
    Duration? recentClipDuration,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FeedbackComposerScreen(
          textScale: textScale,
          recentClipDuration: recentClipDuration,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<FeedbackComposerScreen> createState() => _FeedbackComposerScreenState();
}

class _FeedbackComposerScreenState extends State<FeedbackComposerScreen> {
  /// 下書きはセッションに保持する (ElementPicker で画面へ戻っても失われないように)。
  FeedbackDraft get _draft => FeedbackSession.instance.draft;
  _SubmissionState _state = const _Idle();

  /// 直近の動画を書き出し中か
  bool _exportingClip = false;

  /// 要素選択のために閉じて開き直す途中か(録画を再開しないため)
  bool _reopeningAfterPick = false;

  /// フィールドごとの永続 TextEditingController (build 毎再生成でカーソルが飛ぶのを防ぐ)。
  final Map<String, TextEditingController> _controllers = {};

  late final IssueSubmitter _submitter = IssueSubmitter(
    bundleProvider: _makeBundle,
  );

  @override
  void initState() {
    super.initState();
    // 起票画面を開いている間は録画を止め、直近の動画が「開く直前まで」になるようにする
    ScreenReplayRecorder.instance.pause();
    // 確認端末欄が未入力なら自動入力 (内部モデル名相当 + OS バージョン)。
    // 再オープン時に既存入力を上書きしないよう空のときだけ設定する。
    if (_draft.bugConfirmedDevice.isEmpty) {
      _draft.bugConfirmedDevice = _defaultConfirmedDevice();
    }
  }

  @override
  void dispose() {
    // 要素選択のために一旦閉じるときは止めたまま(選択中の画面を動画に入れない)
    if (!_reopeningAfterPick) ScreenReplayRecorder.instance.resume();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String key, String initial) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initial),
    );
  }

  FeedbackBundle _makeBundle() {
    return FeedbackBundle(
      appVersion: '1.0.0',
      buildNumber: '1',
      scheme: kReleaseMode ? 'Release' : 'Debug',
      deviceModel: _defaultConfirmedDevice(),
      osVersion: _osVersion(),
      locale: WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
      capturedAt: DateTime.now(),
      selectedAccessibilityId: _draft.selectedAccessibilityId,
    );
  }

  String _osVersion() {
    if (kIsWeb) return 'Web';
    try {
      return Platform.operatingSystemVersion;
    } catch (_) {
      return 'unknown';
    }
  }

  String _defaultConfirmedDevice() {
    if (kIsWeb) return 'Web browser';
    try {
      return '${Platform.operatingSystem}, ${Platform.operatingSystemVersion}';
    } catch (_) {
      return 'unknown';
    }
  }

  bool get _isSubmitting => _state is _Submitting;

  bool get _isSubmitDisabled => !_draft.isValid || _isSubmitting;

  Future<void> _performSubmit() async {
    setState(() => _state = const _Submitting());
    // 送信中表示を最低 1 フレーム見せる (即時 throw で loading が飛ぶのを防ぐ)
    await Future<void>.delayed(const Duration(milliseconds: 50));
    try {
      final result = await _submitter.submit(_draft);
      // 送信成功 → 下書きをクリア (次回はまっさらな状態で開く)。
      FeedbackSession.instance.reset();
      for (final c in _controllers.values) {
        c.clear();
      }
      if (!mounted) return;
      setState(() => _state = _Succeeded(result));
    } catch (error) {
      if (!mounted) return;
      setState(() => _state = _Failed(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return MediaQuery(
      data:
          mediaQuery.copyWith(textScaler: TextScaler.linear(widget.textScale)),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Issue を起票', 'Create an issue')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _elementSection(),
          _issueKindSection(),
          _issueContentSection(),
          _attachmentSection(),
          _diagnosticSection(),
          _aiAutoSearchSection(),
          _authenticationSection(),
          _submissionStatusSection(),
          const SizedBox(height: 16),
          _submitButton(),
        ],
      ),
    );
  }

  // ---- Section 共通レイアウト ----

  Widget _section({
    required String title,
    String? footer,
    List<Widget> trailing = const [],
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                ...trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
            if (footer != null) ...[
              const SizedBox(height: 8),
              Text(
                footer,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- 1. 対象 UI 要素 ----

  Widget _elementSection() {
    final id = _draft.selectedAccessibilityId;
    return _section(
      title: tr('対象 UI 要素 (任意)', 'Target UI element (optional)'),
      children: [
        if (id != null && id.isNotEmpty) ...[
          Row(
            children: [
              const Text('Identifier: '),
              Expanded(
                child: Text(id, overflow: TextOverflow.ellipsis),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _draft.selectedAccessibilityId = null),
                child: Text(tr('クリア', 'Clear')),
              ),
            ],
          ),
        ] else
          Text(tr('選択されていません', 'No element selected')),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.center_focus_strong),
            label: Text(tr('画面から選ぶ', 'Pick from screen')),
            onPressed: _pickElement,
          ),
        ),
      ],
    );
  }

  /// 画面上の要素をタップして選択する(選んだ要素が枠で囲まれる)。
  ///
  /// iOS 版 (ElementPicker) と同じく、Composer / DebugMenu を一旦閉じてアプリ本体を
  /// 露出させ、その上に透明なピッカーを重ねてタップで要素を選ぶ。選択結果は
  /// セッションの下書きに保持され、Composer を開き直しても入力内容は維持される。
  Future<void> _pickElement() async {
    // Composer を閉じる前に root Overlay / Navigator を確保しておく。
    final overlay = Overlay.of(context, rootOverlay: true);
    final navigator = Navigator.of(context);

    // Composer と DebugMenu を閉じてアプリ本体を表示する。
    _reopeningAfterPick = true;
    navigator.popUntil((route) => route.isFirst);

    final identifier = await ElementPicker.pick(overlay);
    if (identifier != null) {
      _draft.selectedAccessibilityId = identifier;
    }

    // Composer を開き直す (下書きはセッションに残っているので入力内容は維持)。
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => FeedbackComposerScreen(
          textScale: widget.textScale,
          recentClipDuration: widget.recentClipDuration,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  // ---- 2. Issue 種別 ----

  Widget _issueKindSection() {
    return _section(
      title: tr('Issue 種別', 'Issue type'),
      children: [
        SegmentedButton<IssueKind>(
          segments: [
            ButtonSegment(
                value: IssueKind.task, label: Text(tr('タスク管理', 'Task'))),
            ButtonSegment(value: IssueKind.bug, label: Text(tr('バグ管理', 'Bug'))),
          ],
          selected: {_draft.issueKind},
          onSelectionChanged: (selected) {
            setState(() => _draft.issueKind = selected.first);
          },
        ),
      ],
    );
  }

  // ---- 3. Issue 内容 (種別ごとに切替) ----

  Widget _issueContentSection() {
    final isBug = _draft.issueKind == IssueKind.bug;
    return _section(
      title: tr('Issue 内容', 'Issue details'),
      footer: isBug
          ? tr('項目はすべて qa-bug-template.md と同じです',
              'Fields match qa-bug-template.md')
          : tr('Issue として GitHub に起票されます', 'Creates an issue on GitHub'),
      children: isBug ? _bugContentRows() : _taskContentRows(),
    );
  }

  List<Widget> _bugContentRows() {
    return [
      _textField(
        fieldKey: 'title',
        label: tr('概要 (タイトル)', 'Summary (title)'),
        hint: tr('バグの要点を 1 行で', 'Summarize the bug in one line'),
        value: _draft.title,
        onChanged: (v) => setState(() => _draft.title = v),
      ),
      _dropdown<BugPriority>(
        label: tr('優先度', 'Priority'),
        value: _draft.bugPriority,
        values: BugPriority.values,
        labelOf: (v) => v.rawValue,
        onChanged: (v) => setState(() => _draft.bugPriority = v),
      ),
      _textField(
        fieldKey: 'bug.details',
        label: tr('詳細', 'Description'),
        value: _draft.bugDetails,
        minLines: 3,
        onChanged: (v) => setState(() => _draft.bugDetails = v),
      ),
      _textField(
        fieldKey: 'bug.reproSteps',
        label: tr('再現手順', 'Steps to reproduce'),
        hint: tr('例: 1. 一覧を開く  2. 項目をタップ  3. ...',
            'Example: 1. Open the list  2. Tap an item  3. ...'),
        value: _draft.bugReproSteps,
        minLines: 3,
        onChanged: (v) => setState(() => _draft.bugReproSteps = v),
      ),
      _textField(
        fieldKey: 'bug.expectation',
        label: tr('期待する結果', 'Expected result'),
        value: _draft.bugExpectation,
        minLines: 2,
        onChanged: (v) => setState(() => _draft.bugExpectation = v),
      ),
      _dropdown<Reproducibility>(
        label: tr('再現性', 'Reproducibility'),
        value: _draft.bugReproducibility,
        values: Reproducibility.values,
        labelOf: (v) => tr(
            v.rawValue,
            switch (v) {
              Reproducibility.always => 'Always',
              Reproducibility.sometimes => 'Sometimes',
              Reproducibility.never => 'Never'
            }),
        onChanged: (v) => setState(() => _draft.bugReproducibility = v),
      ),
      _textField(
        fieldKey: 'bug.confirmedDevice',
        label: tr('確認端末', 'Tested device'),
        hint: tr('起動時に自動入力', 'Filled automatically when opened'),
        value: _draft.bugConfirmedDevice,
        onChanged: (v) => setState(() => _draft.bugConfirmedDevice = v),
      ),
      _dropdown<TestCaseScope>(
        label: tr('テストケース内/外', 'Test case coverage'),
        value: _draft.bugTestCaseScope,
        values: TestCaseScope.values,
        labelOf: (v) => tr(
            v.rawValue,
            switch (v) {
              TestCaseScope.inside => 'Within test cases',
              TestCaseScope.outside => 'Outside test cases',
              TestCaseScope.unspecified => 'Not specified'
            }),
        onChanged: (v) => setState(() => _draft.bugTestCaseScope = v),
      ),
    ];
  }

  List<Widget> _taskContentRows() {
    return [
      _textField(
        fieldKey: 'title',
        label: tr('タイトル', 'Title'),
        hint: tr('タスクのタイトル', 'Task title'),
        value: _draft.title,
        onChanged: (v) => setState(() => _draft.title = v),
      ),
      _textField(
        fieldKey: 'task.currentIssue',
        label: tr('現状の課題・わかりにくいところ', 'Current problem or confusing behavior'),
        value: _draft.taskCurrentIssue,
        minLines: 4,
        onChanged: (v) => setState(() => _draft.taskCurrentIssue = v),
      ),
      _textField(
        fieldKey: 'task.improvement',
        label: tr('改善案 (任意)', 'Suggested improvement (optional)'),
        hint: tr('もし具体的な改善案があれば', 'Describe an improvement, if you have one'),
        value: _draft.taskImprovement,
        minLines: 3,
        onChanged: (v) => setState(() => _draft.taskImprovement = v),
      ),
    ];
  }

  // ---- 4. 添付ファイル ----

  Widget _attachmentSection() {
    final remaining = FeedbackDraft.attachmentLimit - _draft.attachments.length;
    return _section(
      title: tr('添付ファイル (上限 ${FeedbackDraft.attachmentLimit} 件)',
          'Attachments (up to ${FeedbackDraft.attachmentLimit})'),
      children: [
        for (final a in _draft.attachments) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(a.isVideo ? Icons.movie : Icons.image),
            title: Text(a.displayName, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
              onPressed: () => setState(
                () => _draft.attachments.removeWhere((x) => x.id == a.id),
              ),
            ),
          ),
          // 添付した動画はその場で再生して確認できる(フォトライブラリーを開かずに済む)
          if (a.isVideo && a.filePath != null && _canPreviewClip)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ClipPreview(key: ValueKey(a.id), path: a.filePath!),
            ),
        ],
        if (remaining > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(tr('添付を追加 (残り $remaining 件)',
                  'Add attachment ($remaining remaining)')),
              onPressed: _addMockAttachment,
            ),
          ),
        if (remaining > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: _exportingClip
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.videocam),
              label: Text(_exportingClip
                  ? tr('動画を書き出し中…', 'Exporting video…')
                  : tr('直近の動画を添付', 'Attach recent video')),
              onPressed: _exportingClip ? null : _attachRecentClip,
            ),
          )
        else
          Text(tr('添付ファイルの上限に達しています', 'Attachment limit reached')),
      ],
    );
  }

  /// 裏で撮り続けている静止画(リングバッファ)から直近の動画を書き出して添付する。
  Future<void> _attachRecentClip() async {
    setState(() => _exportingClip = true);
    try {
      final clip = await ScreenReplayRecorder.instance.exportClip(
        duration: widget.recentClipDuration,
      );
      if (!mounted) return;
      setState(() {
        _draft.attachments.add(
          PickedAttachment(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            displayName:
                'screen-replay_${clip.duration.toStringAsFixed(0)}s.mp4',
            contentType: 'video/mp4',
            filePath: clip.path,
          ),
        );
      });
      debugPrint('[composer] 直近の動画を添付: ${clip.path}');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                tr('動画を書き出せませんでした: $error', 'Could not export video: $error'))),
      );
    } finally {
      if (mounted) setState(() => _exportingClip = false);
    }
  }

  /// 動画プレビュー(端末内のファイルを再生するので Web では出さない)
  bool get _canPreviewClip => !kIsWeb;

  void _addMockAttachment() {
    // バックエンド未接続のため、擬似的な添付を追加する。
    final index = _draft.attachments.length + 1;
    setState(() {
      _draft.attachments.add(
        PickedAttachment(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          displayName: 'attachment_$index.png',
          contentType: 'image/png',
        ),
      );
    });
  }

  // ---- 5. 診断データ ----

  Widget _diagnosticSection() {
    return _section(
      title: tr('診断データ (任意)', 'Diagnostics (optional)'),
      footer: tr('ON にした項目を Issue にアップロードする想定 (現状は本文に列挙のみ)',
          'Selected diagnostics would be uploaded (currently listed in the issue body only)'),
      children: [
        _switch(
          tr('スタックトレース', 'Stack trace'),
          _draft.includeStackTrace,
          (v) => setState(() => _draft.includeStackTrace = v),
        ),
        _switch(
          tr('Widget 階層 (View Hierarchy)', 'Widget hierarchy (View Hierarchy)'),
          _draft.includeViewHierarchy,
          (v) => setState(() => _draft.includeViewHierarchy = v),
        ),
        _switch(
          tr('ログ', 'Logs'),
          _draft.includeLogs,
          (v) => setState(() => _draft.includeLogs = v),
        ),
        _switch(
          tr('Debug Info (デバイス / バージョン等)',
              'Debug info (device / version, etc.)'),
          _draft.includeDebugInfo,
          (v) => setState(() => _draft.includeDebugInfo = v),
        ),
        _switch(
          tr('App Context (設定値 + 前回クラッシュ)',
              'App context (settings + previous crash)'),
          _draft.includeAppContext,
          (v) => setState(() => _draft.includeAppContext = v),
        ),
      ],
    );
  }

  // ---- 6. AI 自動下調べ ----

  Widget _aiAutoSearchSection() {
    return _section(
      title: tr('AI 自動下調べ (任意)', 'AI research (optional)'),
      footer: tr(
          'ON にすると起票後に Vertex AI 経由で下調べを自動実行する想定。必須項目がすべて入力されるまで有効化されません',
          'When enabled, Vertex AI would research the issue after submission. All required fields must be filled first.'),
      children: [
        _switch(
          tr('Issue 起票後に AI で自動下調べする',
              'Run AI research after creating the issue'),
          _draft.requestAiAutoSearch,
          _draft.isValid
              ? (v) => setState(() => _draft.requestAiAutoSearch = v)
              : null,
        ),
        if (!_draft.isValid)
          Text(
            tr('必須項目がすべて入力されると有効化されます',
                'Available once all required fields are filled'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (_draft.requestAiAutoSearch)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _textField(
              fieldKey: 'ai.prompt',
              label:
                  tr('AI への追加指示 (任意)', 'Additional AI instructions (optional)'),
              hint: tr('例: 過去 7 日以内の類似 Issue を重点的に',
                  'Example: Focus on similar issues from the past 7 days'),
              value: _draft.aiPromptCustomText,
              minLines: 2,
              onChanged: (v) => setState(() => _draft.aiPromptCustomText = v),
            ),
          ),
      ],
    );
  }

  // ---- 7. 認証 (GitHub OAuth) ----

  Widget _authenticationSection() {
    final configured = GitHubConfig.isConfigured;
    return _section(
      title: tr('認証 (GitHub OAuth)', 'Authentication (GitHub OAuth)'),
      footer: tr(
          'OAuth Device Flow でサインインする想定。client_id は GitHubConfig に設定します (現在: ${configured ? '設定済み' : '未設定'})',
          'Sign-in would use OAuth Device Flow. Set client_id in GitHubConfig (currently: ${configured ? 'configured' : 'not configured'}).'),
      children: [
        Row(
          children: [
            Icon(
              configured ? Icons.check_circle : Icons.error_outline,
              color: configured ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                configured
                    ? tr('GitHub App client_id 設定済み',
                        'GitHub App client_id configured')
                    : tr('client_id 未設定 (GitHubConfig.clientId)',
                        'client_id not configured (GitHubConfig.clientId)'),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.key),
            label: Text(tr('GitHub にサインイン (擬似)', 'Sign in to GitHub (demo)')),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    tr('バックエンド未接続: 実装時は OAuth Device Flow を接続します',
                        'Backend not connected: OAuth Device Flow would be used'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---- 8. 送信状態 ----

  Widget _submissionStatusSection() {
    final state = _state;
    if (state is _Succeeded) {
      final r = state.result;
      return _section(
        title: tr('送信完了', 'Submitted'),
        children: [
          Text(tr('Issue #${r.issueNumber} を作成しました (擬似)',
              'Created issue #${r.issueNumber} (demo)')),
          const SizedBox(height: 4),
          SelectableText(
            r.issueUrl.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text('labels: ${r.initialLabels.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.article),
              label: Text(tr('送信予定だった本文を見る', 'Preview issue body')),
              onPressed: () => _showBodyPreview(r.renderedBody),
            ),
          ),
        ],
      );
    }
    if (state is _Failed) {
      return _section(
        title: tr('送信失敗', 'Submission failed'),
        children: [
          Text(
            '${state.error}',
            style: const TextStyle(color: Colors.redAccent),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: Text(tr('再送信', 'Retry')),
              onPressed: _performSubmit,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showBodyPreview(String body) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: controller,
            child: SelectableText(
              body,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _isSubmitDisabled ? null : _performSubmit,
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(tr('送信', 'Submit')),
      ),
    );
  }

  // ---- 入力ウィジェットのヘルパ ----

  Widget _textField({
    required String fieldKey,
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    String? hint,
    int minLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controllerFor(fieldKey, value),
        minLines: minLines,
        maxLines: minLines > 1 ? minLines + 4 : 1,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T) labelOf,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            items: [
              for (final v in values)
                DropdownMenuItem(value: v, child: Text(labelOf(v))),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }

  Widget _switch(String label, bool value, ValueChanged<bool>? onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// 添付した動画のプレビュー(video_player)。
/// シークバーをドラッグして、直近の画面がちゃんと撮れていることをその場で見せられる。
class _ClipPreview extends StatefulWidget {
  const _ClipPreview({super.key, required this.path});

  final String path;

  @override
  State<_ClipPreview> createState() => _ClipPreviewState();
}

class _ClipPreviewState extends State<_ClipPreview> {
  late final VideoPlayerController _controller =
      VideoPlayerController.file(File(widget.path));
  Object? _error;

  /// ドラッグ中の位置(ms)。ドラッグ中は再生位置の通知で値が戻らないようにする
  double? _dragMs;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTick);
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
    }).catchError((Object error) {
      if (mounted) setState(() => _error = error);
    });
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final s = d.inMilliseconds / 1000;
    return tr('${s.toStringAsFixed(1)} 秒', '${s.toStringAsFixed(1)} s');
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = _controller.value;

    if (_error != null) {
      return Text(tr('動画を再生できませんでした: $_error', 'Could not play video: $_error'),
          style: TextStyle(color: scheme.error));
    }
    if (!value.isInitialized) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final totalMs = value.duration.inMilliseconds.toDouble();
    final positionMs = (_dragMs ?? value.position.inMilliseconds.toDouble())
        .clamp(0.0, totalMs);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 960),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _togglePlay,
              child: AspectRatio(
                aspectRatio: value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    if (!value.isPlaying && _dragMs == null)
                      const Icon(Icons.play_circle_fill,
                          size: 96, color: Colors.white70),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    color: Colors.white,
                    iconSize: 56,
                    icon:
                        Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _togglePlay,
                  ),
                  Text(
                    _format(Duration(milliseconds: positionMs.round())),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 10,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 18),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 36),
                      ),
                      child: Slider(
                        min: 0,
                        max: totalMs <= 0 ? 1 : totalMs,
                        value: totalMs <= 0 ? 0 : positionMs,
                        activeColor: scheme.primaryContainer,
                        inactiveColor: Colors.white24,
                        // ドラッグ中は止め、離したらそのコマで止めたままにする(指し示しながら説明できる)
                        onChangeStart: (v) {
                          _controller.pause();
                          setState(() => _dragMs = v);
                        },
                        onChanged: (v) {
                          setState(() => _dragMs = v);
                          _controller.seekTo(Duration(milliseconds: v.round()));
                        },
                        onChangeEnd: (v) async {
                          await _controller
                              .seekTo(Duration(milliseconds: v.round()));
                          if (!mounted) return;
                          setState(() => _dragMs = null);
                        },
                      ),
                    ),
                  ),
                  Text(
                    _format(value.duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
