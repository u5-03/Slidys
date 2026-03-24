//
//  GradientMusicStrokeAnimationView.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI

struct MusicIconShape: Shape {
    var animatableData: CGFloat {
        get { animationProgress }
        set { animationProgress = newValue }
    }

    var animationProgress: CGFloat = 0
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.71638*width, y: 0.60023*height))
        path.addCurve(to: CGPoint(x: 0.54777*width, y: 0.43162*height), control1: CGPoint(x: 0.71638*width, y: 0.50711*height), control2: CGPoint(x: 0.6409*width, y: 0.43162*height))
        path.addCurve(to: CGPoint(x: 0.53646*width, y: 0.43229*height), control1: CGPoint(x: 0.54393*width, y: 0.43162*height), control2: CGPoint(x: 0.5402*width, y: 0.432*height))
        path.addCurve(to: CGPoint(x: 0.52614*width, y: 0.35003*height), control1: CGPoint(x: 0.53287*width, y: 0.40382*height), control2: CGPoint(x: 0.52939*width, y: 0.37614*height))
        path.addCurve(to: CGPoint(x: 0.63524*width, y: 0.2646*height), control1: CGPoint(x: 0.56569*width, y: 0.32149*height), control2: CGPoint(x: 0.60542*width, y: 0.29398*height))
        path.addCurve(to: CGPoint(x: 0.58382*width, y: 0), control1: CGPoint(x: 0.74184*width, y: 0.15961*height), control2: CGPoint(x: 0.71108*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.45867*width, y: 0.17551*height), control1: CGPoint(x: 0.45656*width, y: 0), control2: CGPoint(x: 0.45391*width, y: 0.13893*height))
        path.addCurve(to: CGPoint(x: 0.47474*width, y: 0.3028*height), control1: CGPoint(x: 0.46121*width, y: 0.19488*height), control2: CGPoint(x: 0.46803*width, y: 0.25345*height))
        path.addCurve(to: CGPoint(x: 0.46823*width, y: 0.30755*height), control1: CGPoint(x: 0.47212*width, y: 0.30482*height), control2: CGPoint(x: 0.46988*width, y: 0.30647*height))
        path.addCurve(to: CGPoint(x: 0.28371*width, y: 0.5891*height), control1: CGPoint(x: 0.35837*width, y: 0.37933*height), control2: CGPoint(x: 0.28051*width, y: 0.46661*height))
        path.addCurve(to: CGPoint(x: 0.50958*width, y: 0.78795*height), control1: CGPoint(x: 0.28631*width, y: 0.6901*height), control2: CGPoint(x: 0.38232*width, y: 0.78795*height))
        path.addCurve(to: CGPoint(x: 0.53823*width, y: 0.78637*height), control1: CGPoint(x: 0.51933*width, y: 0.78821*height), control2: CGPoint(x: 0.52884*width, y: 0.78751*height))
        path.addCurve(to: CGPoint(x: 0.5414*width, y: 0.81022*height), control1: CGPoint(x: 0.53943*width, y: 0.79569*height), control2: CGPoint(x: 0.54051*width, y: 0.80382*height))
        path.addCurve(to: CGPoint(x: 0.48732*width, y: 0.95179*height), control1: CGPoint(x: 0.55253*width, y: 0.88975*height), control2: CGPoint(x: 0.5239*width, y: 0.94066*height))
        path.addCurve(to: CGPoint(x: 0.41097*width, y: 0.93748*height), control1: CGPoint(x: 0.45072*width, y: 0.96293*height), control2: CGPoint(x: 0.41732*width, y: 0.9502*height))
        path.addCurve(to: CGPoint(x: 0.438*width, y: 0.92315*height), control1: CGPoint(x: 0.40459*width, y: 0.92474*height), control2: CGPoint(x: 0.41891*width, y: 0.92791*height))
        path.addCurve(to: CGPoint(x: 0.4714*width, y: 0.87224*height), control1: CGPoint(x: 0.45709*width, y: 0.91839*height), control2: CGPoint(x: 0.46982*width, y: 0.88816*height))
        path.addCurve(to: CGPoint(x: 0.39664*width, y: 0.79748*height), control1: CGPoint(x: 0.4755*width, y: 0.83116*height), control2: CGPoint(x: 0.43794*width, y: 0.79748*height))
        path.addCurve(to: CGPoint(x: 0.32187*width, y: 0.87224*height), control1: CGPoint(x: 0.35534*width, y: 0.79748*height), control2: CGPoint(x: 0.32699*width, y: 0.83128*height))
        path.addCurve(to: CGPoint(x: 0.33619*width, y: 0.93748*height), control1: CGPoint(x: 0.3187*width, y: 0.8977*height), control2: CGPoint(x: 0.32505*width, y: 0.91839*height))
        path.addCurve(to: CGPoint(x: 0.47936*width, y: 0.99791*height), control1: CGPoint(x: 0.368*width, y: 0.98361*height), control2: CGPoint(x: 0.4205*width, y: 1.00747*height))
        path.addCurve(to: CGPoint(x: 0.58751*width, y: 0.84839*height), control1: CGPoint(x: 0.55223*width, y: 0.98609*height), control2: CGPoint(x: 0.59396*width, y: 0.92344*height))
        path.addCurve(to: CGPoint(x: 0.57957*width, y: 0.77682*height), control1: CGPoint(x: 0.5864*width, y: 0.83537*height), control2: CGPoint(x: 0.58354*width, y: 0.81003*height))
        path.addCurve(to: CGPoint(x: 0.71638*width, y: 0.60023*height), control1: CGPoint(x: 0.65943*width, y: 0.74906*height), control2: CGPoint(x: 0.71638*width, y: 0.67334*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.50639*width, y: 0.18347*height))
        path.addCurve(to: CGPoint(x: 0.60715*width, y: 0.0594*height), control1: CGPoint(x: 0.49686*width, y: 0.08483*height), control2: CGPoint(x: 0.5626*width, y: 0.03235*height))
        path.addCurve(to: CGPoint(x: 0.51584*width, y: 0.26645*height), control1: CGPoint(x: 0.67053*width, y: 0.09788*height), control2: CGPoint(x: 0.57897*width, y: 0.20579*height))
        path.addCurve(to: CGPoint(x: 0.50639*width, y: 0.18347*height), control1: CGPoint(x: 0.51143*width, y: 0.22982*height), control2: CGPoint(x: 0.50806*width, y: 0.20063*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.43004*width, y: 0.73543*height))
        path.addCurve(to: CGPoint(x: 0.39028*width, y: 0.48091*height), control1: CGPoint(x: 0.35051*width, y: 0.6925*height), control2: CGPoint(x: 0.34256*width, y: 0.56842*height))
        path.addCurve(to: CGPoint(x: 0.4872*width, y: 0.37886*height), control1: CGPoint(x: 0.41122*width, y: 0.44254*height), control2: CGPoint(x: 0.4473*width, y: 0.40962*height))
        path.addCurve(to: CGPoint(x: 0.49605*width, y: 0.44148*height), control1: CGPoint(x: 0.48931*width, y: 0.39105*height), control2: CGPoint(x: 0.49239*width, y: 0.41317*height))
        path.addCurve(to: CGPoint(x: 0.41062*width, y: 0.60401*height), control1: CGPoint(x: 0.43165*width, y: 0.46681*height), control2: CGPoint(x: 0.39209*width, y: 0.53723*height))
        path.addCurve(to: CGPoint(x: 0.4879*width, y: 0.65624*height), control1: CGPoint(x: 0.42576*width, y: 0.65854*height), control2: CGPoint(x: 0.47781*width, y: 0.66913*height))
        path.addCurve(to: CGPoint(x: 0.46029*width, y: 0.6056*height), control1: CGPoint(x: 0.49373*width, y: 0.64879*height), control2: CGPoint(x: 0.4731*width, y: 0.64401*height))
        path.addCurve(to: CGPoint(x: 0.47936*width, y: 0.52549*height), control1: CGPoint(x: 0.45109*width, y: 0.578*height), control2: CGPoint(x: 0.45391*width, y: 0.54615*height))
        path.addCurve(to: CGPoint(x: 0.50469*width, y: 0.51027*height), control1: CGPoint(x: 0.48717*width, y: 0.51913*height), control2: CGPoint(x: 0.49572*width, y: 0.51408*height))
        path.addCurve(to: CGPoint(x: 0.53392*width, y: 0.75203*height), control1: CGPoint(x: 0.5145*width, y: 0.59014*height), control2: CGPoint(x: 0.52583*width, y: 0.68654*height))
        path.addCurve(to: CGPoint(x: 0.43004*width, y: 0.73543*height), control1: CGPoint(x: 0.50165*width, y: 0.75752*height), control2: CGPoint(x: 0.46508*width, y: 0.75436*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.62412*width, y: 0.70363*height))
        path.addCurve(to: CGPoint(x: 0.57508*width, y: 0.7396*height), control1: CGPoint(x: 0.61446*width, y: 0.71668*height), control2: CGPoint(x: 0.59701*width, y: 0.72988*height))
        path.addCurve(to: CGPoint(x: 0.5453*width, y: 0.50229*height), control1: CGPoint(x: 0.56697*width, y: 0.67344*height), control2: CGPoint(x: 0.55609*width, y: 0.58754*height))
        path.addCurve(to: CGPoint(x: 0.61299*width, y: 0.52706*height), control1: CGPoint(x: 0.5678*width, y: 0.50262*height), control2: CGPoint(x: 0.5912*width, y: 0.51044*height))
        path.addCurve(to: CGPoint(x: 0.62412*width, y: 0.70363*height), control1: CGPoint(x: 0.67344*width, y: 0.57318*height), control2: CGPoint(x: 0.65116*width, y: 0.66704*height))
        path.closeSubpath()
        return path.trimmedPath(from: 0, to: animationProgress)
    }
}

