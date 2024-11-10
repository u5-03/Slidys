//
//  PeanutsShape.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI

struct PeanutsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.15525*width, y: 0.42885*height))
        path.addLine(to: CGPoint(x: 0.23516*width, y: 0.84585*height))
        path.move(to: CGPoint(x: 0.28995*width, y: 0.35178*height))
        path.addLine(to: CGPoint(x: 0.379*width, y: 0.71937*height))
        path.move(to: CGPoint(x: 0.47603*width, y: 0.37352*height))
        path.addLine(to: CGPoint(x: 0.5274*width, y: 0.62055*height))
        path.move(to: CGPoint(x: 0.60731*width, y: 0.32213*height))
        path.addLine(to: CGPoint(x: 0.67922*width, y: 0.59091*height))
        path.move(to: CGPoint(x: 0.73402*width, y: 0.08103*height))
        path.addLine(to: CGPoint(x: 0.84817*width, y: 0.59091*height))
        path.move(to: CGPoint(x: 0.10274*width, y: 0.48419*height))
        path.addLine(to: CGPoint(x: 0.30479*width, y: 0.35178*height))
        path.move(to: CGPoint(x: 0.11644*width, y: 0.65415*height))
        path.addLine(to: CGPoint(x: 0.86073*width, y: 0.23913*height))
        path.move(to: CGPoint(x: 0.15525*width, y: 0.84585*height))
        path.addLine(to: CGPoint(x: 0.89726*width, y: 0.37352*height))
        path.move(to: CGPoint(x: 0.64041*width, y: 0.21739*height))
        path.addLine(to: CGPoint(x: 0.84817*width, y: 0.09881*height))
        path.move(to: CGPoint(x: 0.74087*width, y: 0.64229*height))
        path.addLine(to: CGPoint(x: 0.91553*width, y: 0.48419*height))
        path.move(to: CGPoint(x: 0.35616*width, y: 0.29644*height))
        path.addLine(to: CGPoint(x: 0.46363*width, y: 0.32164*height))
        path.addCurve(to: CGPoint(x: 0.46784*width, y: 0.32127*height), control1: CGPoint(x: 0.46503*width, y: 0.32197*height), control2: CGPoint(x: 0.46646*width, y: 0.32184*height))
        path.addLine(to: CGPoint(x: 0.52421*width, y: 0.29777*height))
        path.addCurve(to: CGPoint(x: 0.52969*width, y: 0.29239*height), control1: CGPoint(x: 0.52629*width, y: 0.2969*height), control2: CGPoint(x: 0.52819*width, y: 0.29504*height))
        path.addLine(to: CGPoint(x: 0.58147*width, y: 0.20089*height))
        path.addCurve(to: CGPoint(x: 0.58304*width, y: 0.19857*height), control1: CGPoint(x: 0.58195*width, y: 0.20003*height), control2: CGPoint(x: 0.58247*width, y: 0.19926*height))
        path.addLine(to: CGPoint(x: 0.67817*width, y: 0.08231*height))
        path.addCurve(to: CGPoint(x: 0.68042*width, y: 0.08018*height), control1: CGPoint(x: 0.67887*width, y: 0.08146*height), control2: CGPoint(x: 0.67962*width, y: 0.08074*height))
        path.addLine(to: CGPoint(x: 0.75953*width, y: 0.02389*height))
        path.addCurve(to: CGPoint(x: 0.76578*width, y: 0.02269*height), control1: CGPoint(x: 0.76151*width, y: 0.02249*height), control2: CGPoint(x: 0.76368*width, y: 0.02207*height))
        path.addLine(to: CGPoint(x: 0.87308*width, y: 0.05427*height))
        path.addCurve(to: CGPoint(x: 0.8793*width, y: 0.05989*height), control1: CGPoint(x: 0.87544*width, y: 0.05496*height), control2: CGPoint(x: 0.87762*width, y: 0.05693*height))
        path.addLine(to: CGPoint(x: 0.94349*width, y: 0.17287*height))
        path.addCurve(to: CGPoint(x: 0.94605*width, y: 0.17987*height), control1: CGPoint(x: 0.94462*width, y: 0.17486*height), control2: CGPoint(x: 0.9455*width, y: 0.17725*height))
        path.addLine(to: CGPoint(x: 0.98599*width, y: 0.36673*height))
        path.addCurve(to: CGPoint(x: 0.98602*width, y: 0.38032*height), control1: CGPoint(x: 0.98693*width, y: 0.37111*height), control2: CGPoint(x: 0.98694*width, y: 0.37593*height))
        path.addLine(to: CGPoint(x: 0.9553*width, y: 0.52704*height))
        path.addCurve(to: CGPoint(x: 0.95226*width, y: 0.53491*height), control1: CGPoint(x: 0.95467*width, y: 0.53005*height), control2: CGPoint(x: 0.95362*width, y: 0.53275*height))
        path.addLine(to: CGPoint(x: 0.87878*width, y: 0.65089*height))
        path.addCurve(to: CGPoint(x: 0.874*width, y: 0.65539*height), control1: CGPoint(x: 0.87742*width, y: 0.65303*height), control2: CGPoint(x: 0.87578*width, y: 0.65457*height))
        path.addLine(to: CGPoint(x: 0.73611*width, y: 0.71841*height))
        path.addCurve(to: CGPoint(x: 0.73187*width, y: 0.71893*height), control1: CGPoint(x: 0.73473*width, y: 0.71904*height), control2: CGPoint(x: 0.73329*width, y: 0.71922*height))
        path.addLine(to: CGPoint(x: 0.60731*width, y: 0.69368*height))
        path.addLine(to: CGPoint(x: 0.51978*width, y: 0.69368*height))
        path.addCurve(to: CGPoint(x: 0.51474*width, y: 0.6957*height), control1: CGPoint(x: 0.51803*width, y: 0.69368*height), control2: CGPoint(x: 0.51631*width, y: 0.69437*height))
        path.addLine(to: CGPoint(x: 0.45324*width, y: 0.748*height))
        path.addCurve(to: CGPoint(x: 0.45103*width, y: 0.75047*height), control1: CGPoint(x: 0.45245*width, y: 0.74867*height), control2: CGPoint(x: 0.45171*width, y: 0.7495*height))
        path.addLine(to: CGPoint(x: 0.35733*width, y: 0.88372*height))
        path.addCurve(to: CGPoint(x: 0.35479*width, y: 0.88645*height), control1: CGPoint(x: 0.35655*width, y: 0.88482*height), control2: CGPoint(x: 0.3557*width, y: 0.88574*height))
        path.addLine(to: CGPoint(x: 0.23854*width, y: 0.97758*height))
        path.addCurve(to: CGPoint(x: 0.23152*width, y: 0.97893*height), control1: CGPoint(x: 0.23634*width, y: 0.97931*height), control2: CGPoint(x: 0.23389*width, y: 0.97978*height))
        path.addLine(to: CGPoint(x: 0.10553*width, y: 0.93381*height))
        path.addCurve(to: CGPoint(x: 0.10055*width, y: 0.92966*height), control1: CGPoint(x: 0.1037*width, y: 0.93315*height), control2: CGPoint(x: 0.10199*width, y: 0.93172*height))
        path.addLine(to: CGPoint(x: 0.04503*width, y: 0.84987*height))
        path.addCurve(to: CGPoint(x: 0.0413*width, y: 0.83978*height), control1: CGPoint(x: 0.04321*width, y: 0.84725*height), control2: CGPoint(x: 0.04191*width, y: 0.84373*height))
        path.addLine(to: CGPoint(x: 0.0134*width, y: 0.65959*height))
        path.addCurve(to: CGPoint(x: 0.0135*width, y: 0.64875*height), control1: CGPoint(x: 0.01285*width, y: 0.65604*height), control2: CGPoint(x: 0.01288*width, y: 0.65228*height))
        path.addLine(to: CGPoint(x: 0.04126*width, y: 0.48977*height))
        path.addCurve(to: CGPoint(x: 0.04481*width, y: 0.48042*height), control1: CGPoint(x: 0.0419*width, y: 0.48613*height), control2: CGPoint(x: 0.04313*width, y: 0.48288*height))
        path.addLine(to: CGPoint(x: 0.13065*width, y: 0.35438*height))
        path.addCurve(to: CGPoint(x: 0.13464*width, y: 0.35058*height), control1: CGPoint(x: 0.13182*width, y: 0.35266*height), control2: CGPoint(x: 0.13317*width, y: 0.35137*height))
        path.addLine(to: CGPoint(x: 0.2335*width, y: 0.29733*height))
        path.addCurve(to: CGPoint(x: 0.23689*width, y: 0.29644*height), control1: CGPoint(x: 0.2346*width, y: 0.29674*height), control2: CGPoint(x: 0.23574*width, y: 0.29644*height))
        path.addLine(to: CGPoint(x: 0.35616*width, y: 0.29644*height))
        path.closeSubpath()
        return path
    }
}
