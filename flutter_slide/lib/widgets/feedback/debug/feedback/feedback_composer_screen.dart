import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'element_picker.dart';
import 'feedback_bundle.dart';
import 'feedback_draft.dart';
import 'feedback_session.dart';
import 'github_config.dart';
import 'issue_submitter.dart';

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
  const FeedbackComposerScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FeedbackComposerScreen(),
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

  /// フィールドごとの永続 TextEditingController (build 毎再生成でカーソルが飛ぶのを防ぐ)。
  final Map<String, TextEditingController> _controllers = {};

  late final IssueSubmitter _submitter = IssueSubmitter(
    bundleProvider: _makeBundle,
  );

  @override
  void initState() {
    super.initState();
    // 確認端末欄が未入力なら自動入力 (内部モデル名相当 + OS バージョン)。
    // 再オープン時に既存入力を上書きしないよう空のときだけ設定する。
    if (_draft.bugConfirmedDevice.isEmpty) {
      _draft.bugConfirmedDevice = _defaultConfirmedDevice();
    }
  }

  @override
  void dispose() {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue を起票'),
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
      title: '対象 UI 要素 (任意)',
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
                child: const Text('クリア'),
              ),
            ],
          ),
        ] else
          const Text('選択されていません'),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.center_focus_strong),
            label: const Text('画面から選ぶ'),
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
    navigator.popUntil((route) => route.isFirst);

    final identifier = await ElementPicker.pick(overlay);
    if (identifier != null) {
      _draft.selectedAccessibilityId = identifier;
    }

    // Composer を開き直す (下書きはセッションに残っているので入力内容は維持)。
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const FeedbackComposerScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  // ---- 2. Issue 種別 ----

  Widget _issueKindSection() {
    return _section(
      title: 'Issue 種別',
      children: [
        SegmentedButton<IssueKind>(
          segments: const [
            ButtonSegment(value: IssueKind.task, label: Text('タスク管理')),
            ButtonSegment(value: IssueKind.bug, label: Text('バグ管理')),
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
      title: 'Issue 内容',
      footer: isBug
          ? '項目はすべて qa-bug-template.md と同じです'
          : 'Issue として GitHub に起票されます',
      children: isBug ? _bugContentRows() : _taskContentRows(),
    );
  }

  List<Widget> _bugContentRows() {
    return [
      _textField(
        fieldKey: 'title',
        label: '概要 (タイトル)',
        hint: 'バグの要点を 1 行で',
        value: _draft.title,
        onChanged: (v) => setState(() => _draft.title = v),
      ),
      _dropdown<BugPriority>(
        label: '優先度',
        value: _draft.bugPriority,
        values: BugPriority.values,
        labelOf: (v) => v.rawValue,
        onChanged: (v) => setState(() => _draft.bugPriority = v),
      ),
      _textField(
        fieldKey: 'bug.details',
        label: '詳細',
        value: _draft.bugDetails,
        minLines: 3,
        onChanged: (v) => setState(() => _draft.bugDetails = v),
      ),
      _textField(
        fieldKey: 'bug.reproSteps',
        label: '再現手順',
        hint: '例: 1. 一覧を開く  2. 項目をタップ  3. ...',
        value: _draft.bugReproSteps,
        minLines: 3,
        onChanged: (v) => setState(() => _draft.bugReproSteps = v),
      ),
      _textField(
        fieldKey: 'bug.expectation',
        label: '期待する結果',
        value: _draft.bugExpectation,
        minLines: 2,
        onChanged: (v) => setState(() => _draft.bugExpectation = v),
      ),
      _dropdown<Reproducibility>(
        label: '再現性',
        value: _draft.bugReproducibility,
        values: Reproducibility.values,
        labelOf: (v) => v.rawValue,
        onChanged: (v) => setState(() => _draft.bugReproducibility = v),
      ),
      _textField(
        fieldKey: 'bug.confirmedDevice',
        label: '確認端末',
        hint: '起動時に自動入力',
        value: _draft.bugConfirmedDevice,
        onChanged: (v) => setState(() => _draft.bugConfirmedDevice = v),
      ),
      _dropdown<TestCaseScope>(
        label: 'テストケース内/外',
        value: _draft.bugTestCaseScope,
        values: TestCaseScope.values,
        labelOf: (v) => v.rawValue,
        onChanged: (v) => setState(() => _draft.bugTestCaseScope = v),
      ),
    ];
  }

  List<Widget> _taskContentRows() {
    return [
      _textField(
        fieldKey: 'title',
        label: 'タイトル',
        hint: 'タスクのタイトル',
        value: _draft.title,
        onChanged: (v) => setState(() => _draft.title = v),
      ),
      _textField(
        fieldKey: 'task.currentIssue',
        label: '現状の課題・わかりにくいところ',
        value: _draft.taskCurrentIssue,
        minLines: 4,
        onChanged: (v) => setState(() => _draft.taskCurrentIssue = v),
      ),
      _textField(
        fieldKey: 'task.improvement',
        label: '改善案 (任意)',
        hint: 'もし具体的な改善案があれば',
        value: _draft.taskImprovement,
        minLines: 3,
        onChanged: (v) => setState(() => _draft.taskImprovement = v),
      ),
    ];
  }

  // ---- 4. 添付ファイル ----

  Widget _attachmentSection() {
    final remaining =
        FeedbackDraft.attachmentLimit - _draft.attachments.length;
    return _section(
      title: '添付ファイル (上限 ${FeedbackDraft.attachmentLimit} 件)',
      children: [
        for (final a in _draft.attachments)
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
        if (remaining > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add_photo_alternate),
              label: Text('添付を追加 (残り $remaining 件)'),
              onPressed: _addMockAttachment,
            ),
          )
        else
          const Text('添付ファイルの上限に達しています'),
      ],
    );
  }

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
      title: '診断データ (任意)',
      footer: 'ON にした項目を Issue にアップロードする想定 (現状は本文に列挙のみ)',
      children: [
        _switch(
          'スタックトレース',
          _draft.includeStackTrace,
          (v) => setState(() => _draft.includeStackTrace = v),
        ),
        _switch(
          'Widget 階層 (View Hierarchy)',
          _draft.includeViewHierarchy,
          (v) => setState(() => _draft.includeViewHierarchy = v),
        ),
        _switch(
          'ログ',
          _draft.includeLogs,
          (v) => setState(() => _draft.includeLogs = v),
        ),
        _switch(
          'Debug Info (デバイス / バージョン等)',
          _draft.includeDebugInfo,
          (v) => setState(() => _draft.includeDebugInfo = v),
        ),
        _switch(
          'App Context (設定値 + 前回クラッシュ)',
          _draft.includeAppContext,
          (v) => setState(() => _draft.includeAppContext = v),
        ),
      ],
    );
  }

  // ---- 6. AI 自動下調べ ----

  Widget _aiAutoSearchSection() {
    return _section(
      title: 'AI 自動下調べ (任意)',
      footer:
          'ON にすると起票後に Vertex AI 経由で下調べを自動実行する想定。必須項目が'
          'すべて入力されるまで有効化されません',
      children: [
        _switch(
          'Issue 起票後に AI で自動下調べする',
          _draft.requestAiAutoSearch,
          _draft.isValid
              ? (v) => setState(() => _draft.requestAiAutoSearch = v)
              : null,
        ),
        if (!_draft.isValid)
          Text(
            '必須項目がすべて入力されると有効化されます',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (_draft.requestAiAutoSearch)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _textField(
              fieldKey: 'ai.prompt',
              label: 'AI への追加指示 (任意)',
              hint: '例: 過去 7 日以内の類似 Issue を重点的に',
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
      title: '認証 (GitHub OAuth)',
      footer:
          'OAuth Device Flow でサインインする想定。client_id は GitHubConfig に設定します'
          ' (現在: ${configured ? '設定済み' : '未設定'})',
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
                    ? 'GitHub App client_id 設定済み'
                    : 'client_id 未設定 (GitHubConfig.clientId)',
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.key),
            label: const Text('GitHub にサインイン (擬似)'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'バックエンド未接続: 実装時は OAuth Device Flow を接続します',
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
        title: '送信完了',
        children: [
          Text('Issue #${r.issueNumber} を作成しました (擬似)'),
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
              label: const Text('送信予定だった本文を見る'),
              onPressed: () => _showBodyPreview(r.renderedBody),
            ),
          ),
        ],
      );
    }
    if (state is _Failed) {
      return _section(
        title: '送信失敗',
        children: [
          Text(
            '${state.error}',
            style: const TextStyle(color: Colors.redAccent),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('再送信'),
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
            : const Text('送信'),
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
