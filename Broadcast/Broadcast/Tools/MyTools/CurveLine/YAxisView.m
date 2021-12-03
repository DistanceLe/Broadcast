//
//  YAxisView.m
//  WSLineChart
//
//  Created by iMac on 16/11/17.
//  Copyright © 2016年 zws. All rights reserved.
//

#import "YAxisView.h"

@interface YAxisView ()

@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;

@end

@implementation YAxisView

- (id)initWithFrame:(CGRect)frame yMax:(CGFloat)yMax yMin:(CGFloat)yMin {
    
    if (self = [super initWithFrame:frame]) {
        self.yMax = yMax;
        self.yMin = yMin;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 计算坐标轴的位置以及大小
    [self drawLine:context
        startPoint:CGPointMake(self.frame.size.width,
                               0)
          endPoint:CGPointMake(self.frame.size.width,
                               self.frame.size.height - (self.bottomHeight-5) - self.xAxisAndTextInterval) lineColor:self.xyLineColor lineWidth:1];
    
    
    NSDictionary *waterAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:7]};
    
    //Y轴的单位
    if (self.showUnit && self.unitStr.length>0) {
        CGSize waterLabelSize = [self.unitStr sizeWithAttributes:waterAttr];
        CGRect waterRect = CGRectMake(self.frame.size.width -2 - waterLabelSize.width,
                                      5,
                                      waterLabelSize.width,
                                      waterLabelSize.height);
        [self.unitStr drawInRect:waterRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:7],NSForegroundColorAttributeName:self.xyTextColor}];
    }
    
    CGFloat labelMargin = (self.frame.size.height - self.topMargin - self.bottomHeight) / self.yAxisElements;
    
    
    waterAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
    // 添加Label
    for (int i = 0; i < self.yAxisElements + 1; i++) {

        CGFloat avgValue = (self.yMax - self.yMin) / self.yAxisElements;
        // 判断是不是小数
        if ([self isPureFloat:self.yMin + avgValue * i]) {
            CGSize yLabelSize = [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i] sizeWithAttributes:waterAttr];
            [[NSString stringWithFormat:@"%.2f", self.yMin + avgValue * i]
             drawInRect:CGRectMake(self.frame.size.width - 1-5 - yLabelSize.width,
                                   self.frame.size.height - self.bottomHeight - labelMargin* i - yLabelSize.height/2,
                                   yLabelSize.width,
                                   yLabelSize.height)
             withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],
                              NSForegroundColorAttributeName:self.xyTextColor}];
        }
        else {
            CGSize yLabelSize = [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i] sizeWithAttributes:waterAttr];
            [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i]
             drawInRect:CGRectMake(self.frame.size.width - 1-5 - yLabelSize.width,
                                   self.frame.size.height - self.bottomHeight - labelMargin* i - yLabelSize.height/2,
                                   yLabelSize.width,
                                   yLabelSize.height)
             withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],
                              NSForegroundColorAttributeName:self.xyTextColor}];
        }
    }
}
// 判断是小数还是整数
- (BOOL)isPureFloat:(CGFloat)num{
    int i = num;
    CGFloat result = num - i;
    // 当不等于0时，是小数
    return result != 0;
}

- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width {
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
    CGContextStrokePath(context);
    CGColorSpaceRelease(Linecolorspace1);
}



@end
