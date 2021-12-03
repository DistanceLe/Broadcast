//
//  XAxisView.h
//  WSLineChart
//
//  Created by iMac on 16/11/17.
//  Copyright © 2016年 zws. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XAxisView : UIView


@property (nonatomic, assign)CGFloat    pointGap;//点之间的距离
@property (nonatomic, assign)BOOL       showAnimation;//是否有动画

@property (nonatomic, strong)UIColor*   lineColor;
@property (nonatomic, strong)UIColor*   line2Color;
@property (nonatomic, strong)UIColor*   line3Color;

/**  顶部的留白 默认30 */
@property(nonatomic, assign)CGFloat topMargin;

/**  xy轴 线的颜色  默认白色半透明*/
@property(nonatomic, strong)UIColor* xyLineColor;

/**  横向指示线的颜色，默认和xy轴颜色一样 */
@property(nonatomic, strong)UIColor* horizontalLineColor;

/**  xy轴文字的颜色 默认白色半透明*/
@property(nonatomic, strong)UIColor* xyTextColor;

/**  左边的边缘 默认45 */
@property(nonatomic, assign)CGFloat leftMargin;

/**  点之间的距离  默认23*/
//@property (nonatomic, assign)CGFloat pointInterval;

/**  y轴 分为几段， 默认5段 */
@property(nonatomic, assign)CGFloat yAxisElements;

/**  X轴的 文字高度 */
@property (assign, nonatomic) CGFloat bottomHeight;

@property(nonatomic, assign)BOOL showUnit;
@property(nonatomic, strong)NSString* XunitStr;


/**  首尾是否 相等，默认NO */
@property(nonatomic, assign)BOOL beganEqualEnd;

/**  是否溢出0和最大值区域  默认NO*/
@property(nonatomic, assign)BOOL fullToOverflow;
/**  头部是否需要 顶到头 默认YES */
@property(nonatomic, assign)BOOL beagnNeedFull;
/**  尾部是否需要 画到底 默认YES*/
@property(nonatomic, assign)BOOL endNeedFull;

/**  在倒数第二个 插入一个空的点 */
@property(nonatomic, assign)BOOL needLastSecondPoint;


/**  虚线的颜色 */
@property (strong, nonatomic)UIColor* virtualColor;
/**   X轴上对应的值(按照百分比来 设置) 虚线 比较淡的线条 */
@property(nonatomic, strong)NSArray* virtualXArray;
/**  表示对应Y轴的值 */
@property(nonatomic, strong)NSArray* virtualYArray;

@property (assign, nonatomic) CGFloat virtualYMin;
@property (assign, nonatomic) CGFloat virtualYMax;

/**  画折线的 视图 */
- (id)initWithFrame:(CGRect)frame
        xTitleArray:(NSArray*)xTitleArray
        yValueArray:(NSArray*)yValueArray
       yValue2Array:(NSArray*)yValue2Array
               yMax:(CGFloat)yMax
               yMin:(CGFloat)yMin;


- (void)refreshLineWithValueArray:(NSArray*)yValueArray yValue2Array:(NSArray*)yValue2Array;

@end
