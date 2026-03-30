import SwiftUI
import StoreKit
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
                LabeledContent("バージョン", value: "v\(appVersion)(\(buildNumber))")
            }

            Section("サポート") {
                NavigationLink {
                    DonationView()
                } label: {
                    Label("開発者をサポート", systemImage: "heart.fill")
                }
            }

            Section("法的情報") {
                NavigationLink("ライセンス") {
                    LicenseListView()
                        .licenseViewStyle(.withRepositoryAnchorLink)
                        .navigationTitle("ライセンス")
                }
            }

            Section("謝辞") {
                Link(destination: URL(string: "https://github.com/mtj0928/SlideKit")!) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("SlideKit")
                                .font(.body)
                            Text("by mtj0928")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("設定")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SettingsView()
    }
}
#endif
