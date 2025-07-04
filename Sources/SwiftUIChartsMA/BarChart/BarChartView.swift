//
//  ChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartView : View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private var data: ChartData
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize:CGSize
    public var dropShadow: Bool
    public var cornerImage: Image?
    public var valueSpecifier:String
    public var customFont: Font?
    public var cornerRadius: CGFloat?
    @State private var touchLocation: CGFloat = -1.0
    @State private var showValue: Bool = false
    @State private var showLabelValue: Bool = false
    @State private var currentValue: Double = 0 {
        didSet{
            if(oldValue != self.currentValue && self.showValue) {
                HapticFeedback.playSelection()
            }
        }
    }
    var isFullWidth:Bool {
        return self.formSize == ChartForm.large
    }
    public init(data:ChartData, title: String, legend: String? = nil, style: ChartStyle = Styles.barChartStyleOrangeLight, form: CGSize? = ChartForm.medium, dropShadow: Bool? = true, cornerImage:Image? = Image(systemName: "waveform.path.ecg"), valueSpecifier: String? = "%.1f", customFont:Font? = nil,
                cornerRadius:CGFloat? = 20.0){
        self.data = data
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.barChartStyleOrangeDark
        self.formSize = form!
        self.dropShadow = dropShadow!
        self.cornerImage = cornerImage
        self.valueSpecifier = valueSpecifier!
        self.customFont = customFont;
        self.cornerRadius = cornerRadius;
    }
    
    public var body: some View {
        ZStack{
            Rectangle()
                .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
                .cornerRadius(self.cornerRadius!)
                .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
            VStack(alignment: .leading){
                HStack{
                    if(!showValue){
                        Text(self.title)
                            .font(self.customFont != nil ? self.customFont : .title)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }else{
                        Text(self.valueSpecifier == "%d" ? "\(Int(self.currentValue))" : "\(self.currentValue, specifier: self.valueSpecifier)")
                            .font(self.customFont != nil ? self.customFont : .headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    if(self.formSize == ChartForm.large && self.legend != nil && !showValue) {
                        Text(self.legend!)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor)
                            .transition(.opacity)
                            .animation(.easeOut)
                        
                    }
                    Spacer()
                    if(self.cornerImage != nil){
                        self.cornerImage!.renderingMode(.template).resizable().frame(width: 30.0, height: 30.0, alignment: .center)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor);
                    }
                }.padding()
                BarChartRow(data: data.points.map{$0.1},
                            accentColor: self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor,
                            axisColor: self.colorScheme == .dark ? self.darkModeStyle.axisColor : self.style.axisColor,
                            gradient: self.colorScheme == .dark ? self.darkModeStyle.gradientColor : self.style.gradientColor,
                            touchLocation: self.$touchLocation)
                if self.legend != nil  && self.formSize != ChartForm.large && !self.showLabelValue{
                    Text(self.legend!)
                        .font(self.customFont != nil ? self.customFont : .headline)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                        .padding()
                }else if (self.data.valuesGiven && self.getCurrentValue() != nil) {
                    LabelView(arrowOffset: self.getArrowOffset(touchLocation: self.touchLocation),
                              title: .constant(self.getCurrentValue()!.0))
                        .offset(x: self.getLabelViewOffset(touchLocation: self.touchLocation), y: -6)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                }
                
            }
        }.frame(minWidth:self.formSize.width,
                maxWidth: self.isFullWidth ? .infinity : self.formSize.width,
                minHeight:self.formSize.height,
                maxHeight:self.formSize.height)
            .gesture(DragGesture()
                .onChanged({ value in
                    self.touchLocation = value.location.x/self.formSize.width
                    self.showValue = true
                    self.currentValue = self.getCurrentValue()?.1 ?? 0
                    if(self.data.valuesGiven && self.formSize == ChartForm.medium) {
                        self.showLabelValue = true
                    }
                })
                .onEnded({ value in
                    self.showValue = false
                    self.showLabelValue = false
                    self.touchLocation = -1
                })
        )
            .gesture(TapGesture()
        )
    }
    
    func getArrowOffset(touchLocation:CGFloat) -> Binding<CGFloat> {
        let realLoc = (self.touchLocation * self.formSize.width) - 50
        if realLoc < 10 {
            return .constant(realLoc - 10)
        }else if realLoc > self.formSize.width-110 {
            return .constant((self.formSize.width-110 - realLoc) * -1)
        } else {
            return .constant(0)
        }
    }
    
    func getLabelViewOffset(touchLocation:CGFloat) -> CGFloat {
        return min(self.formSize.width-110,max(10,(self.touchLocation * self.formSize.width) - 50))
    }
    
    func getCurrentValue() -> (String,Double)? {
        guard self.data.points.count > 0 else { return nil}
        let index = max(0,min(self.data.points.count-1,Int(floor((self.touchLocation*self.formSize.width)/(self.formSize.width/CGFloat(self.data.points.count))))))
        return self.data.points[index]
    }
}

#if DEBUG
struct ChartView_Previews : PreviewProvider {

    static var previews: some View {
        BarChartView(data: ChartData(values: [("Lun",63150), ("Mar Q1",50900), ("2019 Q2",77550), ("2019 Q3",79600),  ("2019 Q4",120 ), ("2019 Q4",92550)]), title: "Test", legend: "Quarterly", form: CGSize(width: UIScreen.main.bounds.width, height: 300), dropShadow: false, valueSpecifier: "%.1f EUR", cornerRadius: 0)
    }
}
#endif
