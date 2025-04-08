//
//  Created by yugo.sugiyama on 2025/04/07
//  Copyright ©Sugiy All rights reserved.
//

import SwiftUI

public struct MtFujiShape: Shape {
    public static let aspectRatio: CGFloat = 895 / 505

    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.31066*width, y: 0.33992*height))
        path.addLine(to: CGPoint(x: 0.3237*width, y: 0.33399*height))
        path.addLine(to: CGPoint(x: 0.33844*width, y: 0.32312*height))
        path.addLine(to: CGPoint(x: 0.34864*width, y: 0.30731*height))
        path.addLine(to: CGPoint(x: 0.35884*width, y: 0.28755*height))
        path.addLine(to: CGPoint(x: 0.36961*width, y: 0.26186*height))
        path.addLine(to: CGPoint(x: 0.37415*width, y: 0.24901*height))
        path.addLine(to: CGPoint(x: 0.37925*width, y: 0.24012*height))
        path.addLine(to: CGPoint(x: 0.38662*width, y: 0.23419*height))
        path.addLine(to: CGPoint(x: 0.39512*width, y: 0.23123*height))
        path.addLine(to: CGPoint(x: 0.40023*width, y: 0.23419*height))
        path.addLine(to: CGPoint(x: 0.40476*width, y: 0.24111*height))
        path.addLine(to: CGPoint(x: 0.4076*width, y: 0.24802*height))
        path.addLine(to: CGPoint(x: 0.40873*width, y: 0.25494*height))
        path.addLine(to: CGPoint(x: 0.40816*width, y: 0.26877*height))
        path.addLine(to: CGPoint(x: 0.4076*width, y: 0.28755*height))
        path.addLine(to: CGPoint(x: 0.40646*width, y: 0.31917*height))
        path.addLine(to: CGPoint(x: 0.40646*width, y: 0.33004*height))
        path.addLine(to: CGPoint(x: 0.40646*width, y: 0.34387*height))
        path.addLine(to: CGPoint(x: 0.4076*width, y: 0.35375*height))
        path.addLine(to: CGPoint(x: 0.40986*width, y: 0.36462*height))
        path.addLine(to: CGPoint(x: 0.41327*width, y: 0.37253*height))
        path.addLine(to: CGPoint(x: 0.41667*width, y: 0.37648*height))
        path.addLine(to: CGPoint(x: 0.42347*width, y: 0.37846*height))
        path.addLine(to: CGPoint(x: 0.43084*width, y: 0.37648*height))
        path.addLine(to: CGPoint(x: 0.44161*width, y: 0.36957*height))
        path.addLine(to: CGPoint(x: 0.44955*width, y: 0.35573*height))
        path.addLine(to: CGPoint(x: 0.45522*width, y: 0.34289*height))
        path.addLine(to: CGPoint(x: 0.46485*width, y: 0.31818*height))
        path.addLine(to: CGPoint(x: 0.47222*width, y: 0.29743*height))
        path.addLine(to: CGPoint(x: 0.48129*width, y: 0.27273*height))
        path.addLine(to: CGPoint(x: 0.48753*width, y: 0.26383*height))
        path.addLine(to: CGPoint(x: 0.4949*width, y: 0.25692*height))
        path.addLine(to: CGPoint(x: 0.5051*width, y: 0.25692*height))
        path.addLine(to: CGPoint(x: 0.51134*width, y: 0.26186*height))
        path.addLine(to: CGPoint(x: 0.51701*width, y: 0.27273*height))
        path.addLine(to: CGPoint(x: 0.52608*width, y: 0.2915*height))
        path.addLine(to: CGPoint(x: 0.53401*width, y: 0.30731*height))
        path.addLine(to: CGPoint(x: 0.54478*width, y: 0.33202*height))
        path.addLine(to: CGPoint(x: 0.55272*width, y: 0.3498*height))
        path.addLine(to: CGPoint(x: 0.56066*width, y: 0.36265*height))
        path.addLine(to: CGPoint(x: 0.56973*width, y: 0.37352*height))
        path.addLine(to: CGPoint(x: 0.57766*width, y: 0.37747*height))
        path.addLine(to: CGPoint(x: 0.589*width, y: 0.37648*height))
        path.addLine(to: CGPoint(x: 0.59694*width, y: 0.37055*height))
        path.addLine(to: CGPoint(x: 0.60091*width, y: 0.36067*height))
        path.addLine(to: CGPoint(x: 0.60261*width, y: 0.34783*height))
        path.addLine(to: CGPoint(x: 0.60317*width, y: 0.32411*height))
        path.addLine(to: CGPoint(x: 0.60261*width, y: 0.29249*height))
        path.addLine(to: CGPoint(x: 0.60544*width, y: 0.27964*height))
        path.addLine(to: CGPoint(x: 0.61111*width, y: 0.26482*height))
        path.addLine(to: CGPoint(x: 0.61735*width, y: 0.25988*height))
        path.addLine(to: CGPoint(x: 0.62415*width, y: 0.26285*height))
        path.addLine(to: CGPoint(x: 0.63379*width, y: 0.27767*height))
        path.addLine(to: CGPoint(x: 0.64342*width, y: 0.29447*height))
        path.addLine(to: CGPoint(x: 0.65703*width, y: 0.31423*height))
        path.addLine(to: CGPoint(x: 0.6695*width, y: 0.32312*height))
        path.addLine(to: CGPoint(x: 0.67971*width, y: 0.32871*height))
        path.move(to: CGPoint(x: 0.67971*width, y: 0.32871*height))
        path.addLine(to: CGPoint(x: 0.68424*width, y: 0.34387*height))
        path.addLine(to: CGPoint(x: 0.69501*width, y: 0.37846*height))
        path.addLine(to: CGPoint(x: 0.71315*width, y: 0.43577*height))
        path.addLine(to: CGPoint(x: 0.72449*width, y: 0.46937*height))
        path.addLine(to: CGPoint(x: 0.7398*width, y: 0.50988*height))
        path.addLine(to: CGPoint(x: 0.75227*width, y: 0.5415*height))
        path.addLine(to: CGPoint(x: 0.77098*width, y: 0.583*height))
        path.addLine(to: CGPoint(x: 0.78515*width, y: 0.6166*height))
        path.addLine(to: CGPoint(x: 0.80385*width, y: 0.65316*height))
        path.addLine(to: CGPoint(x: 0.82653*width, y: 0.69466*height))
        path.addLine(to: CGPoint(x: 0.85601*width, y: 0.74605*height))
        path.addLine(to: CGPoint(x: 0.87528*width, y: 0.77569*height))
        path.addLine(to: CGPoint(x: 0.89683*width, y: 0.81028*height))
        path.addLine(to: CGPoint(x: 0.92574*width, y: 0.84783*height))
        path.addLine(to: CGPoint(x: 0.94841*width, y: 0.87846*height))
        path.addLine(to: CGPoint(x: 0.96882*width, y: 0.90613*height))
        path.addLine(to: CGPoint(x: 0.99887*width, y: 0.93874*height))
        path.addLine(to: CGPoint(x: 0.99376*width, y: 0.94565*height))
        path.addLine(to: CGPoint(x: 0.97336*width, y: 0.95257*height))
        path.addLine(to: CGPoint(x: 0.94841*width, y: 0.95257*height))
        path.addLine(to: CGPoint(x: 0.92574*width, y: 0.94862*height))
        path.addLine(to: CGPoint(x: 0.90249*width, y: 0.94565*height))
        path.addLine(to: CGPoint(x: 0.87982*width, y: 0.94664*height))
        path.addLine(to: CGPoint(x: 0.85034*width, y: 0.95059*height))
        path.addLine(to: CGPoint(x: 0.81746*width, y: 0.96047*height))
        path.addLine(to: CGPoint(x: 0.79138*width, y: 0.96838*height))
        path.addLine(to: CGPoint(x: 0.75567*width, y: 0.98024*height))
        path.addLine(to: CGPoint(x: 0.72732*width, y: 0.98814*height))
        path.addLine(to: CGPoint(x: 0.69274*width, y: 0.99506*height))
        path.addLine(to: CGPoint(x: 0.6695*width, y: 0.99901*height))
        path.addLine(to: CGPoint(x: 0.63889*width, y: 0.99901*height))
        path.addLine(to: CGPoint(x: 0.61508*width, y: 0.99407*height))
        path.addLine(to: CGPoint(x: 0.56803*width, y: 0.98518*height))
        path.addLine(to: CGPoint(x: 0.54422*width, y: 0.98024*height))
        path.addLine(to: CGPoint(x: 0.52041*width, y: 0.9753*height))
        path.addLine(to: CGPoint(x: 0.4898*width, y: 0.9753*height))
        path.addLine(to: CGPoint(x: 0.46372*width, y: 0.9753*height))
        path.addLine(to: CGPoint(x: 0.4144*width, y: 0.98123*height))
        path.addLine(to: CGPoint(x: 0.33673*width, y: 0.98913*height))
        path.addLine(to: CGPoint(x: 0.28118*width, y: 0.98518*height))
        path.addLine(to: CGPoint(x: 0.2517*width, y: 0.97826*height))
        path.addLine(to: CGPoint(x: 0.22392*width, y: 0.96542*height))
        path.addLine(to: CGPoint(x: 0.19444*width, y: 0.95158*height))
        path.addLine(to: CGPoint(x: 0.16837*width, y: 0.94466*height))
        path.addLine(to: CGPoint(x: 0.14512*width, y: 0.93972*height))
        path.addLine(to: CGPoint(x: 0.11621*width, y: 0.94466*height))
        path.addLine(to: CGPoint(x: 0.08844*width, y: 0.94466*height))
        path.addLine(to: CGPoint(x: 0.05329*width, y: 0.94466*height))
        path.addLine(to: CGPoint(x: 0.02551*width, y: 0.94466*height))
        path.addLine(to: CGPoint(x: 0.0017*width, y: 0.93972*height))
        path.addLine(to: CGPoint(x: 0.02154*width, y: 0.90909*height))
        path.addLine(to: CGPoint(x: 0.06689*width, y: 0.85573*height))
        path.addLine(to: CGPoint(x: 0.12812*width, y: 0.76186*height))
        path.addLine(to: CGPoint(x: 0.18707*width, y: 0.65217*height))
        path.addLine(to: CGPoint(x: 0.22279*width, y: 0.58202*height))
        path.addLine(to: CGPoint(x: 0.26814*width, y: 0.4753*height))
        path.addLine(to: CGPoint(x: 0.29819*width, y: 0.37945*height))
        path.addLine(to: CGPoint(x: 0.33107*width, y: 0.2668*height))
        path.addLine(to: CGPoint(x: 0.35601*width, y: 0.16996*height))
        path.addLine(to: CGPoint(x: 0.37302*width, y: 0.10277*height))
        path.addLine(to: CGPoint(x: 0.38322*width, y: 0.05336*height))
        path.addLine(to: CGPoint(x: 0.39626*width, y: 0.00099*height))
        path.addLine(to: CGPoint(x: 0.60034*width, y: 0.00099*height))
        path.addLine(to: CGPoint(x: 0.61111*width, y: 0.05731*height))
        path.addLine(to: CGPoint(x: 0.62358*width, y: 0.11364*height))
        path.addLine(to: CGPoint(x: 0.63832*width, y: 0.18182*height))
        path.addLine(to: CGPoint(x: 0.65646*width, y: 0.25099*height))
        path.addLine(to: CGPoint(x: 0.67971*width, y: 0.32871*height))
        path.closeSubpath()
        return path
    }
}
