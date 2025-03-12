//
//  UhooiShape.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI

public struct UhooiShape: Shape {
    public static let aspectRatio: CGFloat = 411 / 405
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.19259*width, y: 0.25352*height))
        path.addLine(to: CGPoint(x: 0.20519*width, y: 0.25686*height))
        path.addCurve(to: CGPoint(x: 0.2274*width, y: 0.24656*height), control1: CGPoint(x: 0.21405*width, y: 0.2592*height), control2: CGPoint(x: 0.2233*width, y: 0.25491*height))
        path.addCurve(to: CGPoint(x: 0.24298*width, y: 0.23572*height), control1: CGPoint(x: 0.2304*width, y: 0.24044*height), control2: CGPoint(x: 0.2363*width, y: 0.23634*height))
        path.addLine(to: CGPoint(x: 0.24993*width, y: 0.23507*height))
        path.addCurve(to: CGPoint(x: 0.26491*width, y: 0.23958*height), control1: CGPoint(x: 0.2553*width, y: 0.23458*height), control2: CGPoint(x: 0.26066*width, y: 0.23619*height))
        path.addCurve(to: CGPoint(x: 0.29702*width, y: 0.23202*height), control1: CGPoint(x: 0.27553*width, y: 0.24805*height), control2: CGPoint(x: 0.29111*width, y: 0.24438*height))
        path.addLine(to: CGPoint(x: 0.3145*width, y: 0.19542*height))
        path.addCurve(to: CGPoint(x: 0.35291*width, y: 0.18928*height), control1: CGPoint(x: 0.32172*width, y: 0.1803*height), control2: CGPoint(x: 0.3415*width, y: 0.17714*height))
        path.addLine(to: CGPoint(x: 0.36994*width, y: 0.20739*height))
        path.addCurve(to: CGPoint(x: 0.40049*width, y: 0.21056*height), control1: CGPoint(x: 0.37798*width, y: 0.21594*height), control2: CGPoint(x: 0.39092*width, y: 0.21728*height))
        path.addLine(to: CGPoint(x: 0.42254*width, y: 0.19508*height))
        path.addCurve(to: CGPoint(x: 0.45099*width, y: 0.19628*height), control1: CGPoint(x: 0.43123*width, y: 0.18898*height), control2: CGPoint(x: 0.44282*width, y: 0.18947*height))
        path.addLine(to: CGPoint(x: 0.45248*width, y: 0.19752*height))
        path.addCurve(to: CGPoint(x: 0.47623*width, y: 0.20128*height), control1: CGPoint(x: 0.45914*width, y: 0.20308*height), control2: CGPoint(x: 0.46823*width, y: 0.20452*height))
        path.addLine(to: CGPoint(x: 0.51669*width, y: 0.18491*height))
        path.addCurve(to: CGPoint(x: 0.53791*width, y: 0.19961*height), control1: CGPoint(x: 0.52687*width, y: 0.1808*height), control2: CGPoint(x: 0.53791*width, y: 0.18844*height))
        path.addLine(to: CGPoint(x: 0.53791*width, y: 0.20009*height))
        path.addCurve(to: CGPoint(x: 0.54702*width, y: 0.21401*height), control1: CGPoint(x: 0.53791*width, y: 0.20618*height), control2: CGPoint(x: 0.54151*width, y: 0.21167*height))
        path.addCurve(to: CGPoint(x: 0.55739*width, y: 0.2144*height), control1: CGPoint(x: 0.55032*width, y: 0.21541*height), control2: CGPoint(x: 0.554*width, y: 0.21555*height))
        path.addLine(to: CGPoint(x: 0.59825*width, y: 0.20051*height))
        path.addCurve(to: CGPoint(x: 0.60574*width, y: 0.19928*height), control1: CGPoint(x: 0.60066*width, y: 0.19969*height), control2: CGPoint(x: 0.60319*width, y: 0.19928*height))
        path.addLine(to: CGPoint(x: 0.62678*width, y: 0.19928*height))
        path.addCurve(to: CGPoint(x: 0.65047*width, y: 0.22343*height), control1: CGPoint(x: 0.63986*width, y: 0.19928*height), control2: CGPoint(x: 0.65047*width, y: 0.21009*height))
        path.addLine(to: CGPoint(x: 0.65047*width, y: 0.23731*height))
        path.addCurve(to: CGPoint(x: 0.66226*width, y: 0.25819*height), control1: CGPoint(x: 0.65047*width, y: 0.24592*height), control2: CGPoint(x: 0.65496*width, y: 0.25387*height))
        path.addLine(to: CGPoint(x: 0.69644*width, y: 0.27845*height))
        path.addCurve(to: CGPoint(x: 0.70603*width, y: 0.27788*height), control1: CGPoint(x: 0.69946*width, y: 0.28024*height), control2: CGPoint(x: 0.70324*width, y: 0.28001*height))
        path.addCurve(to: CGPoint(x: 0.716*width, y: 0.27755*height), control1: CGPoint(x: 0.70895*width, y: 0.27564*height), control2: CGPoint(x: 0.71294*width, y: 0.27551*height))
        path.addLine(to: CGPoint(x: 0.76191*width, y: 0.3081*height))
        path.addCurve(to: CGPoint(x: 0.75887*width, y: 0.349*height), control1: CGPoint(x: 0.77693*width, y: 0.31809*height), control2: CGPoint(x: 0.77507*width, y: 0.34115*height))
        path.addCurve(to: CGPoint(x: 0.74665*width, y: 0.36489*height), control1: CGPoint(x: 0.7526*width, y: 0.35203*height), control2: CGPoint(x: 0.74801*width, y: 0.35795*height))
        path.addCurve(to: CGPoint(x: 0.7482*width, y: 0.37856*height), control1: CGPoint(x: 0.74575*width, y: 0.3695*height), control2: CGPoint(x: 0.74629*width, y: 0.37428*height))
        path.addLine(to: CGPoint(x: 0.76491*width, y: 0.41604*height))
        path.addCurve(to: CGPoint(x: 0.76072*width, y: 0.43052*height), control1: CGPoint(x: 0.76723*width, y: 0.42125*height), control2: CGPoint(x: 0.76545*width, y: 0.42742*height))
        path.addCurve(to: CGPoint(x: 0.7566*width, y: 0.44514*height), control1: CGPoint(x: 0.75594*width, y: 0.43365*height), control2: CGPoint(x: 0.75418*width, y: 0.43991*height))
        path.addLine(to: CGPoint(x: 0.78921*width, y: 0.51564*height))
        path.addCurve(to: CGPoint(x: 0.79147*width, y: 0.52594*height), control1: CGPoint(x: 0.7907*width, y: 0.51886*height), control2: CGPoint(x: 0.79147*width, y: 0.52238*height))
        path.addLine(to: CGPoint(x: 0.79147*width, y: 0.55676*height))
        path.addCurve(to: CGPoint(x: 0.76777*width, y: 0.58092*height), control1: CGPoint(x: 0.79147*width, y: 0.5701*height), control2: CGPoint(x: 0.78086*width, y: 0.58092*height))
        path.addLine(to: CGPoint(x: 0.74181*width, y: 0.58092*height))
        path.addCurve(to: CGPoint(x: 0.72275*width, y: 0.59071*height), control1: CGPoint(x: 0.73429*width, y: 0.58092*height), control2: CGPoint(x: 0.72722*width, y: 0.58455*height))
        path.addLine(to: CGPoint(x: 0.67301*width, y: 0.65932*height))
        path.addCurve(to: CGPoint(x: 0.66397*width, y: 0.66685*height), control1: CGPoint(x: 0.67066*width, y: 0.66256*height), control2: CGPoint(x: 0.66755*width, y: 0.66514*height))
        path.addLine(to: CGPoint(x: 0.64077*width, y: 0.67788*height))
        path.addCurve(to: CGPoint(x: 0.63015*width, y: 0.68791*height), control1: CGPoint(x: 0.6363*width, y: 0.68001*height), control2: CGPoint(x: 0.63258*width, y: 0.68352*height))
        path.addLine(to: CGPoint(x: 0.60147*width, y: 0.73978*height))
        path.addCurve(to: CGPoint(x: 0.58978*width, y: 0.74272*height), control1: CGPoint(x: 0.59913*width, y: 0.74401*height), control2: CGPoint(x: 0.59378*width, y: 0.74536*height))
        path.addCurve(to: CGPoint(x: 0.57701*width, y: 0.74979*height), control1: CGPoint(x: 0.58427*width, y: 0.73909*height), control2: CGPoint(x: 0.57701*width, y: 0.74311*height))
        path.addLine(to: CGPoint(x: 0.57701*width, y: 0.75487*height))
        path.addCurve(to: CGPoint(x: 0.57497*width, y: 0.76137*height), control1: CGPoint(x: 0.57701*width, y: 0.7572*height), control2: CGPoint(x: 0.5763*width, y: 0.75947*height))
        path.addLine(to: CGPoint(x: 0.56577*width, y: 0.77449*height))
        path.addCurve(to: CGPoint(x: 0.54858*width, y: 0.78019*height), control1: CGPoint(x: 0.56189*width, y: 0.78003*height), control2: CGPoint(x: 0.55492*width, y: 0.78235*height))
        path.addLine(to: CGPoint(x: 0.45261*width, y: 0.75*height))
        path.addLine(to: CGPoint(x: 0.43499*width, y: 0.74487*height))
        path.addCurve(to: CGPoint(x: 0.4206*width, y: 0.74532*height), control1: CGPoint(x: 0.43027*width, y: 0.74349*height), control2: CGPoint(x: 0.42523*width, y: 0.74365*height))
        path.addLine(to: CGPoint(x: 0.41435*width, y: 0.74757*height))
        path.addCurve(to: CGPoint(x: 0.40328*width, y: 0.75585*height), control1: CGPoint(x: 0.40994*width, y: 0.74915*height), control2: CGPoint(x: 0.40609*width, y: 0.75204*height))
        path.addLine(to: CGPoint(x: 0.40005*width, y: 0.76025*height))
        path.addCurve(to: CGPoint(x: 0.36343*width, y: 0.76186*height), control1: CGPoint(x: 0.39107*width, y: 0.77244*height), control2: CGPoint(x: 0.3734*width, y: 0.77322*height))
        path.addLine(to: CGPoint(x: 0.34635*width, y: 0.7424*height))
        path.addCurve(to: CGPoint(x: 0.33688*width, y: 0.73584*height), control1: CGPoint(x: 0.34377*width, y: 0.73946*height), control2: CGPoint(x: 0.34052*width, y: 0.73721*height))
        path.addLine(to: CGPoint(x: 0.31991*width, y: 0.72947*height))
        path.addLine(to: CGPoint(x: 0.31241*width, y: 0.72708*height))
        path.addCurve(to: CGPoint(x: 0.30095*width, y: 0.71118*height), control1: CGPoint(x: 0.30559*width, y: 0.72491*height), control2: CGPoint(x: 0.30095*width, y: 0.71847*height))
        path.addCurve(to: CGPoint(x: 0.2914*width, y: 0.69603*height), control1: CGPoint(x: 0.30095*width, y: 0.70466*height), control2: CGPoint(x: 0.29722*width, y: 0.69874*height))
        path.addLine(to: CGPoint(x: 0.26294*width, y: 0.68277*height))
        path.addCurve(to: CGPoint(x: 0.25569*width, y: 0.68088*height), control1: CGPoint(x: 0.26065*width, y: 0.68171*height), control2: CGPoint(x: 0.25819*width, y: 0.68107*height))
        path.addLine(to: CGPoint(x: 0.24992*width, y: 0.68046*height))
        path.addCurve(to: CGPoint(x: 0.23822*width, y: 0.64848*height), control1: CGPoint(x: 0.23419*width, y: 0.67932*height), control2: CGPoint(x: 0.22707*width, y: 0.65985*height))
        path.addCurve(to: CGPoint(x: 0.23593*width, y: 0.61997*height), control1: CGPoint(x: 0.24625*width, y: 0.64029*height), control2: CGPoint(x: 0.24516*width, y: 0.62671*height))
        path.addLine(to: CGPoint(x: 0.20182*width, y: 0.59504*height))
        path.addCurve(to: CGPoint(x: 0.1945*width, y: 0.57362*height), control1: CGPoint(x: 0.19518*width, y: 0.59019*height), control2: CGPoint(x: 0.19225*width, y: 0.58162*height))
        path.addCurve(to: CGPoint(x: 0.19771*width, y: 0.56709*height), control1: CGPoint(x: 0.19516*width, y: 0.57126*height), control2: CGPoint(x: 0.19625*width, y: 0.56905*height))
        path.addLine(to: CGPoint(x: 0.20054*width, y: 0.56331*height))
        path.addCurve(to: CGPoint(x: 0.19663*width, y: 0.52992*height), control1: CGPoint(x: 0.20829*width, y: 0.55293*height), control2: CGPoint(x: 0.20656*width, y: 0.53815*height))
        path.addLine(to: CGPoint(x: 0.17869*width, y: 0.51507*height))
        path.addCurve(to: CGPoint(x: 0.17405*width, y: 0.51206*height), control1: CGPoint(x: 0.17726*width, y: 0.51388*height), control2: CGPoint(x: 0.1757*width, y: 0.51287*height))
        path.addLine(to: CGPoint(x: 0.1592*width, y: 0.50475*height))
        path.addCurve(to: CGPoint(x: 0.15439*width, y: 0.48167*height), control1: CGPoint(x: 0.15058*width, y: 0.50051*height), control2: CGPoint(x: 0.14821*width, y: 0.48912*height))
        path.addCurve(to: CGPoint(x: 0.15586*width, y: 0.47955*height), control1: CGPoint(x: 0.15494*width, y: 0.48101*height), control2: CGPoint(x: 0.15543*width, y: 0.4803*height))
        path.addLine(to: CGPoint(x: 0.16053*width, y: 0.47138*height))
        path.addCurve(to: CGPoint(x: 0.16351*width, y: 0.46017*height), control1: CGPoint(x: 0.16248*width, y: 0.46798*height), control2: CGPoint(x: 0.16351*width, y: 0.46411*height))
        path.addCurve(to: CGPoint(x: 0.16299*width, y: 0.45535*height), control1: CGPoint(x: 0.16351*width, y: 0.45855*height), control2: CGPoint(x: 0.16333*width, y: 0.45693*height))
        path.addLine(to: CGPoint(x: 0.16198*width, y: 0.45071*height))
        path.addCurve(to: CGPoint(x: 0.16154*width, y: 0.44294*height), control1: CGPoint(x: 0.16142*width, y: 0.44816*height), control2: CGPoint(x: 0.16127*width, y: 0.44554*height))
        path.addLine(to: CGPoint(x: 0.16351*width, y: 0.42391*height))
        path.addLine(to: CGPoint(x: 0.16351*width, y: 0.41318*height))
        path.addCurve(to: CGPoint(x: 0.16584*width, y: 0.40386*height), control1: CGPoint(x: 0.16351*width, y: 0.40992*height), control2: CGPoint(x: 0.16431*width, y: 0.40671*height))
        path.addCurve(to: CGPoint(x: 0.16615*width, y: 0.38583*height), control1: CGPoint(x: 0.16883*width, y: 0.39826*height), control2: CGPoint(x: 0.16895*width, y: 0.39153*height))
        path.addLine(to: CGPoint(x: 0.15521*width, y: 0.36353*height))
        path.addLine(to: CGPoint(x: 0.13511*width, y: 0.32709*height))
        path.addCurve(to: CGPoint(x: 0.13314*width, y: 0.32245*height), control1: CGPoint(x: 0.1343*width, y: 0.32562*height), control2: CGPoint(x: 0.13364*width, y: 0.32407*height))
        path.addLine(to: CGPoint(x: 0.12467*width, y: 0.29482*height))
        path.addCurve(to: CGPoint(x: 0.12556*width, y: 0.27798*height), control1: CGPoint(x: 0.12297*width, y: 0.28928*height), control2: CGPoint(x: 0.12329*width, y: 0.2833*height))
        path.addLine(to: CGPoint(x: 0.1284*width, y: 0.27132*height))
        path.addCurve(to: CGPoint(x: 0.14757*width, y: 0.25694*height), control1: CGPoint(x: 0.13179*width, y: 0.26336*height), control2: CGPoint(x: 0.13911*width, y: 0.25787*height))
        path.addLine(to: CGPoint(x: 0.18408*width, y: 0.25289*height))
        path.addCurve(to: CGPoint(x: 0.19259*width, y: 0.25352*height), control1: CGPoint(x: 0.18693*width, y: 0.25258*height), control2: CGPoint(x: 0.18981*width, y: 0.25279*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.20024*width, y: 0.25845*height))
        path.addLine(to: CGPoint(x: 0.13076*width, y: 0.15763*height))
        path.addCurve(to: CGPoint(x: 0.13033*width, y: 0.15624*height), control1: CGPoint(x: 0.13048*width, y: 0.15722*height), control2: CGPoint(x: 0.13033*width, y: 0.15674*height))
        path.addLine(to: CGPoint(x: 0.13033*width, y: 0.08937*height))
        path.addLine(to: CGPoint(x: 0.13655*width, y: 0.03761*height))
        path.addCurve(to: CGPoint(x: 0.14098*width, y: 0.03674*height), control1: CGPoint(x: 0.13683*width, y: 0.03528*height), control2: CGPoint(x: 0.13987*width, y: 0.03468*height))
        path.addLine(to: CGPoint(x: 0.16934*width, y: 0.08921*height))
        path.addCurve(to: CGPoint(x: 0.16954*width, y: 0.08952*height), control1: CGPoint(x: 0.1694*width, y: 0.08932*height), control2: CGPoint(x: 0.16947*width, y: 0.08942*height))
        path.addLine(to: CGPoint(x: 0.20935*width, y: 0.14203*height))
        path.addCurve(to: CGPoint(x: 0.21027*width, y: 0.14276*height), control1: CGPoint(x: 0.20959*width, y: 0.14235*height), control2: CGPoint(x: 0.2099*width, y: 0.1426*height))
        path.addLine(to: CGPoint(x: 0.31161*width, y: 0.18841*height))
        path.move(to: CGPoint(x: 0.65403*width, y: 0.20894*height))
        path.addLine(to: CGPoint(x: 0.71522*width, y: 0.16815*height))
        path.addCurve(to: CGPoint(x: 0.71591*width, y: 0.16745*height), control1: CGPoint(x: 0.7155*width, y: 0.16797*height), control2: CGPoint(x: 0.71573*width, y: 0.16773*height))
        path.addLine(to: CGPoint(x: 0.74858*width, y: 0.11631*height))
        path.addCurve(to: CGPoint(x: 0.74891*width, y: 0.11552*height), control1: CGPoint(x: 0.74874*width, y: 0.11607*height), control2: CGPoint(x: 0.74885*width, y: 0.1158*height))
        path.addLine(to: CGPoint(x: 0.77119*width, y: 0.01445*height))
        path.addCurve(to: CGPoint(x: 0.77555*width, y: 0.01376*height), control1: CGPoint(x: 0.77166*width, y: 0.01231*height), control2: CGPoint(x: 0.77446*width, y: 0.01187*height))
        path.addLine(to: CGPoint(x: 0.83025*width, y: 0.10934*height))
        path.addCurve(to: CGPoint(x: 0.83057*width, y: 0.11056*height), control1: CGPoint(x: 0.83046*width, y: 0.10971*height), control2: CGPoint(x: 0.83057*width, y: 0.11013*height))
        path.addLine(to: CGPoint(x: 0.83057*width, y: 0.22139*height))
        path.addCurve(to: CGPoint(x: 0.83007*width, y: 0.22288*height), control1: CGPoint(x: 0.83057*width, y: 0.22193*height), control2: CGPoint(x: 0.83039*width, y: 0.22245*height))
        path.addLine(to: CGPoint(x: 0.76777*width, y: 0.30435*height))
        path.move(to: CGPoint(x: 0.77844*width, y: 0.47705*height))
        path.addLine(to: CGPoint(x: 0.94292*width, y: 0.41717*height))
        path.addCurve(to: CGPoint(x: 0.94448*width, y: 0.41517*height), control1: CGPoint(x: 0.94377*width, y: 0.41686*height), control2: CGPoint(x: 0.94438*width, y: 0.41609*height))
        path.addLine(to: CGPoint(x: 0.97275*width, y: 0.16425*height))
        path.move(to: CGPoint(x: 0.76777*width, y: 0.41063*height))
        path.addLine(to: CGPoint(x: 0.89094*width, y: 0.36041*height))
        path.addCurve(to: CGPoint(x: 0.89239*width, y: 0.35855*height), control1: CGPoint(x: 0.89171*width, y: 0.3601*height), control2: CGPoint(x: 0.89226*width, y: 0.35939*height))
        path.addLine(to: CGPoint(x: 0.92417*width, y: 0.15821*height))
        path.move(to: CGPoint(x: 0.98697*width, y: 0.13907*height))
        path.addCurve(to: CGPoint(x: 0.95261*width, y: 0.1741*height), control1: CGPoint(x: 0.98697*width, y: 0.15842*height), control2: CGPoint(x: 0.97158*width, y: 0.1741*height))
        path.addCurve(to: CGPoint(x: 0.91825*width, y: 0.13907*height), control1: CGPoint(x: 0.93363*width, y: 0.1741*height), control2: CGPoint(x: 0.91825*width, y: 0.15842*height))
        path.addCurve(to: CGPoint(x: 0.95261*width, y: 0.10405*height), control1: CGPoint(x: 0.91825*width, y: 0.11973*height), control2: CGPoint(x: 0.93363*width, y: 0.10405*height))
        path.addCurve(to: CGPoint(x: 0.98697*width, y: 0.13907*height), control1: CGPoint(x: 0.97158*width, y: 0.10405*height), control2: CGPoint(x: 0.98697*width, y: 0.11973*height))
        path.closeSubpath()
        path.addEllipse(in: CGRect(x: 0.01185*width, y: 0.46618*height, width: 0.06872*width, height: 0.07005*height))
        path.addEllipse(in: CGRect(x: 0.17062*width, y: 0.77053*height, width: 0.06161*width, height: 0.0628*height))
        path.addEllipse(in: CGRect(x: 0.1872*width, y: 0.91546*height, width: 0.07109*width, height: 0.07246*height))
        path.addEllipse(in: CGRect(x: 0.81991*width, y: 0.67391*height, width: 0.06398*width, height: 0.06522*height))
        path.addEllipse(in: CGRect(x: 0.73934*width, y: 0.90338*height, width: 0.07109*width, height: 0.07246*height))
        path.addEllipse(in: CGRect(x: 0.03791*width, y: 0.69565*height, width: 0.08531*width, height: 0.08696*height))
        path.addEllipse(in: CGRect(x: 0.87915*width, y: 0.35266*height, width: 0.06872*width, height: 0.07005*height))
        path.move(to: CGPoint(x: 0.16232*width, y: 0.38768*height))
        path.addLine(to: CGPoint(x: 0.03791*width, y: 0.46981*height))
        path.move(to: CGPoint(x: 0.15521*width, y: 0.48188*height))
        path.addLine(to: CGPoint(x: 0.08175*width, y: 0.50121*height))
        path.move(to: CGPoint(x: 0.02014*width, y: 0.52415*height))
        path.addLine(to: CGPoint(x: 0.05095*width, y: 0.70652*height))
        path.move(to: CGPoint(x: 0.07109*width, y: 0.53019*height))
        path.addLine(to: CGPoint(x: 0.09834*width, y: 0.69444*height))
        path.move(to: CGPoint(x: 0.25355*width, y: 0.68237*height))
        path.addLine(to: CGPoint(x: 0.18483*width, y: 0.77657*height))
        path.move(to: CGPoint(x: 0.29502*width, y: 0.71377*height))
        path.addLine(to: CGPoint(x: 0.22867*width, y: 0.79589*height))
        path.move(to: CGPoint(x: 0.17417*width, y: 0.81522*height))
        path.addLine(to: CGPoint(x: 0.18839*width, y: 0.93961*height))
        path.move(to: CGPoint(x: 0.22867*width, y: 0.81522*height))
        path.addLine(to: CGPoint(x: 0.24645*width, y: 0.92512*height))
        path.move(to: CGPoint(x: 0.67299*width, y: 0.66425*height))
        path.addLine(to: CGPoint(x: 0.81635*width, y: 0.70894*height))
        path.move(to: CGPoint(x: 0.70498*width, y: 0.6256*height))
        path.addLine(to: CGPoint(x: 0.85545*width, y: 0.67391*height))
        path.move(to: CGPoint(x: 0.81991*width, y: 0.72464*height))
        path.addLine(to: CGPoint(x: 0.74882*width, y: 0.91546*height))
        path.move(to: CGPoint(x: 0.88033*width, y: 0.7186*height))
        path.addLine(to: CGPoint(x: 0.80806*width, y: 0.92633*height))
        path.move(to: CGPoint(x: 0.27488*width, y: 0.35024*height))
        path.addLine(to: CGPoint(x: 0.28555*width, y: 0.33333*height))
        path.addLine(to: CGPoint(x: 0.31635*width, y: 0.35024*height))
        path.addLine(to: CGPoint(x: 0.3436*width, y: 0.36232*height))
        path.addLine(to: CGPoint(x: 0.38152*width, y: 0.37077*height))
        path.addLine(to: CGPoint(x: 0.42417*width, y: 0.38285*height))
        path.addLine(to: CGPoint(x: 0.39336*width, y: 0.41304*height))
        path.addLine(to: CGPoint(x: 0.3673*width, y: 0.42874*height))
        path.addLine(to: CGPoint(x: 0.34123*width, y: 0.4372*height))
        path.addLine(to: CGPoint(x: 0.31043*width, y: 0.4372*height))
        path.addLine(to: CGPoint(x: 0.28555*width, y: 0.42512*height))
        path.addLine(to: CGPoint(x: 0.27488*width, y: 0.40459*height))
        path.addLine(to: CGPoint(x: 0.27014*width, y: 0.37923*height))
        path.addLine(to: CGPoint(x: 0.27488*width, y: 0.35024*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.58175*width, y: 0.34179*height))
        path.addLine(to: CGPoint(x: 0.62204*width, y: 0.32246*height))
        path.addLine(to: CGPoint(x: 0.63744*width, y: 0.34179*height))
        path.addLine(to: CGPoint(x: 0.63744*width, y: 0.37077*height))
        path.addLine(to: CGPoint(x: 0.62915*width, y: 0.39614*height))
        path.addLine(to: CGPoint(x: 0.61493*width, y: 0.41304*height))
        path.addLine(to: CGPoint(x: 0.58649*width, y: 0.43116*height))
        path.addLine(to: CGPoint(x: 0.55806*width, y: 0.4372*height))
        path.addLine(to: CGPoint(x: 0.53555*width, y: 0.4372*height))
        path.addLine(to: CGPoint(x: 0.51659*width, y: 0.42874*height))
        path.addLine(to: CGPoint(x: 0.50592*width, y: 0.41667*height))
        path.addLine(to: CGPoint(x: 0.50118*width, y: 0.3913*height))
        path.addLine(to: CGPoint(x: 0.51303*width, y: 0.3756*height))
        path.addLine(to: CGPoint(x: 0.54384*width, y: 0.3587*height))
        path.addLine(to: CGPoint(x: 0.58175*width, y: 0.34179*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.38152*width, y: 0.53986*height))
        path.addLine(to: CGPoint(x: 0.41114*width, y: 0.53986*height))
        path.addLine(to: CGPoint(x: 0.42162*width, y: 0.53986*height))
        path.addCurve(to: CGPoint(x: 0.42198*width, y: 0.53983*height), control1: CGPoint(x: 0.42174*width, y: 0.53986*height), control2: CGPoint(x: 0.42186*width, y: 0.53985*height))
        path.addLine(to: CGPoint(x: 0.48437*width, y: 0.53023*height))
        path.addCurve(to: CGPoint(x: 0.48481*width, y: 0.53011*height), control1: CGPoint(x: 0.48452*width, y: 0.53021*height), control2: CGPoint(x: 0.48467*width, y: 0.53017*height))
        path.addLine(to: CGPoint(x: 0.56754*width, y: 0.5*height))
        path.move(to: CGPoint(x: 0.41114*width, y: 0.57005*height))
        path.addLine(to: CGPoint(x: 0.41607*width, y: 0.59671*height))
        path.addCurve(to: CGPoint(x: 0.41249*width, y: 0.59921*height), control1: CGPoint(x: 0.41645*width, y: 0.59877*height), control2: CGPoint(x: 0.41424*width, y: 0.60032*height))
        path.addLine(to: CGPoint(x: 0.38264*width, y: 0.58042*height))
        path.addCurve(to: CGPoint(x: 0.38152*width, y: 0.57836*height), control1: CGPoint(x: 0.38194*width, y: 0.57998*height), control2: CGPoint(x: 0.38152*width, y: 0.5792*height))
        path.addLine(to: CGPoint(x: 0.38152*width, y: 0.54227*height))
        path.move(to: CGPoint(x: 0.41114*width, y: 0.57005*height))
        path.addLine(to: CGPoint(x: 0.40995*width, y: 0.54469*height))
        path.move(to: CGPoint(x: 0.54384*width, y: 0.51087*height))
        path.addLine(to: CGPoint(x: 0.55781*width, y: 0.53579*height))
        path.addCurve(to: CGPoint(x: 0.55811*width, y: 0.53674*height), control1: CGPoint(x: 0.55797*width, y: 0.53608*height), control2: CGPoint(x: 0.55807*width, y: 0.53641*height))
        path.addLine(to: CGPoint(x: 0.56238*width, y: 0.58031*height))
        path.addCurve(to: CGPoint(x: 0.56615*width, y: 0.58201*height), control1: CGPoint(x: 0.56256*width, y: 0.58217*height), control2: CGPoint(x: 0.56467*width, y: 0.58313*height))
        path.addLine(to: CGPoint(x: 0.59369*width, y: 0.56122*height))
        path.addCurve(to: CGPoint(x: 0.59463*width, y: 0.559*height), control1: CGPoint(x: 0.59437*width, y: 0.5607*height), control2: CGPoint(x: 0.59473*width, y: 0.55986*height))
        path.addLine(to: CGPoint(x: 0.59016*width, y: 0.51908*height))
        path.addCurve(to: CGPoint(x: 0.58932*width, y: 0.5175*height), control1: CGPoint(x: 0.59009*width, y: 0.51846*height), control2: CGPoint(x: 0.58979*width, y: 0.51789*height))
        path.addLine(to: CGPoint(x: 0.56872*width, y: 0.5*height))
        path.addEllipse(in: CGRect(x: 0.30095*width, y: 0.40097*height, width: 0.04265*width, height: 0.0314*height))
        path.move(to: CGPoint(x: 0.12678*width, y: 0.10024*height))
        path.addLine(to: CGPoint(x: 0.17891*width, y: 0.10024*height))
        path.move(to: CGPoint(x: 0.12678*width, y: 0.1244*height))
        path.addLine(to: CGPoint(x: 0.20616*width, y: 0.13889*height))
        path.move(to: CGPoint(x: 0.13626*width, y: 0.16908*height))
        path.addLine(to: CGPoint(x: 0.22512*width, y: 0.15217*height))
        path.move(to: CGPoint(x: 0.1564*width, y: 0.19928*height))
        path.addLine(to: CGPoint(x: 0.2737*width, y: 0.17874*height))
        path.move(to: CGPoint(x: 0.75474*width, y: 0.10749*height))
        path.addLine(to: CGPoint(x: 0.77433*width, y: 0.10749*height))
        path.addCurve(to: CGPoint(x: 0.78569*width, y: 0.11613*height), control1: CGPoint(x: 0.77958*width, y: 0.10749*height), control2: CGPoint(x: 0.7842*width, y: 0.11101*height))
        path.addLine(to: CGPoint(x: 0.7912*width, y: 0.13509*height))
        path.addCurve(to: CGPoint(x: 0.79007*width, y: 0.14461*height), control1: CGPoint(x: 0.79213*width, y: 0.13829*height), control2: CGPoint(x: 0.79172*width, y: 0.14173*height))
        path.addLine(to: CGPoint(x: 0.77287*width, y: 0.17467*height))
        path.addCurve(to: CGPoint(x: 0.75834*width, y: 0.17984*height), control1: CGPoint(x: 0.76993*width, y: 0.1798*height), control2: CGPoint(x: 0.76377*width, y: 0.18199*height))
        path.addLine(to: CGPoint(x: 0.754*width, y: 0.17812*height))
        path.addCurve(to: CGPoint(x: 0.74645*width, y: 0.16686*height), control1: CGPoint(x: 0.74945*width, y: 0.17631*height), control2: CGPoint(x: 0.74645*width, y: 0.17184*height))
        path.addLine(to: CGPoint(x: 0.74645*width, y: 0.157*height))
        path.move(to: CGPoint(x: 0.6718*width, y: 0.19928*height))
        path.addLine(to: CGPoint(x: 0.70093*width, y: 0.20102*height))
        path.addCurve(to: CGPoint(x: 0.71209*width, y: 0.21308*height), control1: CGPoint(x: 0.70719*width, y: 0.2014*height), control2: CGPoint(x: 0.71209*width, y: 0.20668*height))
        path.addLine(to: CGPoint(x: 0.71209*width, y: 0.24396*height))
        path.move(to: CGPoint(x: 0.75474*width, y: 0.26329*height))
        path.addLine(to: CGPoint(x: 0.75474*width, y: 0.25772*height))
        path.addCurve(to: CGPoint(x: 0.76453*width, y: 0.24582*height), control1: CGPoint(x: 0.75474*width, y: 0.25186*height), control2: CGPoint(x: 0.75887*width, y: 0.24684*height))
        path.addLine(to: CGPoint(x: 0.76509*width, y: 0.24572*height))
        path.addCurve(to: CGPoint(x: 0.77488*width, y: 0.23383*height), control1: CGPoint(x: 0.77075*width, y: 0.2447*height), control2: CGPoint(x: 0.77488*width, y: 0.23969*height))
        path.addLine(to: CGPoint(x: 0.77488*width, y: 0.21964*height))
        path.addCurve(to: CGPoint(x: 0.78183*width, y: 0.21256*height), control1: CGPoint(x: 0.77488*width, y: 0.21573*height), control2: CGPoint(x: 0.77799*width, y: 0.21256*height))
        path.addLine(to: CGPoint(x: 0.78183*width, y: 0.21256*height))
        path.addCurve(to: CGPoint(x: 0.78838*width, y: 0.20786*height), control1: CGPoint(x: 0.78477*width, y: 0.21256*height), control2: CGPoint(x: 0.78739*width, y: 0.21068*height))
        path.addLine(to: CGPoint(x: 0.79024*width, y: 0.20255*height))
        path.addCurve(to: CGPoint(x: 0.79977*width, y: 0.19465*height), control1: CGPoint(x: 0.79172*width, y: 0.19831*height), control2: CGPoint(x: 0.7954*width, y: 0.19527*height))
        path.addLine(to: CGPoint(x: 0.82701*width, y: 0.19082*height))
        path.move(to: CGPoint(x: 0.79976*width, y: 0.06522*height))
        path.addLine(to: CGPoint(x: 0.78377*width, y: 0.05978*height))
        path.addLine(to: CGPoint(x: 0.76777*width, y: 0.05435*height))
        path.addEllipse(in: CGRect(x: 0.54294*width, y: 0.40089*height, width: 0.05687*width, height: 0.03623*height))
        return path
    }
}
