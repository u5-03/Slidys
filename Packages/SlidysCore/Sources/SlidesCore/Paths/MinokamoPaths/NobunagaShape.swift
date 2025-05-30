//
//  Nobunaga.swift
//  SlidysCore
//
//  Created by yugo.sugiyama on 2025/01/23.
//

import SwiftUI

public struct NobunagaShape: Shape {
    public static let aspectRatio: CGFloat = 1015 / 1192
    public init() {}

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.56041*width, y: 0.58787*height))
        path.addLine(to: CGPoint(x: 0.53782*width, y: 0.64393*height))
        path.addLine(to: CGPoint(x: 0.50982*width, y: 0.70335*height))
        path.addLine(to: CGPoint(x: 0.46562*width, y: 0.80042*height))
        path.addLine(to: CGPoint(x: 0.40373*width, y: 0.91883*height))
        path.addLine(to: CGPoint(x: 0.38212*width, y: 0.94979*height))
        path.addLine(to: CGPoint(x: 0.37328*width, y: 0.9272*height))
        path.addLine(to: CGPoint(x: 0.40373*width, y: 0.87238*height))
        path.addLine(to: CGPoint(x: 0.42534*width, y: 0.82845*height))
        path.addLine(to: CGPoint(x: 0.45825*width, y: 0.77657*height))
        path.addLine(to: CGPoint(x: 0.43517*width, y: 0.72343*height))
        path.addLine(to: CGPoint(x: 0.41896*width, y: 0.68787*height))
        path.addLine(to: CGPoint(x: 0.40815*width, y: 0.65732*height))
        path.addLine(to: CGPoint(x: 0.40029*width, y: 0.63054*height))
        path.addLine(to: CGPoint(x: 0.40029*width, y: 0.62008*height))
        path.addLine(to: CGPoint(x: 0.37033*width, y: 0.60837*height))
        path.addLine(to: CGPoint(x: 0.3502*width, y: 0.60293*height))
        path.move(to: CGPoint(x: 0.3502*width, y: 0.60293*height))
        path.addLine(to: CGPoint(x: 0.3502*width, y: 0.64017*height))
        path.addLine(to: CGPoint(x: 0.3502*width, y: 0.67406*height))
        path.addLine(to: CGPoint(x: 0.35265*width, y: 0.74854*height))
        path.addLine(to: CGPoint(x: 0.35707*width, y: 0.79456*height))
        path.addLine(to: CGPoint(x: 0.36346*width, y: 0.86151*height))
        path.addLine(to: CGPoint(x: 0.36935*width, y: 0.9113*height))
        path.addLine(to: CGPoint(x: 0.38605*width, y: 0.99707*height))
        path.addLine(to: CGPoint(x: 0.30894*width, y: 0.99707*height))
        path.addLine(to: CGPoint(x: 0.26375*width, y: 0.99707*height))
        path.addLine(to: CGPoint(x: 0.2554*width, y: 0.9272*height))
        path.addLine(to: CGPoint(x: 0.24116*width, y: 0.89247*height))
        path.addLine(to: CGPoint(x: 0.17092*width, y: 0.78619*height))
        path.addLine(to: CGPoint(x: 0.1336*width, y: 0.73891*height))
        path.addLine(to: CGPoint(x: 0.10069*width, y: 0.69749*height))
        path.addLine(to: CGPoint(x: 0.06827*width, y: 0.6523*height))
        path.addLine(to: CGPoint(x: 0.04028*width, y: 0.6159*height))
        path.addLine(to: CGPoint(x: 0.04028*width, y: 0.60293*height))
        path.addLine(to: CGPoint(x: 0.04862*width, y: 0.59665*height))
        path.addLine(to: CGPoint(x: 0.08055*width, y: 0.58787*height))
        path.addLine(to: CGPoint(x: 0.1336*width, y: 0.57448*height))
        path.addLine(to: CGPoint(x: 0.20383*width, y: 0.56025*height))
        path.addLine(to: CGPoint(x: 0.25196*width, y: 0.5523*height))
        path.addLine(to: CGPoint(x: 0.27358*width, y: 0.5523*height))
        path.addLine(to: CGPoint(x: 0.28635*width, y: 0.56653*height))
        path.addLine(to: CGPoint(x: 0.29912*width, y: 0.57448*height))
        path.addLine(to: CGPoint(x: 0.32809*width, y: 0.59079*height))
        path.addLine(to: CGPoint(x: 0.34037*width, y: 0.59665*height))
        path.addLine(to: CGPoint(x: 0.3502*width, y: 0.60293*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.55943*width, y: 0.5887*height))
        path.addLine(to: CGPoint(x: 0.55943*width, y: 0.58285*height))
        path.addLine(to: CGPoint(x: 0.58988*width, y: 0.56569*height))
        path.move(to: CGPoint(x: 0.58988*width, y: 0.56569*height))
        path.addLine(to: CGPoint(x: 0.58546*width, y: 0.60209*height))
        path.addLine(to: CGPoint(x: 0.57809*width, y: 0.70167*height))
        path.addLine(to: CGPoint(x: 0.57318*width, y: 0.73891*height))
        path.addLine(to: CGPoint(x: 0.56532*width, y: 0.79372*height))
        path.addLine(to: CGPoint(x: 0.55501*width, y: 0.86151*height))
        path.addLine(to: CGPoint(x: 0.54322*width, y: 0.91548*height))
        path.addLine(to: CGPoint(x: 0.52898*width, y: 0.96904*height))
        path.addLine(to: CGPoint(x: 0.52308*width, y: 0.99414*height))
        path.addLine(to: CGPoint(x: 0.57318*width, y: 0.99749*height))
        path.addLine(to: CGPoint(x: 0.6331*width, y: 0.99749*height))
        path.addLine(to: CGPoint(x: 0.71071*width, y: 0.99749*height))
        path.addLine(to: CGPoint(x: 0.72741*width, y: 0.90544*height))
        path.addLine(to: CGPoint(x: 0.74853*width, y: 0.87113*height))
        path.addLine(to: CGPoint(x: 0.77652*width, y: 0.83347*height))
        path.addLine(to: CGPoint(x: 0.82318*width, y: 0.77699*height))
        path.addLine(to: CGPoint(x: 0.85069*width, y: 0.73891*height))
        path.addLine(to: CGPoint(x: 0.89194*width, y: 0.68745*height))
        path.addLine(to: CGPoint(x: 0.92829*width, y: 0.6477*height))
        path.addLine(to: CGPoint(x: 0.94843*width, y: 0.62762*height))
        path.addLine(to: CGPoint(x: 0.94843*width, y: 0.61464*height))
        path.addLine(to: CGPoint(x: 0.9391*width, y: 0.60753*height))
        path.addLine(to: CGPoint(x: 0.91798*width, y: 0.6*height))
        path.addLine(to: CGPoint(x: 0.8836*width, y: 0.59121*height))
        path.addLine(to: CGPoint(x: 0.84185*width, y: 0.57908*height))
        path.addLine(to: CGPoint(x: 0.79273*width, y: 0.56736*height))
        path.addLine(to: CGPoint(x: 0.75835*width, y: 0.55941*height))
        path.addLine(to: CGPoint(x: 0.73035*width, y: 0.55356*height))
        path.addLine(to: CGPoint(x: 0.70629*width, y: 0.54979*height))
        path.addLine(to: CGPoint(x: 0.67829*width, y: 0.54603*height))
        path.addLine(to: CGPoint(x: 0.64833*width, y: 0.5431*height))
        path.addLine(to: CGPoint(x: 0.62819*width, y: 0.54142*height))
        path.addLine(to: CGPoint(x: 0.62132*width, y: 0.54142*height))
        path.addLine(to: CGPoint(x: 0.60707*width, y: 0.55105*height))
        path.addLine(to: CGPoint(x: 0.58988*width, y: 0.56569*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.89489*width, y: 0.6841*height))
        path.addLine(to: CGPoint(x: 0.91257*width, y: 0.70711*height))
        path.addLine(to: CGPoint(x: 0.9332*width, y: 0.74184*height))
        path.addLine(to: CGPoint(x: 0.95383*width, y: 0.77824*height))
        path.addLine(to: CGPoint(x: 0.972*width, y: 0.81381*height))
        path.addLine(to: CGPoint(x: 0.98428*width, y: 0.85063*height))
        path.addLine(to: CGPoint(x: 0.99509*width, y: 0.88787*height))
        path.addLine(to: CGPoint(x: 0.99853*width, y: 0.91799*height))
        path.addLine(to: CGPoint(x: 0.99853*width, y: 0.95314*height))
        path.addLine(to: CGPoint(x: 0.99509*width, y: 0.98201*height))
        path.addLine(to: CGPoint(x: 0.99018*width, y: 0.99874*height))
        path.addLine(to: CGPoint(x: 0.71071*width, y: 0.99874*height))
        path.move(to: CGPoint(x: 0.26228*width, y: 0.99749*height))
        path.addLine(to: CGPoint(x: 0.00147*width, y: 0.99749*height))
        path.addLine(to: CGPoint(x: 0.00147*width, y: 0.95774*height))
        path.addLine(to: CGPoint(x: 0.00786*width, y: 0.91548*height))
        path.addLine(to: CGPoint(x: 0.01621*width, y: 0.88117*height))
        path.addLine(to: CGPoint(x: 0.02505*width, y: 0.85105*height))
        path.addLine(to: CGPoint(x: 0.03684*width, y: 0.81757*height))
        path.addLine(to: CGPoint(x: 0.05354*width, y: 0.78033*height))
        path.addLine(to: CGPoint(x: 0.07564*width, y: 0.74937*height))
        path.addLine(to: CGPoint(x: 0.09381*width, y: 0.72343*height))
        path.addLine(to: CGPoint(x: 0.10904*width, y: 0.70879*height))
        path.move(to: CGPoint(x: 0.43026*width, y: 0.62134*height))
        path.addLine(to: CGPoint(x: 0.46857*width, y: 0.70753*height))
        path.addLine(to: CGPoint(x: 0.51277*width, y: 0.60251*height))
        path.move(to: CGPoint(x: 0.43026*width, y: 0.62134*height))
        path.addLine(to: CGPoint(x: 0.4558*width, y: 0.61841*height))
        path.addLine(to: CGPoint(x: 0.48084*width, y: 0.61297*height))
        path.addLine(to: CGPoint(x: 0.51277*width, y: 0.60251*height))
        path.move(to: CGPoint(x: 0.43026*width, y: 0.62134*height))
        path.addLine(to: CGPoint(x: 0.40029*width, y: 0.62134*height))
        path.move(to: CGPoint(x: 0.51277*width, y: 0.60251*height))
        path.addLine(to: CGPoint(x: 0.56041*width, y: 0.58285*height))
        path.move(to: CGPoint(x: 0.27161*width, y: 0.54895*height))
        path.addLine(to: CGPoint(x: 0.24018*width, y: 0.51004*height))
        path.addLine(to: CGPoint(x: 0.22004*width, y: 0.46904*height))
        path.addLine(to: CGPoint(x: 0.20972*width, y: 0.43264*height))
        path.addLine(to: CGPoint(x: 0.20285*width, y: 0.39079*height))
        path.addLine(to: CGPoint(x: 0.19892*width, y: 0.34854*height))
        path.addLine(to: CGPoint(x: 0.19892*width, y: 0.30711*height))
        path.addLine(to: CGPoint(x: 0.20727*width, y: 0.25439*height))
        path.addLine(to: CGPoint(x: 0.21611*width, y: 0.20921*height))
        path.addLine(to: CGPoint(x: 0.22741*width, y: 0.17782*height))
        path.addLine(to: CGPoint(x: 0.24754*width, y: 0.13975*height))
        path.addLine(to: CGPoint(x: 0.28094*width, y: 0.09623*height))
        path.addLine(to: CGPoint(x: 0.3168*width, y: 0.06653*height))
        path.addLine(to: CGPoint(x: 0.35953*width, y: 0.04184*height))
        path.addLine(to: CGPoint(x: 0.41012*width, y: 0.02176*height))
        path.addLine(to: CGPoint(x: 0.46807*width, y: 0.00753*height))
        path.addLine(to: CGPoint(x: 0.51817*width, y: 0.00126*height))
        path.addLine(to: CGPoint(x: 0.56582*width, y: 0.00377*height))
        path.addLine(to: CGPoint(x: 0.60953*width, y: 0.01046*height))
        path.addLine(to: CGPoint(x: 0.64391*width, y: 0.02176*height))
        path.addLine(to: CGPoint(x: 0.68124*width, y: 0.03515*height))
        path.addLine(to: CGPoint(x: 0.6956*width, y: 0.05146*height))
        path.move(to: CGPoint(x: 0.76817*width, y: 0.30544*height))
        path.addLine(to: CGPoint(x: 0.7446*width, y: 0.29916*height))
        path.addLine(to: CGPoint(x: 0.74279*width, y: 0.29951*height))
        path.addLine(to: CGPoint(x: 0.71218*width, y: 0.30544*height))
        path.addLine(to: CGPoint(x: 0.68369*width, y: 0.31046*height))
        path.addLine(to: CGPoint(x: 0.66847*width, y: 0.30167*height))
        path.addLine(to: CGPoint(x: 0.66847*width, y: 0.2795*height))
        path.addLine(to: CGPoint(x: 0.68369*width, y: 0.25941*height))
        path.addLine(to: CGPoint(x: 0.66847*width, y: 0.25607*height))
        path.addLine(to: CGPoint(x: 0.65668*width, y: 0.25356*height))
        path.addLine(to: CGPoint(x: 0.65128*width, y: 0.24477*height))
        path.addLine(to: CGPoint(x: 0.66159*width, y: 0.22594*height))
        path.addLine(to: CGPoint(x: 0.66159*width, y: 0.2205*height))
        path.addLine(to: CGPoint(x: 0.6724*width, y: 0.21674*height))
        path.addLine(to: CGPoint(x: 0.67583*width, y: 0.21213*height))
        path.addLine(to: CGPoint(x: 0.66847*width, y: 0.20795*height))
        path.addLine(to: CGPoint(x: 0.65668*width, y: 0.20795*height))
        path.addLine(to: CGPoint(x: 0.64686*width, y: 0.19498*height))
        path.addLine(to: CGPoint(x: 0.66159*width, y: 0.17531*height))
        path.addLine(to: CGPoint(x: 0.67583*width, y: 0.16862*height))
        path.addLine(to: CGPoint(x: 0.67583*width, y: 0.16109*height))
        path.addLine(to: CGPoint(x: 0.65668*width, y: 0.16109*height))
        path.addLine(to: CGPoint(x: 0.64686*width, y: 0.15397*height))
        path.addLine(to: CGPoint(x: 0.64391*width, y: 0.14017*height))
        path.addLine(to: CGPoint(x: 0.66159*width, y: 0.11674*height))
        path.addLine(to: CGPoint(x: 0.68713*width, y: 0.09958*height))
        path.addLine(to: CGPoint(x: 0.71513*width, y: 0.08285*height))
        path.addLine(to: CGPoint(x: 0.70481*width, y: 0.06192*height))
        path.addLine(to: CGPoint(x: 0.6956*width, y: 0.05146*height))
        path.move(to: CGPoint(x: 0.76817*width, y: 0.30544*height))
        path.addLine(to: CGPoint(x: 0.78193*width, y: 0.32092*height))
        path.addLine(to: CGPoint(x: 0.78585*width, y: 0.34393*height))
        path.addLine(to: CGPoint(x: 0.78585*width, y: 0.37322*height))
        path.addLine(to: CGPoint(x: 0.76473*width, y: 0.39916*height))
        path.addLine(to: CGPoint(x: 0.73919*width, y: 0.40711*height))
        path.addLine(to: CGPoint(x: 0.71218*width, y: 0.40502*height))
        path.addLine(to: CGPoint(x: 0.69352*width, y: 0.40126*height))
        path.addLine(to: CGPoint(x: 0.68664*width, y: 0.43473*height))
        path.addLine(to: CGPoint(x: 0.67583*width, y: 0.47155*height))
        path.addLine(to: CGPoint(x: 0.65128*width, y: 0.51088*height))
        path.addLine(to: CGPoint(x: 0.6223*width, y: 0.54059*height))
        path.move(to: CGPoint(x: 0.76817*width, y: 0.30544*height))
        path.addLine(to: CGPoint(x: 0.76817*width, y: 0.24979*height))
        path.addLine(to: CGPoint(x: 0.76817*width, y: 0.20293*height))
        path.addLine(to: CGPoint(x: 0.77554*width, y: 0.15397*height))
        path.addLine(to: CGPoint(x: 0.77554*width, y: 0.08912*height))
        path.addLine(to: CGPoint(x: 0.75246*width, y: 0.05146*height))
        path.addLine(to: CGPoint(x: 0.73428*width, y: 0.03515*height))
        path.addLine(to: CGPoint(x: 0.6956*width, y: 0.05146*height))
        path.move(to: CGPoint(x: 0.3777*width, y: 0.52176*height))
        path.addLine(to: CGPoint(x: 0.45383*width, y: 0.52008*height))
        path.move(to: CGPoint(x: 0.41749*width, y: 0.45983*height))
        path.addLine(to: CGPoint(x: 0.37033*width, y: 0.45565*height))
        path.addLine(to: CGPoint(x: 0.33104*width, y: 0.44937*height))
        path.addLine(to: CGPoint(x: 0.30992*width, y: 0.43808*height))
        path.addLine(to: CGPoint(x: 0.30403*width, y: 0.41967*height))
        path.addLine(to: CGPoint(x: 0.30992*width, y: 0.39791*height))
        path.addLine(to: CGPoint(x: 0.31925*width, y: 0.3728*height))
        path.addLine(to: CGPoint(x: 0.33399*width, y: 0.34435*height))
        path.addLine(to: CGPoint(x: 0.34823*width, y: 0.31632*height))
        path.addLine(to: CGPoint(x: 0.36346*width, y: 0.28828*height))
        path.move(to: CGPoint(x: 0.26621*width, y: 0.22887*height))
        path.addLine(to: CGPoint(x: 0.32564*width, y: 0.25356*height))
        path.move(to: CGPoint(x: 0.4612*width, y: 0.24979*height))
        path.addLine(to: CGPoint(x: 0.52701*width, y: 0.22887*height))
        path.move(to: CGPoint(x: 0.27063*width, y: 0.30377*height))
        path.addLine(to: CGPoint(x: 0.32564*width, y: 0.30377*height))
        path.move(to: CGPoint(x: 0.47004*width, y: 0.3113*height))
        path.addLine(to: CGPoint(x: 0.5275*width, y: 0.3113*height))
        path.move(to: CGPoint(x: 0.29862*width, y: 0.4887*height))
        path.addLine(to: CGPoint(x: 0.31189*width, y: 0.4887*height))
        path.addLine(to: CGPoint(x: 0.32564*width, y: 0.48661*height))
        path.addLine(to: CGPoint(x: 0.33988*width, y: 0.48159*height))
        path.addLine(to: CGPoint(x: 0.3556*width, y: 0.4749*height))
        path.move(to: CGPoint(x: 0.52456*width, y: 0.49121*height))
        path.addLine(to: CGPoint(x: 0.50639*width, y: 0.49121*height))
        path.addLine(to: CGPoint(x: 0.4887*width, y: 0.48661*height))
        path.addLine(to: CGPoint(x: 0.472*width, y: 0.48159*height))
        path.addLine(to: CGPoint(x: 0.46071*width, y: 0.4749*height))
        path.move(to: CGPoint(x: 0.2613*width, y: 0.64812*height))
        path.addLine(to: CGPoint(x: 0.26523*width, y: 0.64351*height))
        path.addLine(to: CGPoint(x: 0.26523*width, y: 0.63933*height))
        path.addLine(to: CGPoint(x: 0.26081*width, y: 0.63556*height))
        path.addLine(to: CGPoint(x: 0.25884*width, y: 0.63389*height))
        path.addLine(to: CGPoint(x: 0.25098*width, y: 0.63389*height))
        path.addLine(to: CGPoint(x: 0.24853*width, y: 0.63682*height))
        path.addLine(to: CGPoint(x: 0.2446*width, y: 0.64017*height))
        path.addLine(to: CGPoint(x: 0.2446*width, y: 0.64644*height))
        path.addLine(to: CGPoint(x: 0.24951*width, y: 0.65021*height))
        path.addLine(to: CGPoint(x: 0.25786*width, y: 0.65021*height))
        path.addLine(to: CGPoint(x: 0.2613*width, y: 0.64812*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.24902*width, y: 0.92134*height))
        path.addLine(to: CGPoint(x: 0.15472*width, y: 0.88787*height))
        path.move(to: CGPoint(x: 0.72446*width, y: 0.92845*height))
        path.addLine(to: CGPoint(x: 0.84234*width, y: 0.89874*height))
        path.move(to: CGPoint(x: 0.19303*width, y: 0.66067*height))
        path.addLine(to: CGPoint(x: 0.1724*width, y: 0.66067*height))
        path.addLine(to: CGPoint(x: 0.15815*width, y: 0.66569*height))
        path.addLine(to: CGPoint(x: 0.15521*width, y: 0.67573*height))
        path.addLine(to: CGPoint(x: 0.15815*width, y: 0.68368*height))
        path.addLine(to: CGPoint(x: 0.16994*width, y: 0.68996*height))
        path.addLine(to: CGPoint(x: 0.18861*width, y: 0.68996*height))
        path.addLine(to: CGPoint(x: 0.19892*width, y: 0.70418*height))
        path.addLine(to: CGPoint(x: 0.21267*width, y: 0.70795*height))
        path.addLine(to: CGPoint(x: 0.22741*width, y: 0.70795*height))
        path.addLine(to: CGPoint(x: 0.23723*width, y: 0.69707*height))
        path.addLine(to: CGPoint(x: 0.24263*width, y: 0.68996*height))
        path.addLine(to: CGPoint(x: 0.24361*width, y: 0.68787*height))
        path.addLine(to: CGPoint(x: 0.25344*width, y: 0.68745*height))
        path.addLine(to: CGPoint(x: 0.26031*width, y: 0.68745*height))
        path.addLine(to: CGPoint(x: 0.26817*width, y: 0.68619*height))
        path.addLine(to: CGPoint(x: 0.27407*width, y: 0.68159*height))
        path.addLine(to: CGPoint(x: 0.27554*width, y: 0.6728*height))
        path.addLine(to: CGPoint(x: 0.27603*width, y: 0.66611*height))
        path.addLine(to: CGPoint(x: 0.26621*width, y: 0.65941*height))
        path.addLine(to: CGPoint(x: 0.25491*width, y: 0.65774*height))
        path.addLine(to: CGPoint(x: 0.24263*width, y: 0.65774*height))
        path.addLine(to: CGPoint(x: 0.23969*width, y: 0.65732*height))
        path.addLine(to: CGPoint(x: 0.23477*width, y: 0.65146*height))
        path.addLine(to: CGPoint(x: 0.23527*width, y: 0.64561*height))
        path.addLine(to: CGPoint(x: 0.22986*width, y: 0.63975*height))
        path.addLine(to: CGPoint(x: 0.22348*width, y: 0.63556*height))
        path.addLine(to: CGPoint(x: 0.21415*width, y: 0.63473*height))
        path.addLine(to: CGPoint(x: 0.20825*width, y: 0.63515*height))
        path.addLine(to: CGPoint(x: 0.20187*width, y: 0.63682*height))
        path.addLine(to: CGPoint(x: 0.19646*width, y: 0.64142*height))
        path.addLine(to: CGPoint(x: 0.19401*width, y: 0.64812*height))
        path.addLine(to: CGPoint(x: 0.19303*width, y: 0.65439*height))
        path.addLine(to: CGPoint(x: 0.19303*width, y: 0.66067*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.18026*width, y: 0.64854*height))
        path.addLine(to: CGPoint(x: 0.17436*width, y: 0.65356*height))
        path.addLine(to: CGPoint(x: 0.16847*width, y: 0.65356*height))
        path.addLine(to: CGPoint(x: 0.16405*width, y: 0.65063*height))
        path.addLine(to: CGPoint(x: 0.1611*width, y: 0.64937*height))
        path.addLine(to: CGPoint(x: 0.16159*width, y: 0.64519*height))
        path.addLine(to: CGPoint(x: 0.16454*width, y: 0.6431*height))
        path.addLine(to: CGPoint(x: 0.16847*width, y: 0.64059*height))
        path.addLine(to: CGPoint(x: 0.17289*width, y: 0.64059*height))
        path.addLine(to: CGPoint(x: 0.17633*width, y: 0.64226*height))
        path.addLine(to: CGPoint(x: 0.17878*width, y: 0.64477*height))
        path.addLine(to: CGPoint(x: 0.18026*width, y: 0.64644*height))
        path.addLine(to: CGPoint(x: 0.18026*width, y: 0.64854*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.74705*width, y: 0.62427*height))
        path.addLine(to: CGPoint(x: 0.75639*width, y: 0.62427*height))
        path.addLine(to: CGPoint(x: 0.76424*width, y: 0.62427*height))
        path.addLine(to: CGPoint(x: 0.77112*width, y: 0.6272*height))
        path.addLine(to: CGPoint(x: 0.7775*width, y: 0.63264*height))
        path.addLine(to: CGPoint(x: 0.77849*width, y: 0.641*height))
        path.addLine(to: CGPoint(x: 0.77849*width, y: 0.65272*height))
        path.addLine(to: CGPoint(x: 0.79813*width, y: 0.65272*height))
        path.addLine(to: CGPoint(x: 0.80648*width, y: 0.65523*height))
        path.addLine(to: CGPoint(x: 0.81532*width, y: 0.6682*height))
        path.addLine(to: CGPoint(x: 0.81532*width, y: 0.67448*height))
        path.addLine(to: CGPoint(x: 0.80255*width, y: 0.68117*height))
        path.addLine(to: CGPoint(x: 0.7888*width, y: 0.68117*height))
        path.addLine(to: CGPoint(x: 0.77849*width, y: 0.68117*height))
        path.addLine(to: CGPoint(x: 0.77603*width, y: 0.68117*height))
        path.addLine(to: CGPoint(x: 0.77014*width, y: 0.69331*height))
        path.addLine(to: CGPoint(x: 0.75982*width, y: 0.69916*height))
        path.addLine(to: CGPoint(x: 0.74705*width, y: 0.70042*height))
        path.addLine(to: CGPoint(x: 0.73674*width, y: 0.69582*height))
        path.addLine(to: CGPoint(x: 0.7279*width, y: 0.68494*height))
        path.addLine(to: CGPoint(x: 0.72593*width, y: 0.67824*height))
        path.addLine(to: CGPoint(x: 0.71071*width, y: 0.67824*height))
        path.addLine(to: CGPoint(x: 0.70383*width, y: 0.67657*height))
        path.addLine(to: CGPoint(x: 0.69843*width, y: 0.6682*height))
        path.addLine(to: CGPoint(x: 0.70039*width, y: 0.65732*height))
        path.addLine(to: CGPoint(x: 0.71071*width, y: 0.65063*height))
        path.addLine(to: CGPoint(x: 0.72348*width, y: 0.65146*height))
        path.addLine(to: CGPoint(x: 0.73281*width, y: 0.64895*height))
        path.addLine(to: CGPoint(x: 0.73281*width, y: 0.641*height))
        path.addLine(to: CGPoint(x: 0.73674*width, y: 0.6318*height))
        path.addLine(to: CGPoint(x: 0.74705*width, y: 0.62427*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.71906*width, y: 0.641*height))
        path.addLine(to: CGPoint(x: 0.72348*width, y: 0.63515*height))
        path.addLine(to: CGPoint(x: 0.722*width, y: 0.62971*height))
        path.addLine(to: CGPoint(x: 0.71758*width, y: 0.6272*height))
        path.addLine(to: CGPoint(x: 0.71071*width, y: 0.6272*height))
        path.addLine(to: CGPoint(x: 0.70187*width, y: 0.62971*height))
        path.addLine(to: CGPoint(x: 0.70187*width, y: 0.63515*height))
        path.addLine(to: CGPoint(x: 0.70825*width, y: 0.641*height))
        path.addLine(to: CGPoint(x: 0.71906*width, y: 0.641*height))
        path.closeSubpath()
        path.move(to: CGPoint(x: 0.80108*width, y: 0.63724*height))
        path.addLine(to: CGPoint(x: 0.79175*width, y: 0.63724*height))
        path.addLine(to: CGPoint(x: 0.78929*width, y: 0.63933*height))
        path.addLine(to: CGPoint(x: 0.78635*width, y: 0.64017*height))
        path.addLine(to: CGPoint(x: 0.78635*width, y: 0.64561*height))
        path.addLine(to: CGPoint(x: 0.79175*width, y: 0.64561*height))
        path.addLine(to: CGPoint(x: 0.7942*width, y: 0.64728*height))
        path.addLine(to: CGPoint(x: 0.80108*width, y: 0.64728*height))
        path.addLine(to: CGPoint(x: 0.80108*width, y: 0.64561*height))
        path.addLine(to: CGPoint(x: 0.80747*width, y: 0.64435*height))
        path.addLine(to: CGPoint(x: 0.80747*width, y: 0.64017*height))
        path.addLine(to: CGPoint(x: 0.80108*width, y: 0.63724*height))
        path.closeSubpath()
        return path
    }
}
