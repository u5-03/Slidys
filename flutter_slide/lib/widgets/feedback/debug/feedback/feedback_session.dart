import 'feedback_draft.dart';

/// アプリ起動中の下書きを保持するセッション。
///
/// iOS 版の `FeedbackDraftPersistence` に相当。ElementPicker で画面から要素を選ぶ際に
/// Composer を一旦閉じてもフォーム入力が失われないよう、下書きを画面の外 (ここ) に置く。
class FeedbackSession {
  FeedbackSession._();

  static final FeedbackSession instance = FeedbackSession._();

  /// 現在編集中の下書き。Composer はこのインスタンスを直接編集する。
  FeedbackDraft draft = FeedbackDraft();

  /// 送信成功後などに下書きを初期化する。
  void reset() {
    draft = FeedbackDraft();
  }
}
