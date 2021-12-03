//
//  XAxisView.m
//  WSLineChart
//
//  Created by iMac on 16/11/17.
//  Copyright © 2016年 zws. All rights reserved.
//

#import "XAxisView.h"

@interface XAxisView ()

@property (nonatomic, strong) NSMutableArray* layerArray;
@property (strong, nonatomic) NSArray *xTitleArray;
@property (strong, nonatomic) NSArray *yValueArray;
@property (strong, nonatomic) NSArray *yValue2Array;
@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;
@property (assign, nonatomic) CGFloat totalLength;

@property (assign, nonatomic) CGFloat defaultSpace;

/**
 *  记录坐标轴的第一个frame
 */
@property (assign, nonatomic) CGRect firstFrame;
@property (assign, nonatomic) CGRect firstStrFrame;//第一个点的文字的frame

@end


@implementation XAxisView

- (id)initWithFrame:(CGRect)frame
        xTitleArray:(NSArray*)xTitleArray
        yValueArray:(NSArray*)yValueArray
       yValue2Array:(NSArray*)yValue2Array
               yMax:(CGFloat)yMax
               yMin:(CGFloat)yMin{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.layerArray = [NSMutableArray array];
        self.xTitleArray = xTitleArray;
        self.yValueArray = yValueArray;
        self.yValue2Array = yValue2Array;
        self.yMax = yMax;
        self.yMin = yMin;
        self.lineColor = [UIColor redColor];
    }
    return self;
}

- (void)refreshLineWithValueArray:(NSArray*)yValueArray yValue2Array:(NSArray*)yValue2Array{
    [self setNeedsDisplay];
}

