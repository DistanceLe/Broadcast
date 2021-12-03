//
//  RightYAxisView.m
//  LineChartDemo
//
//  Created by lijie on 2018/9/3.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import "RightYAxisView.h"

@interface RightYAxisView()

@end

@implementation RightYAxisView

- (id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawLine:context
        startPoint:CGPointMake(0, 0)
          endPoint:CGPointMake(0, self.frame.size.height - (self.bottomHeight-5) - self.xAxisAndTextInterval) lineColor:self.xyLineColor lineWidth:1];
    
    if (self.showUnit) {
        // 计算坐标轴的位置以及大小
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
        CGSize XlabelSize = [@"x\nx" sizeWithAttributes:attr];
        
        NSDictionary *waterAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:7]};

        //Y轴的单位
        if (self.unitStr.length>0) {
            CGSize waterLabelSize = [self.unitStr sizeWithAttributes:waterAttr];
            CGRect waterRect = CGRectMake(2, 5,waterLabelSize.width,waterLabelSize.height);
            [self.unitStr drawInRect:waterRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:7],NSForegroundColorAttributeName:self.xyTextColor}];
        }

        CGFloat labelMargin = (self.frame.size.height - self.topMargin - XlabelSize.height - 5 ) / self.yAxisElements;

        waterAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
        // 添加Label
        for (int i = 0; i < self.yAxisElements + 1; i++) {

            CGFloat avgValue = (self.yMax - self.yMin) / self.yAxisElements;

            // 判断是不是小数
            if ([self isPureFloat:self.yMin + avgValue * i]) {
                CGSize yLabelSize = [[NSString stringWithFormat:@"%.2f", self.yMin + avgValue * i] sizeWithAttributes:waterAttr];

                [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i]
                 drawInRect:CGRectMake(5,
                                       self.frame.size.height - XlabelSize.height - 5 - labelMargin* i - yLabelSize.height/2,
                                       yLabelSize.width,
                                       yLabelSize.height)
                 withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],
                                  NSForegroundColorAttributeName:self.xyTextColor}];
            }
            else {
                CGSize yLabelSize = [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i] sizeWithAttributes:waterAttr];

                [[NSString stringWithFormat:@"%.0f", self.yMin + avgValue * i]
                 drawInRect:CGRectMake(5,
                                       self.frame.size.height - XlabelSize.height - 5 - labelMargin* i - yLabelSize.height/2,
                                       yLabelSize.width,
                                       yLabelSize.height)
                 withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],
                                  NSForegroundColorAttributeName:self.xyTextColor}];
            }
        }
    }
}
// 判断是小数还是整数
- (BOOL)isPureFloat:(CGFloat)num
{
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
