import 'dart:async';

import 'package:flutter/foundation.dart';

import 'feedback_bundle.dart';
import 'feedback_draft.dart';
import 'issue_body_renderer.dart';

/// Issue 起票の結果
class IssueSubmissionResult {
  IssueSubmissionResult({
    required this.issueNumber,
    required this.issueUrl,
    required this.renderedBody,
    required this.initialLabels,
  });

  final int issueNumber;
  final Uri issueUrl;

  /// 実際に GitHub へ送る予定だった Markdown 本文 (UI プレビュー用)。
  final String renderedBody;
  final List<String> initialLabels;
}

/// Issue 起票の実行窓口。
///
/// iOS 版 `IssueSubmitter.submit()` のフロー
/// (診断収集 → Firebase upload → Issue 作成 → 遅延ラベル付与) を踏襲するが、
/// **バックエンド未接続のサンプル**のため、ネットワーク部分は擬似的にシミュレートする。
///
/// 実運用時は [_simulateCreateIssue] を GitHub REST API の POST /issues に、
/// スクリーンショット/診断アップロードを Firebase Storage に置き換える。
class IssueSubmitter {
  IssueSubmitter({required this.bundleProvider});

  /// 起票時の環境情報を供給する。
  final FeedbackBundle Function() bundleProvider;

  Future<IssueSubmissionResult> submit(FeedbackDraft draft) async {
    // 1. Issue 本文を組み立てる (screenshotUrl はバックエンド未接続なので null)
    final bundle = bundleProvider();
    final body = IssueBodyRenderer.render(draft: draft, bundle: bundle);
    final labels = IssueBodyRenderer.initialLabels(draft);

    // 2. GitHub Issue 作成 (擬似)
    final result = await _simulateCreateIssue(
      title: draft.title,
      body: body,
      labels: labels,
    );

    // 3. artifact-upload ラベルの遅延付与 (iOS 版と同じ 5 秒待機の運用ハックを踏襲)
    //    同時付与すると workflow の concurrency で artifact 処理 run が cancel される。
    unawaited(_simulateAddDeferredLabels(result.issueNumber));

    return result;
  }

  Future<IssueSubmissionResult> _simulateCreateIssue({
    required String title,
    required String body,
    required List<String> labels,
  }) async {
    // ネットワーク往復を模した遅延
    await Future<void>.delayed(const Duration(milliseconds: 900));

    // 送信予定の内容をコンソールに出しておく (実装確認用)
    debugPrint('===== [RuntimeFeedback] 起票内容 (擬似送信) =====');
    debugPrint('title : $title');
    debugPrint('labels: ${labels.join(', ')}');
    debugPrint('--- body ---\n$body');
    debugPrint('===============================================');

    // 擬似 Issue 番号 (時刻ベースで毎回変える)
    final number = 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
    return IssueSubmissionResult(
      issueNumber: number,
      issueUrl: Uri.parse(
        'https://github.com/u5-03/Slidys/issues/$number',
      ),
      renderedBody: body,
      initialLabels: labels,
    );
  }

  Future<void> _simulateAddDeferredLabels(int issueNumber) async {
    await Future<void>.delayed(const Duration(seconds: 5));
    debugPrint(
      '[RuntimeFeedback] Issue #$issueNumber に遅延ラベルを付与 (擬似): '
      '${IssueBodyRenderer.deferredLabels.join(', ')}',
    );
  }
}
