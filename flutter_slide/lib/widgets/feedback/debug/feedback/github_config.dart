/// GitHub Issue 起票先 / OAuth Device Flow の設定窓口。
///
/// iOS 版の `GitHubIssueClient`(owner/repo) と `GitHubOAuthConfiguration`(client_id)
/// をまとめたもの。client_id は Client Secret ではないので公開しても問題ないが、
/// 環境ごとに差し替えられるよう 1 箇所に集約している。
///
/// バックエンド未接続のサンプルなので、値はプレースホルダ。実運用時はここを埋める。
class GitHubConfig {
  const GitHubConfig._();

  /// Issue 起票先 organization (iOS 版と同一)
  static const String owner = 'u5-03';

  /// Issue 起票先リポジトリ (iOS 版と同一)
  static const String repo = 'Slidys';

  /// GitHub App の Client ID (`Iv23li...` 形式)。
  /// 未設定 (空文字) の場合、OAuth サインインは実行できない。
  static const String clientId = '';

  /// GitHub REST API ベース URL
  static const String apiBaseUrl = 'https://api.github.com';

  /// Device authorization endpoint
  static const String deviceCodeUrl = 'https://github.com/login/device/code';

  /// Access token / refresh endpoint
  static const String tokenUrl = 'https://github.com/login/oauth/access_token';

  /// client_id が設定済みか
  static bool get isConfigured => clientId.isNotEmpty;

  /// `POST /repos/{owner}/{repo}/issues` の URL
  static Uri get createIssueUrl => Uri.parse('$apiBaseUrl/repos/$owner/$repo/issues');
}
