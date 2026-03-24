//
//  PanelThemeView.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/02/21.
//

import SwiftUI

struct PanelThemeView: View {
    @Namespace var titleNameSpace
    @Namespace var descriptionNameSpace
    @Namespace var backgroundNameSpace
    @State private var panelThemes = PanelData.panelThemeList
    @State private var selectedTheme: PanelThemeModel?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    panelThemeItemView(theme: panelThemes[0])
                    panelThemeItemView(theme: panelThemes[1])
                }
                HStack(spacing: 0) {
                    panelThemeItemView(theme: panelThemes[2])
                    panelThemeItemView(theme: panelThemes[3])
                }
            }
            if let selectedTheme {
                panelThemeBaseView(theme: selectedTheme, isDetail: true)
                    .onTapGesture {
                        self.selectedTheme = nil
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundStyle(.white)
        .animation(.bouncy, value: selectedTheme?.id)
        .ignoresSafeArea()
    }
}

private extension PanelThemeView {
    func panelThemeItemView(theme: PanelThemeModel) ->  some View {
        panelThemeBaseView(theme: theme, isDetail: false)
            .onTapGesture {
                selectedTheme = theme
            }
    }

    func panelThemeBaseView(theme: PanelThemeModel, isDetail: Bool) ->  some View {
        theme.backgroundColor.brightness(0.3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .matchedGeometryEffect(id: theme.id, in: backgroundNameSpace)
            .overlay {
                VStack(alignment: .center, spacing: 40) {
                    Text(theme.title)
                        .font(.system(size: isDetail ? 80 : 42, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .shadow(color: .black, radius: 10)
                        .matchedGeometryEffect(id: theme.id, in: titleNameSpace)
                    if isDetail {
                        VStack(alignment: .leading, spacing: 32) {
                            ForEach(Array(theme.descriptions.enumerated()), id: \.offset) {
                                Text("\($0.offset + 1). \($0.element)")
                                    .minimumScaleFactor(0.1)
                                    .font(.system(size: 60, weight: .medium))
                                    .shadow(color: .black, radius: 10)
                                    .frame(alignment: .leading)
                            }
                        }
                        .matchedGeometryEffect(id: theme.id, in: descriptionNameSpace)
                    } else {
                        EmptyView()
                            .matchedGeometryEffect(id: theme.id, in: descriptionNameSpace)
                    }
                }
                .padding()
            }
    }
}

#Preview {
    PanelThemeView()
}
