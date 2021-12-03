//
//  XTextView.m
//  LJTrack
//
//  Created by LiJie on 2017/11/18.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "XTextView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface XTextView()

@property (strong, nonatomic) NSArray *xTitleArray;
@property (strong, nonatomic) NSArray *yValueArray;
@property (strong, nonatomic) NSArray *yValue2Array;
@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;

//@property (assign, nonatomic) CGRect firstFrame;
@property (assign, nonatomic) CGRect firstStrFrame;//第一个点的文字的frame

//因为和前一个点可能没有交集，但是和前几个点可能会有交集
@property (nonatomic, strong)NSMutableArray* oldStrFrame;

@property (assign, nonatomic) CGFloat totalLength;
@end


@implementation XTextView


- (id)initWithFrame:(CGRect)frame xTitleArray:(NSArray*)xTitleArray yValueArray:(NSArray*)yValueArray yValue2Array:(NSArray*)yValue2Array yMax:(CGFloat)yMax yMin:(CGFloat)yMin {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.oldStrFrame = [NSMutableArray array];
        self.xTitleArray = xTitleArray;
        self.yValueArray = yValueArray;
        self.yValue2Array = yValue2Array;
        self.yMax = yMax;
        self.yMin = yMin;
        self.longIndex = -1;
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

- (void)setIsLongPress:(BOOL)isLongPress {
    _isLongPress = isLongPress;
    [self setNeedsDisplay];
}

-(void)setLongIndex:(NSInteger)longIndex{
    _longIndex = longIndex;
    [self setNeedsDisplay];
}

/**  解决手势冲突  */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([NSStringFromClass([gestureRecognizer class]) isEqualToString:@"UILongPressGestureRecognizer"]) {
        return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self];
    CGFloat chartHeight = self.frame.size.height - self.bottomHeight - self.topMargin;
    CGFloat totalLength = self.pointGap * self.xTitleArray.count - self.pointGap;
    
    for (NSInteger i = 0; i < self.yValueArray.count; i++) {
        
        CGPoint pointLocation = CGPointMake(self.pointGap + ([self.yValue2Array[i] floatValue])*totalLength,
                                            chartHeight - ([self.yValueArray[i] floatValue]-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
        CGFloat tempLength = pow(fabs(location.x-pointLocation.x),2) + pow(fabs(location.y-pointLocation.y),2);
        //在点的 半径 40个像素内 最小距离的一个点
        if (tempLength < kPointRange) {
//            DLog(@"❌ %@, %@",NSStringFromClass([gestureRecognizer class]), NSStringFromClass([otherGestureRecognizer class]));
            return NO;
        }
    }
//    DLog(@"✅ %@, %@",NSStringFromClass([gestureRecognizer class]), NSStringFromClass([otherGestureRecognizer class]));
    return YES;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    self.oldStrFrame = [NSMutableArray array];
    if (self.yValueArray && self.yValueArray.count > 0) {
        
        for (NSInteger i = 0; i < self.yValueArray.count; i++) {
            
            NSString *startValue = self.yValueArray[i];
            NSString *endValue = nil;
            
            if (i == self.yValueArray.count-1) {
                endValue = self.yValueArray[i];
            }else{
                endValue = self.yValueArray[i+1];
            }
            CGFloat chartHeight = self.frame.size.height - self.bottomHeight - self.topMargin;
            CGPoint startPoint = CGPointMake(self.pointGap + ([self.yValue2Array[i] floatValue])*self.totalLength,
                                             chartHeight -  (startValue.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
            
            
            if (_isShowLabel) {
                //画点上的文字
                NSString *str = [NSString stringWithFormat:@"%.2f", endValue.floatValue];
                // 判断是不是小数
                if ([self isPureFloat:startValue.floatValue]) {
                    str = [NSString stringWithFormat:@"%.0f", startValue.floatValue];
                }
                else {
                    str = [NSString stringWithFormat:@"%.0f", startValue.floatValue];
                }
                
                NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
                CGSize strSize = [str sizeWithAttributes:attr];
                
                CGRect strRect = CGRectMake(startPoint.x-strSize.width/2,
                                            startPoint.y-strSize.height-self.valueTextBottomEdge,
                                            strSize.width,
                                            strSize.height);
                if (i == 0) {
                    if (strRect.origin.x < 0) {
                        strRect.origin.x = 0;
                    }
                    self.firstStrFrame = strRect;
                    [self.oldStrFrame addObject:[NSValue valueWithCGRect:strRect]];
                    
                    //测试
//                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//                    CGContextAddRect(context, strRect);
//                    CGContextFillPath(context);
                    
                    [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],NSForegroundColorAttributeName:self.xyTextColor}];
                }
                
                // 交界点
                if (self.showValuePoint) {
                    CGRect myOval = {startPoint.x-self.showValueWidth/2.0, startPoint.y-self.showValueWidth/2.0, self.showValueWidth, self.showValueWidth};
                    CGContextSetFillColorWithColor(context, self.valuePointColor.CGColor);
                    CGContextAddEllipseInRect(context, myOval);
                    CGContextFillPath(context);
                }
                
                // 如果点的文字有重叠，那么不绘制
//                CGFloat maxX = CGRectGetMaxX(self.firstStrFrame);
//                CGFloat maxY = CGRectGetMaxY(self.firstStrFrame);
//                CGFloat minY = CGRectGetMinY(self.firstStrFrame);
//                CGFloat startMinY = CGRectGetMinY(strRect);
//                CGFloat startMaxY = CGRectGetMaxY(strRect);
                if (i != 0) {
                    
                    BOOL needDrawStr = YES;
                    for (NSValue* oldRectValue in self.oldStrFrame) {
                        CGRect tempRect = [oldRectValue CGRectValue];
                        tempRect.origin.x = tempRect.origin.x-2;
                        tempRect.origin.y = tempRect.origin.y-2;
                        tempRect.size.width = tempRect.size.width+4;
                        tempRect.size.height = tempRect.size.height+4;
                        
                        if (CGRectIntersectsRect(tempRect, strRect)) {
                            needDrawStr = NO;
                            break;
                        }
                    }
                    
                    if (needDrawStr) {
                        //测试
//                        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//                        CGContextAddRect(context, strRect);
//                        CGContextFillPath(context);
                        
                        [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],NSForegroundColorAttributeName:self.xyTextColor}];
                        self.firstStrFrame = strRect;
                        
                        if (self.oldStrFrame.count >= 10) {
                            [self.oldStrFrame removeObjectAtIndex:0];
                        }
                        [self.oldStrFrame addObject:[NSValue valueWithCGRect:strRect]];
                    }
                    
                    
//                    if (((maxX + 5) >= strRect.origin.x)
//                        && ((minY >= startMinY && minY <= startMaxY) || (maxY >= startMinY && maxY <= startMaxY) || (minY <= startMinY || maxY >= startMaxY))
//                        ) {
//                        //不绘制
//
//                    }else{
//                        //测试
//                        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//                        CGContextAddRect(context, strRect);
//                        CGContextFillPath(context);
//
//                        [str drawInRect:strRect withAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:8],NSForegroundColorAttributeName:self.xyTextColor}];
//                        self.firstStrFrame = strRect;
//                    }
                }else {

                }
            }
        }
    }
    if (self.longIndex >= 0 && self.longIndex < self.yValueArray.count) {
        NSNumber *num = self.yValueArray[self.longIndex];
        CGFloat chartHeight = self.frame.size.height - self.bottomHeight - self.topMargin;
        
        CGPoint selectPoint = CGPointMake(self.pointGap + ([self.yValue2Array[self.longIndex] floatValue])*self.totalLength,
                                          //                                              (nowPoint+1)*self.pointGap,
                                          chartHeight -  (num.floatValue-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
        
        CGContextSaveGState(context);
        
        // 交界点
        if (self.tapCanSelect) {
            CGFloat selectPointWidth = self.showValueWidth*1.5;
            CGRect myOval = {selectPoint.x-selectPointWidth/2.0, selectPoint.y-selectPointWidth/2.0, selectPointWidth, selectPointWidth};
            CGContextSetFillColorWithColor(context, self.tapPointColor.CGColor);
            CGContextAddEllipseInRect(context, myOval);
            CGContextFillPath(context);
        }
        
        if (self.isLongPress) {
            //画十字线
            [self drawLine:context
                startPoint:CGPointMake(selectPoint.x, 0)
                  endPoint:CGPointMake(selectPoint.x, self.frame.size.height- self.bottomHeight)
                 lineColor:[UIColor lightGrayColor] lineWidth:1];
            
            [self drawLine:context
                startPoint:CGPointMake(0, selectPoint.y)
                  endPoint:CGPointMake(self.lj_width, selectPoint.y)
                 lineColor:[UIColor lightGrayColor] lineWidth:1];
        }
    }
}

- (void)drawLine:(CGContextRef)context startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)width {
    
    CGContextSetShouldAntialias(context, YES ); //抗锯齿
//    CGColorSpaceRef Linecolorspace1 = CGColorSpaceCreateDeviceRGB();
//    CGContextSetStrokeColorSpace(context, Linecolorspace1);
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
//    CGContextStrokePath(context);
    
    CGFloat normal[]={10, 6};
    CGContextSetLineDash(context,0,normal,2); //画实线
    CGContextDrawPath(context, kCGPathStroke);
//    CGColorSpaceRelease(Linecolorspace1);
}

// 判断是小数还是整数
- (BOOL)isPureFloat:(CGFloat)num {
    int i = num;
    
    CGFloat result = num - i;
    
    // 当不等于0时，是小数
    return result != 0;
}



@end
