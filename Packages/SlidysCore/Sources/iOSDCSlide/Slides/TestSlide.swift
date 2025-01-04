//
//  TestSlide.swift
//  iOSDC2024Slide
//
//  Created by Yugo Sugiyama on 2024/08/02.
//


import SwiftUI
import SlideKit
import AVFoundation
import SlidesCore

@Slide
struct TestSlide: View {
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false

    var body: some View {
        VStack(alignment: .center) {
            Text("テスト中...")
                .font(.system(size: 100, weight: .heavy))
                .frame(maxWidth: .infinity)
                .foregroundStyle(.defaultForegroundColor)
            if isPlaying {
                Button(action: {
                    audioPlayer?.pause()
                    isPlaying = false
                }, label: {
                    Image(systemName: "pause.circle")
                        .resizable()
                        .frame(width: 500, height: 500)
                        .background(.clear)
                        .foregroundStyle(.themeColor)
                })
                .buttonStyle(PlainButtonStyle())
            } else {
                Button(action: {
                    playSound()
                    isPlaying = true
                }, label: {
                    Image(systemName: "play.circle")
                        .resizable()
                        .frame(width: 500, height: 500)
                        .background(.clear)
                        .foregroundStyle(.themeColor)
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.slideBackgroundColor)
    }
}

extension TestSlide {
    func playSound() {
        if let path = Bundle.main.path(forResource: "sonatine1", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error: Could not find or play the sound file.")
            }
        }
    }
}

#Preview {
    SlidePreview {
        TestSlide()
    }
}

