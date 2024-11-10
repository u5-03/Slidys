//
//  ChibaShape.swift
//  ChibaSwiftSlide
//
//  Created by Yugo Sugiyama on 2024/09/08.
//

import SwiftUI

struct ChibaShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.61053*width, y: 0.74932*height))
        path.addLine(to: CGPoint(x: 0.58596*width, y: 0.7726*height))
        path.addLine(to: CGPoint(x: 0.54386*width, y: 0.80822*height))
        path.addLine(to: CGPoint(x: 0.48772*width, y: 0.84795*height))
        path.addLine(to: CGPoint(x: 0.43504*width, y: 0.88112*height))
        path.addCurve(to: CGPoint(x: 0.43202*width, y: 0.88356*height), control1: CGPoint(x: 0.43391*width, y: 0.88183*height), control2: CGPoint(x: 0.43289*width, y: 0.88265*height))
        path.addLine(to: CGPoint(x: 0.41521*width, y: 0.90105*height))
        path.addCurve(to: CGPoint(x: 0.41179*width, y: 0.90791*height), control1: CGPoint(x: 0.41329*width, y: 0.90305*height), control2: CGPoint(x: 0.41211*width, y: 0.90542*height))
        path.addLine(to: CGPoint(x: 0.40715*width, y: 0.94415*height))
        path.addCurve(to: CGPoint(x: 0.40668*width, y: 0.94623*height), control1: CGPoint(x: 0.40706*width, y: 0.94485*height), control2: CGPoint(x: 0.40691*width, y: 0.94555*height))
        path.addLine(to: CGPoint(x: 0.39662*width, y: 0.97651*height))
        path.addCurve(to: CGPoint(x: 0.38816*width, y: 0.98504*height), control1: CGPoint(x: 0.39542*width, y: 0.98014*height), control2: CGPoint(x: 0.39236*width, y: 0.98322*height))
        path.addLine(to: CGPoint(x: 0.36713*width, y: 0.99417*height))
        path.addCurve(to: CGPoint(x: 0.35861*width, y: 0.99589*height), control1: CGPoint(x: 0.36453*width, y: 0.9953*height), control2: CGPoint(x: 0.36159*width, y: 0.99589*height))
        path.addLine(to: CGPoint(x: 0.3*width, y: 0.99589*height))
        path.addLine(to: CGPoint(x: 0.2561*width, y: 0.99344*height))
        path.addCurve(to: CGPoint(x: 0.24671*width, y: 0.99067*height), control1: CGPoint(x: 0.25269*width, y: 0.99325*height), control2: CGPoint(x: 0.24943*width, y: 0.99229*height))
        path.addLine(to: CGPoint(x: 0.2237*width, y: 0.97698*height))
        path.addCurve(to: CGPoint(x: 0.21756*width, y: 0.96206*height), control1: CGPoint(x: 0.21788*width, y: 0.97352*height), control2: CGPoint(x: 0.21546*width, y: 0.96753*height))
        path.addLine(to: CGPoint(x: 0.21756*width, y: 0.96206*height))
        path.addCurve(to: CGPoint(x: 0.22418*width, y: 0.95481*height), control1: CGPoint(x: 0.21868*width, y: 0.95915*height), control2: CGPoint(x: 0.22102*width, y: 0.95658*height))
        path.addLine(to: CGPoint(x: 0.2652*width, y: 0.93193*height))
        path.addCurve(to: CGPoint(x: 0.27034*width, y: 0.92744*height), control1: CGPoint(x: 0.26732*width, y: 0.93075*height), control2: CGPoint(x: 0.26908*width, y: 0.92921*height))
        path.addLine(to: CGPoint(x: 0.28376*width, y: 0.90858*height))
        path.addCurve(to: CGPoint(x: 0.28596*width, y: 0.90193*height), control1: CGPoint(x: 0.2852*width, y: 0.90655*height), control2: CGPoint(x: 0.28596*width, y: 0.90426*height))
        path.addLine(to: CGPoint(x: 0.28596*width, y: 0.87143*height))
        path.addCurve(to: CGPoint(x: 0.28442*width, y: 0.86581*height), control1: CGPoint(x: 0.28596*width, y: 0.8695*height), control2: CGPoint(x: 0.28544*width, y: 0.86758*height))
        path.addLine(to: CGPoint(x: 0.25439*width, y: 0.8137*height))
        path.addLine(to: CGPoint(x: 0.22456*width, y: 0.7726*height))
        path.addLine(to: CGPoint(x: 0.19598*width, y: 0.72404*height))
        path.addCurve(to: CGPoint(x: 0.19446*width, y: 0.7196*height), control1: CGPoint(x: 0.19516*width, y: 0.72263*height), control2: CGPoint(x: 0.19464*width, y: 0.72113*height))
        path.addLine(to: CGPoint(x: 0.18965*width, y: 0.67957*height))
        path.addCurve(to: CGPoint(x: 0.18971*width, y: 0.67659*height), control1: CGPoint(x: 0.18953*width, y: 0.67858*height), control2: CGPoint(x: 0.18955*width, y: 0.67758*height))
        path.addLine(to: CGPoint(x: 0.19803*width, y: 0.62463*height))
        path.addCurve(to: CGPoint(x: 0.1988*width, y: 0.622*height), control1: CGPoint(x: 0.19817*width, y: 0.62374*height), control2: CGPoint(x: 0.19843*width, y: 0.62286*height))
        path.addLine(to: CGPoint(x: 0.21511*width, y: 0.58379*height))
        path.addCurve(to: CGPoint(x: 0.21695*width, y: 0.58077*height), control1: CGPoint(x: 0.21556*width, y: 0.58273*height), control2: CGPoint(x: 0.21618*width, y: 0.58172*height))
        path.addLine(to: CGPoint(x: 0.25263*width, y: 0.53699*height))
        path.addLine(to: CGPoint(x: 0.30526*width, y: 0.48493*height))
        path.addLine(to: CGPoint(x: 0.34961*width, y: 0.44898*height))
        path.addCurve(to: CGPoint(x: 0.35185*width, y: 0.44673*height), control1: CGPoint(x: 0.35045*width, y: 0.44829*height), control2: CGPoint(x: 0.3512*width, y: 0.44754*height))
        path.addLine(to: CGPoint(x: 0.37453*width, y: 0.4184*height))
        path.addCurve(to: CGPoint(x: 0.37719*width, y: 0.41114*height), control1: CGPoint(x: 0.37627*width, y: 0.41622*height), control2: CGPoint(x: 0.37719*width, y: 0.41371*height))
        path.addLine(to: CGPoint(x: 0.37719*width, y: 0.38953*height))
        path.addCurve(to: CGPoint(x: 0.37159*width, y: 0.3795*height), control1: CGPoint(x: 0.37719*width, y: 0.38573*height), control2: CGPoint(x: 0.37516*width, y: 0.38209*height))
        path.addLine(to: CGPoint(x: 0.35665*width, y: 0.36867*height))
        path.addCurve(to: CGPoint(x: 0.3472*width, y: 0.36515*height), control1: CGPoint(x: 0.35404*width, y: 0.36677*height), control2: CGPoint(x: 0.35074*width, y: 0.36554*height))
        path.addLine(to: CGPoint(x: 0.30351*width, y: 0.36027*height))
        path.addLine(to: CGPoint(x: 0.24035*width, y: 0.34658*height))
        path.move(to: CGPoint(x: 0.7*width, y: 0.16301*height))
        path.addLine(to: CGPoint(x: 0.71404*width, y: 0.18356*height))
        path.addLine(to: CGPoint(x: 0.72376*width, y: 0.19442*height))
        path.addCurve(to: CGPoint(x: 0.73029*width, y: 0.19881*height), control1: CGPoint(x: 0.72544*width, y: 0.19628*height), control2: CGPoint(x: 0.72768*width, y: 0.19779*height))
        path.addLine(to: CGPoint(x: 0.75644*width, y: 0.20902*height))
        path.addCurve(to: CGPoint(x: 0.75946*width, y: 0.20994*height), control1: CGPoint(x: 0.75741*width, y: 0.2094*height), control2: CGPoint(x: 0.75842*width, y: 0.20971*height))
        path.addLine(to: CGPoint(x: 0.79238*width, y: 0.21728*height))
        path.addCurve(to: CGPoint(x: 0.79719*width, y: 0.21781*height), control1: CGPoint(x: 0.79394*width, y: 0.21763*height), control2: CGPoint(x: 0.79556*width, y: 0.21781*height))
        path.addLine(to: CGPoint(x: 0.8506*width, y: 0.21781*height))
        path.addCurve(to: CGPoint(x: 0.85461*width, y: 0.21744*height), control1: CGPoint(x: 0.85195*width, y: 0.21781*height), control2: CGPoint(x: 0.8533*width, y: 0.21769*height))
        path.addLine(to: CGPoint(x: 0.90962*width, y: 0.20734*height))
        path.addCurve(to: CGPoint(x: 0.91462*width, y: 0.20575*height), control1: CGPoint(x: 0.91138*width, y: 0.20701*height), control2: CGPoint(x: 0.91307*width, y: 0.20648*height))
        path.addLine(to: CGPoint(x: 0.97124*width, y: 0.17923*height))
        path.addCurve(to: CGPoint(x: 0.97554*width, y: 0.17639*height), control1: CGPoint(x: 0.97286*width, y: 0.17847*height), control2: CGPoint(x: 0.97431*width, y: 0.17751*height))
        path.addLine(to: CGPoint(x: 0.99008*width, y: 0.16315*height))
        path.addCurve(to: CGPoint(x: 0.99426*width, y: 0.15332*height), control1: CGPoint(x: 0.99306*width, y: 0.16043*height), control2: CGPoint(x: 0.99456*width, y: 0.1569*height))
        path.addLine(to: CGPoint(x: 0.99329*width, y: 0.142*height))
        path.addCurve(to: CGPoint(x: 0.99039*width, y: 0.13532*height), control1: CGPoint(x: 0.99309*width, y: 0.13961*height), control2: CGPoint(x: 0.99209*width, y: 0.13731*height))
        path.addLine(to: CGPoint(x: 0.98602*width, y: 0.1302*height))
        path.addCurve(to: CGPoint(x: 0.97629*width, y: 0.12464*height), control1: CGPoint(x: 0.98372*width, y: 0.1275*height), control2: CGPoint(x: 0.98027*width, y: 0.12553*height))
        path.addLine(to: CGPoint(x: 0.90351*width, y: 0.10822*height))
        path.addLine(to: CGPoint(x: 0.83684*width, y: 0.08767*height))
        path.addLine(to: CGPoint(x: 0.76667*width, y: 0.0589*height))
        path.addLine(to: CGPoint(x: 0.69445*width, y: 0.02874*height))
        path.addCurve(to: CGPoint(x: 0.68759*width, y: 0.02717*height), control1: CGPoint(x: 0.69232*width, y: 0.02785*height), control2: CGPoint(x: 0.68999*width, y: 0.02732*height))
        path.addLine(to: CGPoint(x: 0.62796*width, y: 0.02339*height))
        path.addCurve(to: CGPoint(x: 0.62467*width, y: 0.02342*height), control1: CGPoint(x: 0.62687*width, y: 0.02332*height), control2: CGPoint(x: 0.62576*width, y: 0.02333*height))
        path.addLine(to: CGPoint(x: 0.57915*width, y: 0.02723*height))
        path.addCurve(to: CGPoint(x: 0.57533*width, y: 0.0279*height), control1: CGPoint(x: 0.57785*width, y: 0.02734*height), control2: CGPoint(x: 0.57657*width, y: 0.02756*height))
        path.addLine(to: CGPoint(x: 0.51579*width, y: 0.04384*height))
        path.addLine(to: CGPoint(x: 0.43684*width, y: 0.0726*height))
        path.addLine(to: CGPoint(x: 0.36491*width, y: 0.10137*height))
        path.addLine(to: CGPoint(x: 0.3207*width, y: 0.11332*height))
        path.addCurve(to: CGPoint(x: 0.31784*width, y: 0.11389*height), control1: CGPoint(x: 0.31977*width, y: 0.11357*height), control2: CGPoint(x: 0.31881*width, y: 0.11376*height))
        path.addLine(to: CGPoint(x: 0.29069*width, y: 0.11742*height))
        path.addCurve(to: CGPoint(x: 0.28476*width, y: 0.1174*height), control1: CGPoint(x: 0.28872*width, y: 0.11768*height), control2: CGPoint(x: 0.28672*width, y: 0.11767*height))
        path.addLine(to: CGPoint(x: 0.25789*width, y: 0.1137*height))
        path.addLine(to: CGPoint(x: 0.2193*width, y: 0.10548*height))
        path.addLine(to: CGPoint(x: 0.18977*width, y: 0.09907*height))
        path.addCurve(to: CGPoint(x: 0.18586*width, y: 0.09782*height), control1: CGPoint(x: 0.18841*width, y: 0.09878*height), control2: CGPoint(x: 0.1871*width, y: 0.09836*height))
        path.addLine(to: CGPoint(x: 0.16175*width, y: 0.08722*height))
        path.addCurve(to: CGPoint(x: 0.15795*width, y: 0.08497*height), control1: CGPoint(x: 0.16036*width, y: 0.08661*height), control2: CGPoint(x: 0.15908*width, y: 0.08585*height))
        path.addLine(to: CGPoint(x: 0.13509*width, y: 0.06712*height))
        path.addLine(to: CGPoint(x: 0.1*width, y: 0.04384*height))
        path.addLine(to: CGPoint(x: 0.07529*width, y: 0.02325*height))
        path.addCurve(to: CGPoint(x: 0.07169*width, y: 0.02096*height), control1: CGPoint(x: 0.07422*width, y: 0.02237*height), control2: CGPoint(x: 0.07301*width, y: 0.02159*height))
        path.addLine(to: CGPoint(x: 0.05088*width, y: 0.01096*height))
        path.addLine(to: CGPoint(x: 0.04055*width, y: 0.00693*height))
        path.addCurve(to: CGPoint(x: 0.0327*width, y: 0.00548*height), control1: CGPoint(x: 0.03811*width, y: 0.00597*height), control2: CGPoint(x: 0.03542*width, y: 0.00548*height))
        path.addLine(to: CGPoint(x: 0.02636*width, y: 0.00548*height))
        path.addCurve(to: CGPoint(x: 0.01663*width, y: 0.00778*height), control1: CGPoint(x: 0.0229*width, y: 0.00548*height), control2: CGPoint(x: 0.01951*width, y: 0.00628*height))
        path.addLine(to: CGPoint(x: 0.01523*width, y: 0.00851*height))
        path.addCurve(to: CGPoint(x: 0.00854*width, y: 0.0151*height), control1: CGPoint(x: 0.01217*width, y: 0.0101*height), control2: CGPoint(x: 0.00983*width, y: 0.01241*height))
        path.addLine(to: CGPoint(x: 0.00678*width, y: 0.01876*height))
        path.addCurve(to: CGPoint(x: 0.0058*width, y: 0.02527*height), control1: CGPoint(x: 0.00578*width, y: 0.02083*height), control2: CGPoint(x: 0.00545*width, y: 0.02307*height))
        path.addLine(to: CGPoint(x: 0.00834*width, y: 0.04112*height))
        path.addCurve(to: CGPoint(x: 0.01051*width, y: 0.04621*height), control1: CGPoint(x: 0.00862*width, y: 0.04291*height), control2: CGPoint(x: 0.00936*width, y: 0.04464*height))
        path.addLine(to: CGPoint(x: 0.03684*width, y: 0.08219*height))
        path.addLine(to: CGPoint(x: 0.0807*width, y: 0.13151*height))
        path.addLine(to: CGPoint(x: 0.12013*width, y: 0.16871*height))
        path.addCurve(to: CGPoint(x: 0.12373*width, y: 0.17443*height), control1: CGPoint(x: 0.12189*width, y: 0.17037*height), control2: CGPoint(x: 0.12312*width, y: 0.17233*height))
        path.addLine(to: CGPoint(x: 0.1386*width, y: 0.22603*height))
        path.addLine(to: CGPoint(x: 0.1553*width, y: 0.27299*height))
        path.addCurve(to: CGPoint(x: 0.15796*width, y: 0.27732*height), control1: CGPoint(x: 0.15586*width, y: 0.27455*height), control2: CGPoint(x: 0.15676*width, y: 0.27601*height))
        path.addLine(to: CGPoint(x: 0.19124*width, y: 0.31347*height))
        path.addCurve(to: CGPoint(x: 0.20549*width, y: 0.31918*height), control1: CGPoint(x: 0.19454*width, y: 0.31705*height), control2: CGPoint(x: 0.19984*width, y: 0.31918*height))
        path.addLine(to: CGPoint(x: 0.22129*width, y: 0.31918*height))
        path.addCurve(to: CGPoint(x: 0.2243*width, y: 0.31898*height), control1: CGPoint(x: 0.2223*width, y: 0.31918*height), control2: CGPoint(x: 0.22331*width, y: 0.31911*height))
        path.addLine(to: CGPoint(x: 0.26109*width, y: 0.31398*height))
        path.addCurve(to: CGPoint(x: 0.26508*width, y: 0.31305*height), control1: CGPoint(x: 0.26246*width, y: 0.31379*height), control2: CGPoint(x: 0.2638*width, y: 0.31348*height))
        path.addLine(to: CGPoint(x: 0.29964*width, y: 0.30131*height))
        path.addCurve(to: CGPoint(x: 0.30619*width, y: 0.29746*height), control1: CGPoint(x: 0.30218*width, y: 0.30045*height), control2: CGPoint(x: 0.30443*width, y: 0.29913*height))
        path.addLine(to: CGPoint(x: 0.32807*width, y: 0.27671*height))
        path.move(to: CGPoint(x: 0.82281*width, y: 0.21918*height))
        path.addLine(to: CGPoint(x: 0.80351*width, y: 0.23699*height))
        path.addLine(to: CGPoint(x: 0.77719*width, y: 0.26301*height))
        path.addLine(to: CGPoint(x: 0.74035*width, y: 0.30137*height))
        path.addLine(to: CGPoint(x: 0.71851*width, y: 0.33154*height))
        path.addCurve(to: CGPoint(x: 0.71698*width, y: 0.33435*height), control1: CGPoint(x: 0.71787*width, y: 0.33243*height), control2: CGPoint(x: 0.71735*width, y: 0.33337*height))
        path.addLine(to: CGPoint(x: 0.70756*width, y: 0.35886*height))
        path.addCurve(to: CGPoint(x: 0.70687*width, y: 0.36175*height), control1: CGPoint(x: 0.7072*width, y: 0.3598*height), control2: CGPoint(x: 0.70697*width, y: 0.36077*height))
        path.addLine(to: CGPoint(x: 0.70351*width, y: 0.39589*height))
        path.addLine(to: CGPoint(x: 0.70526*width, y: 0.45616*height))
        path.addLine(to: CGPoint(x: 0.71404*width, y: 0.50411*height))
        path.addLine(to: CGPoint(x: 0.72982*width, y: 0.54932*height))
        path.addLine(to: CGPoint(x: 0.74211*width, y: 0.59452*height))
        path.addLine(to: CGPoint(x: 0.74726*width, y: 0.64549*height))
        path.addCurve(to: CGPoint(x: 0.74726*width, y: 0.64766*height), control1: CGPoint(x: 0.74733*width, y: 0.64621*height), control2: CGPoint(x: 0.74733*width, y: 0.64694*height))
        path.addLine(to: CGPoint(x: 0.74402*width, y: 0.67925*height))
        path.addCurve(to: CGPoint(x: 0.74324*width, y: 0.68233*height), control1: CGPoint(x: 0.74391*width, y: 0.68029*height), control2: CGPoint(x: 0.74365*width, y: 0.68133*height))
        path.addLine(to: CGPoint(x: 0.73138*width, y: 0.71127*height))
        path.addCurve(to: CGPoint(x: 0.7259*width, y: 0.71762*height), control1: CGPoint(x: 0.73036*width, y: 0.71375*height), control2: CGPoint(x: 0.72846*width, y: 0.71595*height))
        path.addLine(to: CGPoint(x: 0.70047*width, y: 0.73417*height))
        path.addCurve(to: CGPoint(x: 0.69554*width, y: 0.73643*height), control1: CGPoint(x: 0.699*width, y: 0.73513*height), control2: CGPoint(x: 0.69733*width, y: 0.73589*height))
        path.addLine(to: CGPoint(x: 0.65463*width, y: 0.74872*height))
        path.addCurve(to: CGPoint(x: 0.65051*width, y: 0.74952*height), control1: CGPoint(x: 0.6533*width, y: 0.74911*height), control2: CGPoint(x: 0.65192*width, y: 0.74938*height))
        path.addLine(to: CGPoint(x: 0.62841*width, y: 0.75168*height))
        path.addCurve(to: CGPoint(x: 0.62087*width, y: 0.75113*height), control1: CGPoint(x: 0.62588*width, y: 0.75193*height), control2: CGPoint(x: 0.6233*width, y: 0.75174*height))
        path.addLine(to: CGPoint(x: 0.58172*width, y: 0.7413*height))
        path.addCurve(to: CGPoint(x: 0.57205*width, y: 0.73531*height), control1: CGPoint(x: 0.57767*width, y: 0.74028*height), control2: CGPoint(x: 0.57423*width, y: 0.73816*height))
        path.addLine(to: CGPoint(x: 0.56741*width, y: 0.72928*height))
        path.addCurve(to: CGPoint(x: 0.56491*width, y: 0.72223*height), control1: CGPoint(x: 0.56578*width, y: 0.72715*height), control2: CGPoint(x: 0.56491*width, y: 0.72472*height))
        path.addLine(to: CGPoint(x: 0.56491*width, y: 0.7046*height))
        path.addCurve(to: CGPoint(x: 0.56676*width, y: 0.69848*height), control1: CGPoint(x: 0.56491*width, y: 0.70248*height), control2: CGPoint(x: 0.56555*width, y: 0.70038*height))
        path.addLine(to: CGPoint(x: 0.57592*width, y: 0.68418*height))
        path.addCurve(to: CGPoint(x: 0.57921*width, y: 0.68062*height), control1: CGPoint(x: 0.57676*width, y: 0.68286*height), control2: CGPoint(x: 0.57787*width, y: 0.68166*height))
        path.addLine(to: CGPoint(x: 0.59897*width, y: 0.66519*height))
        path.addCurve(to: CGPoint(x: 0.60085*width, y: 0.66346*height), control1: CGPoint(x: 0.59966*width, y: 0.66465*height), control2: CGPoint(x: 0.60028*width, y: 0.66407*height))
        path.addLine(to: CGPoint(x: 0.61428*width, y: 0.64878*height))
        path.addCurve(to: CGPoint(x: 0.61754*width, y: 0.64082*height), control1: CGPoint(x: 0.6164*width, y: 0.64645*height), control2: CGPoint(x: 0.61754*width, y: 0.64367*height))
        path.addLine(to: CGPoint(x: 0.61754*width, y: 0.59178*height))
        path.addLine(to: CGPoint(x: 0.61228*width, y: 0.55753*height))
        path.addLine(to: CGPoint(x: 0.60562*width, y: 0.53283*height))
        path.addCurve(to: CGPoint(x: 0.60458*width, y: 0.53026*height), control1: CGPoint(x: 0.60538*width, y: 0.53195*height), control2: CGPoint(x: 0.60504*width, y: 0.53109*height))
        path.addLine(to: CGPoint(x: 0.59474*width, y: 0.51233*height))
        path.addLine(to: CGPoint(x: 0.58596*width, y: 0.5*height))
        path.move(to: CGPoint(x: 0.24912*width, y: 0.31918*height))
        path.addLine(to: CGPoint(x: 0.24146*width, y: 0.33235*height))
        path.addCurve(to: CGPoint(x: 0.24002*width, y: 0.33632*height), control1: CGPoint(x: 0.24072*width, y: 0.33361*height), control2: CGPoint(x: 0.24024*width, y: 0.33495*height))
        path.addLine(to: CGPoint(x: 0.23684*width, y: 0.35616*height))
        path.addLine(to: CGPoint(x: 0.23684*width, y: 0.37397*height))
        path.addLine(to: CGPoint(x: 0.23684*width, y: 0.37548*height))
        path.addCurve(to: CGPoint(x: 0.22716*width, y: 0.3864*height), control1: CGPoint(x: 0.23684*width, y: 0.38034*height), control2: CGPoint(x: 0.23298*width, y: 0.38469*height))
        path.addLine(to: CGPoint(x: 0.22716*width, y: 0.3864*height))
        path.addCurve(to: CGPoint(x: 0.2183*width, y: 0.38679*height), control1: CGPoint(x: 0.22432*width, y: 0.38723*height), control2: CGPoint(x: 0.22123*width, y: 0.38736*height))
        path.addLine(to: CGPoint(x: 0.20647*width, y: 0.38448*height))
        path.addCurve(to: CGPoint(x: 0.19832*width, y: 0.38088*height), control1: CGPoint(x: 0.20338*width, y: 0.38388*height), control2: CGPoint(x: 0.20057*width, y: 0.38264*height))
        path.addLine(to: CGPoint(x: 0.1924*width, y: 0.37626*height))
        path.addCurve(to: CGPoint(x: 0.18816*width, y: 0.3709*height), control1: CGPoint(x: 0.19048*width, y: 0.37476*height), control2: CGPoint(x: 0.18903*width, y: 0.37292*height))
        path.addLine(to: CGPoint(x: 0.18511*width, y: 0.36375*height))
        path.addCurve(to: CGPoint(x: 0.18421*width, y: 0.35942*height), control1: CGPoint(x: 0.18451*width, y: 0.36236*height), control2: CGPoint(x: 0.18421*width, y: 0.36089*height))
        path.addLine(to: CGPoint(x: 0.18421*width, y: 0.35222*height))
        path.addCurve(to: CGPoint(x: 0.18572*width, y: 0.34666*height), control1: CGPoint(x: 0.18421*width, y: 0.3503*height), control2: CGPoint(x: 0.18473*width, y: 0.34841*height))
        path.addLine(to: CGPoint(x: 0.19019*width, y: 0.33882*height))
        path.addCurve(to: CGPoint(x: 0.1929*width, y: 0.33547*height), control1: CGPoint(x: 0.19088*width, y: 0.3376*height), control2: CGPoint(x: 0.19179*width, y: 0.33647*height))
        path.addLine(to: CGPoint(x: 0.2008*width, y: 0.32827*height))
        path.addCurve(to: CGPoint(x: 0.20289*width, y: 0.32666*height), control1: CGPoint(x: 0.20143*width, y: 0.32769*height), control2: CGPoint(x: 0.20213*width, y: 0.32715*height))
        path.addLine(to: CGPoint(x: 0.21228*width, y: 0.32055*height))
        path.move(to: CGPoint(x: 0.35439*width, y: 0.16712*height))
        path.addLine(to: CGPoint(x: 0.36198*width, y: 0.16119*height))
        path.addCurve(to: CGPoint(x: 0.36884*width, y: 0.15788*height), control1: CGPoint(x: 0.36391*width, y: 0.15969*height), control2: CGPoint(x: 0.36626*width, y: 0.15855*height))
        path.addLine(to: CGPoint(x: 0.37274*width, y: 0.15687*height))
        path.addCurve(to: CGPoint(x: 0.37828*width, y: 0.15616*height), control1: CGPoint(x: 0.37453*width, y: 0.1564*height), control2: CGPoint(x: 0.3764*width, y: 0.15616*height))
        path.addLine(to: CGPoint(x: 0.38182*width, y: 0.15616*height))
        path.addCurve(to: CGPoint(x: 0.38967*width, y: 0.15761*height), control1: CGPoint(x: 0.38455*width, y: 0.15616*height), control2: CGPoint(x: 0.38723*width, y: 0.15666*height))
        path.addLine(to: CGPoint(x: 0.39279*width, y: 0.15883*height))
        path.addCurve(to: CGPoint(x: 0.39898*width, y: 0.16286*height), control1: CGPoint(x: 0.39522*width, y: 0.15978*height), control2: CGPoint(x: 0.39734*width, y: 0.16116*height))
        path.addLine(to: CGPoint(x: 0.40175*width, y: 0.16575*height))
        path.addLine(to: CGPoint(x: 0.40452*width, y: 0.16935*height))
        path.addCurve(to: CGPoint(x: 0.40702*width, y: 0.1764*height), control1: CGPoint(x: 0.40615*width, y: 0.17148*height), control2: CGPoint(x: 0.40702*width, y: 0.17391*height))
        path.addLine(to: CGPoint(x: 0.40702*width, y: 0.17947*height))
        path.addCurve(to: CGPoint(x: 0.40668*width, y: 0.18215*height), control1: CGPoint(x: 0.40702*width, y: 0.18037*height), control2: CGPoint(x: 0.4069*width, y: 0.18127*height))
        path.addLine(to: CGPoint(x: 0.40586*width, y: 0.18534*height))
        path.addCurve(to: CGPoint(x: 0.4037*width, y: 0.18971*height), control1: CGPoint(x: 0.40546*width, y: 0.18688*height), control2: CGPoint(x: 0.40473*width, y: 0.18836*height))
        path.addLine(to: CGPoint(x: 0.40263*width, y: 0.1911*height))
        path.addCurve(to: CGPoint(x: 0.39543*width, y: 0.1963*height), control1: CGPoint(x: 0.40091*width, y: 0.19333*height), control2: CGPoint(x: 0.39841*width, y: 0.19514*height))
        path.addLine(to: CGPoint(x: 0.39183*width, y: 0.19771*height))
        path.addCurve(to: CGPoint(x: 0.38687*width, y: 0.19897*height), control1: CGPoint(x: 0.39027*width, y: 0.19832*height), control2: CGPoint(x: 0.3886*width, y: 0.19874*height))
        path.addLine(to: CGPoint(x: 0.38038*width, y: 0.19981*height))
        path.addCurve(to: CGPoint(x: 0.37749*width, y: 0.2*height), control1: CGPoint(x: 0.37943*width, y: 0.19994*height), control2: CGPoint(x: 0.37846*width, y: 0.2*height))
        path.addLine(to: CGPoint(x: 0.36667*width, y: 0.2*height))
        path.move(to: CGPoint(x: 0.3614*width, y: 0.14384*height))
        path.addLine(to: CGPoint(x: 0.36877*width, y: 0.13713*height))
        path.addCurve(to: CGPoint(x: 0.37654*width, y: 0.13305*height), control1: CGPoint(x: 0.37084*width, y: 0.13524*height), control2: CGPoint(x: 0.37352*width, y: 0.13383*height))
        path.addLine(to: CGPoint(x: 0.38217*width, y: 0.13158*height))
        path.addCurve(to: CGPoint(x: 0.39327*width, y: 0.13158*height), control1: CGPoint(x: 0.38577*width, y: 0.13064*height), control2: CGPoint(x: 0.38967*width, y: 0.13064*height))
        path.addLine(to: CGPoint(x: 0.40037*width, y: 0.13343*height))
        path.addCurve(to: CGPoint(x: 0.40605*width, y: 0.1359*height), control1: CGPoint(x: 0.40244*width, y: 0.13397*height), control2: CGPoint(x: 0.40437*width, y: 0.13481*height))
        path.addLine(to: CGPoint(x: 0.41404*width, y: 0.1411*height))
        path.addLine(to: CGPoint(x: 0.42281*width, y: 0.14795*height))
        path.addLine(to: CGPoint(x: 0.42469*width, y: 0.14941*height))
        path.addCurve(to: CGPoint(x: 0.42982*width, y: 0.1591*height), control1: CGPoint(x: 0.42798*width, y: 0.15198*height), control2: CGPoint(x: 0.42982*width, y: 0.15547*height))
        path.addLine(to: CGPoint(x: 0.42982*width, y: 0.16712*height))
        path.addLine(to: CGPoint(x: 0.42982*width, y: 0.17808*height))
        path.addLine(to: CGPoint(x: 0.42982*width, y: 0.18519*height))
        path.addCurve(to: CGPoint(x: 0.42871*width, y: 0.19*height), control1: CGPoint(x: 0.42982*width, y: 0.18683*height), control2: CGPoint(x: 0.42945*width, y: 0.18846*height))
        path.addLine(to: CGPoint(x: 0.42545*width, y: 0.19679*height))
        path.addCurve(to: CGPoint(x: 0.42305*width, y: 0.2002*height), control1: CGPoint(x: 0.42486*width, y: 0.19801*height), control2: CGPoint(x: 0.42405*width, y: 0.19916*height))
        path.addLine(to: CGPoint(x: 0.41691*width, y: 0.2066*height))
        path.addCurve(to: CGPoint(x: 0.40962*width, y: 0.21103*height), control1: CGPoint(x: 0.41503*width, y: 0.20856*height), control2: CGPoint(x: 0.41251*width, y: 0.21009*height))
        path.addLine(to: CGPoint(x: 0.39877*width, y: 0.21456*height))
        path.addCurve(to: CGPoint(x: 0.38698*width, y: 0.21503*height), control1: CGPoint(x: 0.39503*width, y: 0.21577*height), control2: CGPoint(x: 0.39086*width, y: 0.21594*height))
        path.addLine(to: CGPoint(x: 0.37843*width, y: 0.21303*height))
        path.addCurve(to: CGPoint(x: 0.37294*width, y: 0.21087*height), control1: CGPoint(x: 0.37645*width, y: 0.21257*height), control2: CGPoint(x: 0.37459*width, y: 0.21183*height))
        path.addLine(to: CGPoint(x: 0.36515*width, y: 0.20631*height))
        path.addCurve(to: CGPoint(x: 0.35956*width, y: 0.20074*height), control1: CGPoint(x: 0.3627*width, y: 0.20487*height), control2: CGPoint(x: 0.36076*width, y: 0.20295*height))
        path.addLine(to: CGPoint(x: 0.35614*width, y: 0.19452*height))
        path.addLine(to: CGPoint(x: 0.35178*width, y: 0.1843*height))
        path.addCurve(to: CGPoint(x: 0.35088*width, y: 0.17997*height), control1: CGPoint(x: 0.35118*width, y: 0.1829*height), control2: CGPoint(x: 0.35088*width, y: 0.18144*height))
        path.addLine(to: CGPoint(x: 0.35088*width, y: 0.16712*height))
        path.addLine(to: CGPoint(x: 0.35088*width, y: 0.15849*height))
        path.addCurve(to: CGPoint(x: 0.3551*width, y: 0.14958*height), control1: CGPoint(x: 0.35088*width, y: 0.15522*height), control2: CGPoint(x: 0.35238*width, y: 0.15206*height))
        path.addLine(to: CGPoint(x: 0.3614*width, y: 0.14384*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.09649*width, y: 0.14521*height))
        path.addLine(to: CGPoint(x: 0.12281*width, y: 0.12877*height))
        path.addLine(to: CGPoint(x: 0.14386*width, y: 0.10959*height))
        path.addLine(to: CGPoint(x: 0.1614*width, y: 0.09041*height))
        return path
    }
}
