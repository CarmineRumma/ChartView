//
//  ChartRow.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartRow : View {
    var data: [Double]
    var accentColor: Color
    var gradient: GradientColor?
    
    var maxValue: Double {
        guard let max = data.max() else {
            return 1
        }
        return max != 0 ? max : 1
    }
    @Binding var touchLocation: CGFloat
    public var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: (geometry.frame(in: .local).width)/CGFloat(self.data.count * 3)){
                
                ForEach(0..<self.data.count, id: \.self) { i in
                   // if (Int(self.data[i]) == 0){
                        //ZeroLine(geoProx: geometry, dataCount: self.data.count)
                   // } else {
                        BarChartCell(value: self.normalizedValue(index: i),
                                     index: i,
                                     width: Float(geometry.frame(in: .local).width - 11),
                                     numberOfDataPoints: self.data.count,
                                     accentColor: self.accentColor,
                                     gradient: self.gradient,
                                     touchLocation: self.$touchLocation)
                            .scaleEffect(self.touchLocation > CGFloat(i)/CGFloat(self.data.count) && self.touchLocation < CGFloat(i+1)/CGFloat(self.data.count) ? CGSize(width: 1.4, height: 1.1) : CGSize(width: 1, height: 1), anchor: .bottom)
                            .animation(.spring())
                   // }
                    
                }
                
            }
            .overlay(Rectangle().frame(width: nil, height: 2, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom)
            .padding([.top, .leading, .trailing], 10)
        }
    }
    
    func normalizedValue(index: Int) -> Double {
        return Double(self.data[index])/Double(self.maxValue)
    }
}

struct ZeroLine: View {
    let geoProx: GeometryProxy
    let dataCount: Int
    var body: some View {
        ZStack {
            Path{ path in
                path.move(to: CGPoint(x: 0, y: geoProx.size.height-12))
                path.addLine(to: CGPoint(x: CGFloat(Float(geoProx.frame(in: .local).width - 11)), y: geoProx.size.height-12))

            }
            .stroke(style: StrokeStyle(lineWidth: 4.0, lineCap: .round, dash: [4, 6]))
            .foregroundColor(.black)
            .cornerRadius(1.0)
            .zIndex(1.5)
        }
    }
}

#if DEBUG
struct ChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            BarChartRow(data: [0, 5, 10], accentColor: Colors.OrangeStart, touchLocation: .constant(-1))
        }
    }
}
#endif
