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
                    if (Int(self.data[i]) == 0){
                        ZStack {
                            //ZeroLine(geoProx: geometry).scaleEffect(CGSize(width: 1, height: 1)).animation(.spring())
                            RoundedRectangle(cornerRadius: 4).fill(accentColor).frame(width: 1, height: 1, alignment: .bottom)
                        }
                        
                    }
                    BarChartCell(value: self.normalizedValue(index: i),
                                 index: i,
                                 width: Float(geometry.frame(in: .local).width - 11),
                                 numberOfDataPoints: self.data.count,
                                 accentColor: self.accentColor,
                                 gradient: self.gradient,
                                 touchLocation: self.$touchLocation)
                        .scaleEffect(self.touchLocation > CGFloat(i)/CGFloat(self.data.count) && self.touchLocation < CGFloat(i+1)/CGFloat(self.data.count) ? CGSize(width: 1.4, height: 1.1) : CGSize(width: 1, height: 1), anchor: .bottom)
                        .animation(.spring())
                    
                }
            }
            .padding([.top, .leading, .trailing], 10)
        }
    }
    
    func normalizedValue(index: Int) -> Double {
        return Double(self.data[index])/Double(self.maxValue)
    }
}

struct ZeroLine: View {
    let geoProx: GeometryProxy

    var body: some View {
        Path{ path in
            path.move(to: CGPoint(x: geoProx.size.width/2, y: geoProx.size.height/2))
            path.addLine(to: CGPoint(x: geoProx.size.width/2 - geoProx.size.width/4, y: geoProx.size.height/2))

        }
        .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round))
        .foregroundColor(.white)
        .cornerRadius(10.0)
        .zIndex(1.5)
    }
}

#if DEBUG
struct ChartRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            BarChartRow(data: [0], accentColor: Colors.OrangeStart, touchLocation: .constant(-1))
            BarChartRow(data: [8,23,54,32,12,37,7], accentColor: Colors.OrangeStart, touchLocation: .constant(-1))
        }
    }
}
#endif
