import SwiftUI
import LicenseList

struct SettingsView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
    }

    var body: some View {
        List {
            Section("アプリ情報") {
                LabeledContent("バージョン", value: appVersion)
                LabeledContent("ビルド", value: buildNumber)
            }

            Section("法的情報") {
                NavigationLink("ライセンス") {
                    LicenseListView()
                        .licenseViewStyle(.withRepositoryAnchorLink)
                        .navigationTitle("ライセンス")
                }
            }
        }
        .navigationTitle("設定")
    }
}