struct MusicStrokeAnimationView: View {
    @State private var animationProgress: CGFloat = 0
    let lineWidth: CGFloat
    let duration: CGFloat
    let delay: TimeInterval

    var body: some View {
        MusicIconShape(animationProgress: animationProgress)
            .stroke(Color.blue, lineWidth: lineWidth)
            .onAppear {
                withAnimation(.linear(duration: duration).delay(delay)) {
                    animationProgress = 1.0
                }
            }
    }
}

struct GradientMusicStrokeAnimationView: View {
    @State private var gradientAngle: Angle = .degrees(0)
    let lineWidth: CGFloat
    let duration: CGFloat
    let delay: TimeInterval

    init(lineWidth: CGFloat, duration: CGFloat, delay: TimeInterval = 0) {
        self.lineWidth = lineWidth
        self.duration = duration
        self.delay = delay
    }

    let colorfulGradient = Gradient(
        colors: [.red, .orange, .yellow, .green, .blue, .purple, .pink]
            .map({ (color: Color) in color.opacity(0.8) })
    )

    var body: some View {
        AngularGradient(
            gradient: colorfulGradient,
            center: .leading,
            angle: gradientAngle
        )
        .mask {
            MusicStrokeAnimationView(lineWidth: lineWidth, duration: duration, delay: delay)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                gradientAngle = .degrees(360)
            }
        }
    }
}

#Preview {
    GradientMusicStrokeAnimationView(lineWidth: 3, duration: 10)
        .frame(width: 400, height: 400)
        .padding()
}
