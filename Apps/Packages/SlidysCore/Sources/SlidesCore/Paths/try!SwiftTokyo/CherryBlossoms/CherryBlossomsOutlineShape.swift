//
//  Created by yugo.sugiyama on 2025/03/16
//  Copyright ©Sugiy All rights reserved.
//


import SwiftUI

public struct CherryBlossomsOutlineShape: Shape {
    public static let aspectRatio: CGFloat = 503 / 290
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.1183*width, y: 0.95664*height))
        path.addCurve(to: CGPoint(x: 0.00001*width, y: 0.71871*height), control1: CGPoint(x: 0.01393*width, y: 0.91354*height), control2: CGPoint(x: 0.00001*width, y: 0.71871*height))
        path.addCurve(to: CGPoint(x: 0.00001*width, y: 0.1825*height), control1: CGPoint(x: 0.00001*width, y: 0.71871*height), control2: CGPoint(x: 0.00101*width, y: 0.20836*height))
        path.addCurve(to: CGPoint(x: 0.07754*width, y: 0.24974*height), control1: CGPoint(x: -0.00099*width, y: 0.15664*height), control2: CGPoint(x: 0.07754*width, y: 0.24974*height))
        path.addCurve(to: CGPoint(x: 0.23659*width, y: 0.07733*height), control1: CGPoint(x: 0.07754*width, y: 0.24974*height), control2: CGPoint(x: 0.17752*width, y: 0.07733*height))
        path.addCurve(to: CGPoint(x: 0.3847*width, y: 0.13595*height), control1: CGPoint(x: 0.31015*width, y: 0.07733*height), control2: CGPoint(x: 0.3847*width, y: 0.13595*height))
        path.addCurve(to: CGPoint(x: 0.62625*width, y: 0.00319*height), control1: CGPoint(x: 0.3847*width, y: 0.13595*height), control2: CGPoint(x: 0.45925*width, y: -0.0244*height))
        path.addCurve(to: CGPoint(x: 0.81611*width, y: 0.19457*height), control1: CGPoint(x: 0.79325*width, y: 0.03078*height), control2: CGPoint(x: 0.81611*width, y: 0.19457*height))
        path.addCurve(to: CGPoint(x: 1.001*width, y: 0.38595*height), control1: CGPoint(x: 0.81611*width, y: 0.19457*height), control2: CGPoint(x: 0.99703*width, y: 0.19112*height))
        path.addCurve(to: CGPoint(x: 0.8678*width, y: 0.58078*height), control1: CGPoint(x: 1.00498*width, y: 0.58078*height), control2: CGPoint(x: 0.8678*width, y: 0.58078*height))
        path.addCurve(to: CGPoint(x: 0.79623*width, y: 0.78595*height), control1: CGPoint(x: 0.8678*width, y: 0.58078*height), control2: CGPoint(x: 0.91253*width, y: 0.65491*height))
        path.addCurve(to: CGPoint(x: 0.60935*width, y: 0.78595*height), control1: CGPoint(x: 0.67993*width, y: 0.91699*height), control2: CGPoint(x: 0.60935*width, y: 0.78595*height))
        path.addCurve(to: CGPoint(x: 0.44733*width, y: 0.99457*height), control1: CGPoint(x: 0.60935*width, y: 0.78595*height), control2: CGPoint(x: 0.60538*width, y: 0.94629*height))
        path.addCurve(to: CGPoint(x: 0.22764*width, y: 0.82043*height), control1: CGPoint(x: 0.28927*width, y: 1.04284*height), control2: CGPoint(x: 0.22764*width, y: 0.82043*height))
        path.addCurve(to: CGPoint(x: 0.1183*width, y: 0.95664*height), control1: CGPoint(x: 0.22764*width, y: 0.82043*height), control2: CGPoint(x: 0.22267*width, y: 0.99974*height))
        path.closeSubpath()
        return path
    }
}