- (void)setPointGap:(CGFloat)pointGap {
    _pointGap = pointGap;
    self.totalLength = pointGap*(self.xTitleArray.count-1);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    for (CALayer* layer in self.layerArray) {
        if (layer) {
            layer.hidden = YES;
            [layer removeFromSuperlayer];
        }
    }
    [self.layerArray removeAllObjects];
    
    ////////////////////// X轴文字 //////////////////////////
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    // 添加坐标轴Label
    for (int i = 0; i < self.xTitleArray.count; i++) {
        NSString *title = self.xTitleArray[i];
        
        [self.xyTextColor set];
        NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
        CGSize labelSize = [title sizeWithAttributes:attr];
        
        CGRect titleRect = CGRectMake((i + 1) * self.pointGap - labelSize.width / 2,
                                      self.frame.size.height - labelSize.height - (self.bottomHeight-5-labelSize.height)/2.0-5,
                                      labelSize.width,
                                      labelSize.height);
        
        if (i == 0) {
            if (titleRect.origin.x < 0) {
                titleRect.origin.x = 0;
            }
            self.firstFrame = titleRect;
            
            [title drawInRect:titleRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],NSForegroundColorAttributeName:self.xyTextColor, NSParagraphStyleAttributeName:paragraphStyle}];
            
            //画垂直X轴的竖线，分割点
            [self drawLine:context
                startPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - self.bottomHeight)
                  endPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - self.bottomHeight-5)
                 lineColor:self.xyLineColor
                 lineWidth:1];
        }
        // 如果Label的文字有重叠，那么不绘制
        CGFloat maxX = CGRectGetMaxX(self.firstFrame);
        if (i != 0) {
            if ((maxX + 1) > titleRect.origin.x) {
                //不绘制
                
            }else{
                [title drawInRect:titleRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],NSForegroundColorAttributeName:self.xyTextColor, NSParagraphStyleAttributeName:paragraphStyle}];
                //画垂直X轴的竖线 分割点
                [self drawLine:context
                    startPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - self.bottomHeight)
                      endPoint:CGPointMake(titleRect.origin.x+labelSize.width/2, self.frame.size.height - self.bottomHeight-5)
                     lineColor:self.xyLineColor
                     lineWidth:1];
                
                self.firstFrame = titleRect;
            }
        }else {
            if (self.firstFrame.origin.x < 0) {
                
                CGRect frame = self.firstFrame;
                frame.origin.x = 0;
                self.firstFrame = frame;
            }
        }
    }
    //Y轴的单位
    if (self.showUnit && self.XunitStr.length>0) {
        NSDictionary *waterAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
        CGSize waterLabelSize = [self.XunitStr sizeWithAttributes:waterAttr];
        CGRect waterRect = CGRectMake(self.frame.size.width - waterLabelSize.width,
                                      self.frame.size.height - waterLabelSize.height - (self.bottomHeight-5-waterLabelSize.height)/2.0-5,
                                      waterLabelSize.width,
                                      waterLabelSize.height);
        [self.XunitStr drawInRect:waterRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:7],NSForegroundColorAttributeName:self.xyTextColor}];
    }
    
    //////////////// 画原点上的x轴 ///////////////////////
    [self drawLine:context
        startPoint:CGPointMake(0, self.frame.size.height - self.bottomHeight)
          endPoint:CGPointMake(self.frame.size.width, self.frame.size.height - self.bottomHeight)
         lineColor:self.xyLineColor
         lineWidth:1];
    
    
    //////////////// 画横向分割线 ///////////////////////
    CGFloat separateMargin = (self.frame.size.height - self.topMargin - self.bottomHeight - self.yAxisElements * 1) / self.yAxisElements;
    for (int i = 0; i < self.yAxisElements; i++) {
        
        [self drawLine:context
            startPoint:CGPointMake(0, self.frame.size.height - self.bottomHeight  - (i + 1) *(separateMargin + 1))
              endPoint:CGPointMake(0+self.frame.size.width, self.frame.size.height - self.bottomHeight  - (i + 1) *(separateMargin + 1))
             lineColor:self.horizontalLineColor
             lineWidth:0.5];
    }
    
    //画虚拟线条
    if (self.virtualYArray && self.virtualYArray.count > 0) {
        NSMutableArray* pointArray = [NSMutableArray array];
        CGFloat chartHeight = self.frame.size.height - self.bottomHeight - self.topMargin;
        if (self.beagnNeedFull) {
            //画第一个点
            if (self.fullToOverflow) {
                CGPoint startPoint = CGPointMake(0,
                                                 chartHeight - ([self.virtualYArray.firstObject floatValue]-self.virtualYMin)/(self.virtualYMax-self.virtualYMin) * chartHeight+self.topMargin);
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
            
            if ([self.virtualXArray.firstObject floatValue] != 0) {
                CGPoint startPoint = CGPointMake(self.pointGap,
                                                 chartHeight - ([self.virtualYArray.firstObject floatValue]-self.virtualYMin)/(self.virtualYMax-self.virtualYMin) * chartHeight+self.topMargin);
                
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
        }
        
        for (NSInteger i = 0; i < self.virtualYArray.count; i++) {
            
            NSString *startValue = self.virtualYArray[i];
            CGPoint startPoint = CGPointMake(self.pointGap + ([self.virtualXArray[i] floatValue])*self.totalLength,
                                             chartHeight - (startValue.floatValue-self.virtualYMin)/(self.virtualYMax-self.virtualYMin) * chartHeight+self.topMargin);
            [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            
            //是否需要一个 空的点
            if (i == self.virtualYArray.count-2 && self.needLastSecondPoint) {
                CGPoint emptyPoint = CGPointMake(self.pointGap + ([self.virtualXArray[i+1] floatValue])*self.totalLength,
                                                 chartHeight - (startValue.floatValue-self.virtualYMin)/(self.virtualYMax-self.virtualYMin) * chartHeight+self.topMargin);
                [pointArray addObject:[NSValue valueWithCGPoint:emptyPoint]];
            }
        }
        if (self.endNeedFull) {
            //画最后一个点， 最后的横线
            if ([self.virtualXArray.lastObject intValue] != 1) {
                CGFloat lastValue = [self.virtualYArray.lastObject floatValue];
                if (self.beganEqualEnd) {
                    lastValue = [self.virtualYArray.firstObject floatValue];
                }
                
                CGPoint startPoint = CGPointMake(self.pointGap + self.totalLength,
                                                 chartHeight - (lastValue-self.virtualYMin)/(self.virtualYMax-self.virtualYMin) * chartHeight+self.topMargin);
                
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
            
            if (self.fullToOverflow) {
                CGFloat lastValue = [self.virtualYArray.lastObject floatValue];
                if (self.beganEqualEnd) {
                    lastValue = [self.virtualYArray.firstObject floatValue];
                }
                CGPoint startPoint = CGPointMake(self.pointGap + self.totalLength + self.pointGap,
                                                 chartHeight - (lastValue-self.virtualYMin)/(self.virtualYMax-self.virtualYMin) * chartHeight+self.topMargin);
                
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
        }
        
        [self drawPathWithDataArr:pointArray lineColor:[self.virtualColor colorWithAlphaComponent:0.3] lineWidth:2 isDash:NO];
    }
    
    
    
    
    //画折线 了。。。
    if (self.yValueArray && self.yValueArray.count > 0) {
        
        NSMutableArray* pointArray = [NSMutableArray array];
        CGFloat chartHeight = self.frame.size.height - self.bottomHeight - self.topMargin;
        if (self.beagnNeedFull) {
            //画第一个点
            if (self.fullToOverflow) {
                CGPoint startPoint = CGPointMake(0,
                                                 chartHeight - ([self.yValueArray.firstObject floatValue]-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
            
            if ([self.yValue2Array.firstObject floatValue] != 0) {
                CGPoint startPoint = CGPointMake(self.pointGap,
                                                 chartHeight - ([self.yValueArray.firstObject floatValue]-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
                
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
        }
        
        for (NSInteger i = 0; i < self.yValueArray.count; i++) {
            
            NSString *startValue = self.yValueArray[i];
            CGPoint startPoint = CGPointMake(self.pointGap + ([self.yValue2Array[i] floatValue])*self.totalLength,
                                             chartHeight - (startValue.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
            [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            
            //是否需要一个 空的点
            if (i == self.yValueArray.count-2 && self.needLastSecondPoint) {
                CGPoint emptyPoint = CGPointMake(self.pointGap + ([self.yValue2Array[i+1] floatValue])*self.totalLength,
                                                 chartHeight - (startValue.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
                [pointArray addObject:[NSValue valueWithCGPoint:emptyPoint]];
            }
        }
        if (self.endNeedFull) {
            //画最后一个点， 最后的横线
            if ([self.yValue2Array.lastObject intValue] != 1) {
                CGFloat lastValue = [self.yValueArray.lastObject floatValue];
                if (self.beganEqualEnd) {
                    lastValue = [self.yValueArray.firstObject floatValue];
                }
                
                CGPoint startPoint = CGPointMake(self.pointGap + self.totalLength,
                                                 chartHeight - (lastValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
                
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
            
            if (self.fullToOverflow) {
                CGFloat lastValue = [self.yValueArray.lastObject floatValue];
                if (self.beganEqualEnd) {
                    lastValue = [self.yValueArray.firstObject floatValue];
                }
                CGPoint startPoint = CGPointMake(self.pointGap + self.totalLength + self.pointGap,
                                                 chartHeight - (lastValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
                
                [pointArray addObject:[NSValue valueWithCGPoint:startPoint]];
            }
        }
        
        [self drawPathWithDataArr:pointArray lineColor:self.lineColor lineWidth:2 isDash:NO];
    }
}

- (void)drawPathWithDataArr:(NSArray *)dataArr lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width isDash:(BOOL)isDash{
    
    UIBezierPath *firstPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 0, 0)];
    
    for (NSInteger i = 0; i<dataArr.count; i++) {
        NSValue *value = dataArr[i];
        CGPoint p = value.CGPointValue;
        if (i==0) {
            [firstPath moveToPoint:p];
        }else{
            //画曲线 还是画直线
//            CGPoint nextP = [dataArr[i-1] CGPointValue];
//            CGPoint control1 = CGPointMake(p.x + (nextP.x - p.x) / 2.0, nextP.y );
//            CGPoint control2 = CGPointMake(p.x + (nextP.x - p.x) / 2.0, p.y);
//            [firstPath addCurveToPoint:p controlPoint1:control1 controlPoint2:control2];
            [firstPath addLineToPoint:p];
        }
    }
    if (dataArr.count == 1) {
        NSValue *value = dataArr[0];
        CGPoint p = value.CGPointValue;
        
        [firstPath addLineToPoint:CGPointMake(p.x+1, p.y+1)];
        firstPath.lineCapStyle = kCGLineCapRound;
    }
//    if (isDash) {
//        CGFloat normal[]={10, 6};
//        [firstPath setLineDash:normal count:2 phase:0];
//    }
    
    
    //第二、UIBezierPath和CAShapeLayer关联
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = firstPath.CGPath;
    if (isDash) {
        shapeLayer.lineDashPattern = @[@(10), @(6)];
    }
    
    shapeLayer.strokeColor = lineColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = width;
    
    CGFloat animationDuration = 1.5;
//    if (self.layerArray.count && !self.isMultiLine) {
//        animationDuration = 0;
//    }
    //第三，动画
    if ((!self.layerArray.count && self.showAnimation) || (self.showAnimation)) {
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
        ani.fromValue = @0;
        ani.toValue = @1;
        ani.duration = animationDuration;
        [shapeLayer addAnimation:ani forKey:NSStringFromSelector(@selector(strokeEnd))];
    }
    
    [self.layer addSublayer:shapeLayer];
    
//    for (CALayer* layer in self.layerArray) {
//        if (layer) {
//            [layer removeFromSuperlayer];
//        }
//    }
//    [self.layerArray removeAllObjects];
    [self.layerArray addObject:shapeLayer];
    
}

- (void)drawLine:(CGContextRef)context
      startPoint:(CGPoint)startPoint
        endPoint:(CGPoint)endPoint
       lineColor:(UIColor *)lineColor
       lineWidth:(CGFloat)width{
    
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

