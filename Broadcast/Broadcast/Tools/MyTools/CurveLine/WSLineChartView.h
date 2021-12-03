//
//  WSLineChartView.h
//  WSLineChart
//
//  Created by iMac on 16/11/17.
//  Copyright © 2016年 zws. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XAxisView;

@interface WSLineChartView : UIView

/**  曲线颜色 默认红色*/
@property(nonatomic, strong)UIColor* lineColor;

/**  xy轴 线的颜色  默认白色半透明*/
@property(nonatomic, strong)UIColor* xyLineColor;
/**  横向指示线的颜色，默认和xy轴颜色一样 */
@property(nonatomic, strong)UIColor* horizontalLineColor;

/**  xy轴文字的颜色 默认白色半透明*/
@property(nonatomic, strong)UIColor* xyTextColor;

/**  x轴背景色， 默认透明 */
@property(nonatomic, strong)UIColor* xAxisBackColor;
/**  y轴背景色， 默认透明 */
@property(nonatomic, strong)UIColor* yAxisBackColor;

/**  左边的边缘 默认30 */
@property(nonatomic, assign)CGFloat leftMargin;
@property(nonatomic, assign)CGFloat rightMargin;

/**  顶部的留白 默认30 */
@property(nonatomic, assign)CGFloat topMargin;

/**  y轴 分为几段， 默认5段 */
@property(nonatomic, assign)CGFloat yAxisElements;

/**  X轴文字 与坐标间隙，默认5 */
@property(nonatomic, assign)CGFloat xAxisAndTextInterval;

/**  点之间的最大距离  默认50*/
@property (nonatomic, assign)CGFloat pointInterval;

/**  是否显示Y轴 单位，默认显示 */
@property(nonatomic, assign)BOOL showYUnit;
/**  是否显示X轴 单位，默认不显示 */
@property(nonatomic, assign)BOOL showXUnit;
/**  是否显示点上面的文字 默认NO */
@property (assign,nonatomic)BOOL showValueText;
/**  点上面的文字，距离点多远，默认 5 */
@property (assign,nonatomic)CGFloat valueTextBottomEdge;

/**  是否显示 交界点 默认显示 */
@property (assign, nonatomic)BOOL showValuePoint;
/**  交界点的 直径，默认 4 */
@property (assign, nonatomic)CGFloat showValueWidth;
/**  交界点的颜色 默认 橘红色 */
@property (strong, nonatomic)UIColor* valuePointColor;
/**  交界点 选中时的颜色 默认 橘红色 */
@property (strong, nonatomic)UIColor* tapPointColor;


/**  是否显示无数据时的图片 默认不显示NO */
@property(nonatomic, assign)BOOL showEmptyImageView;
/**  无数据时的图片 */
@property(nonatomic, strong)UIImage* emptyBackImage;
@property(nonatomic, strong)UIColor* emptyLabelColor;

/**  首尾是否 相等，默认NO */
@property(nonatomic, assign)BOOL beganEqualEnd;
/**  第一个点 是否可以 左右移动，默认YES */
@property(nonatomic, assign)BOOL firstPointCanMove;
@property(nonatomic, assign)BOOL endPointCanMove;

/**  最后一个点 能不能上下移动  默认YES*/
@property(nonatomic, assign)BOOL endPointCanVerticalMove;
/**  第二个点的最小值， 默认为 最小的 yMin*/
@property(nonatomic, assign)NSInteger secondPointMinValue;


/**  是否溢出0和最大值区域  默认NO  曲线顶到Y轴*/
@property(nonatomic, assign)BOOL fullToOverflow;
/**  头部是否需要 顶到头 默认YES */
@property(nonatomic, assign)BOOL beagnNeedFull;
/**  尾部是否需要 画到底 默认YES*/
@property(nonatomic, assign)BOOL endNeedFull;

/**  在倒数第二个 插入一个空的点  默认NO*/
@property(nonatomic, assign)BOOL needLastSecondPoint;

/**  X轴的值是否可以相等， 默认YES */
@property(nonatomic, assign)BOOL canEqualX;
/**  最小的单位 比例，(两个点之间的间隔 50/1000 表示最小间隔值是50)  1/1000  表示X轴的值是0~1000，间隔1 */
@property(nonatomic, assign)CGFloat minXUnitValue;

/**  点击点，是否表示选中 默认 NO*/
@property(nonatomic, assign)BOOL tapCanSelect;
/**  长按 是否 增加一个点 默认 NO */
@property(nonatomic, assign)BOOL longPressCanAdd;
/**  是否可以滑动点 默认YES*/
@property(nonatomic, assign)BOOL panGestureEnable;

@property(nonatomic, assign)NSInteger maxPointCount;

@property (strong, nonatomic) XAxisView *xAxisView;
/**  X轴的 文字高度 */
@property (assign, nonatomic) CGFloat bottomHeight;

/**  Y轴每一个单位的大小， 默认1 */
@property(nonatomic, assign)NSInteger yOneUnitValue;
/**  X轴每一个单位的大小 比例，  5/1000  表示X轴的值是0~1000, 每5取一个值 */
//@property(nonatomic, assign)CGFloat xOneUnitValue;

@property(nonatomic, strong) void(^valueChangeHandler)(id changeValue, id changeValue2, NSInteger index);

-(void)setSelectTapIndex:(NSInteger)tapIndex;



/**  虚线的颜色 */
@property (strong, nonatomic)UIColor* virtualColor;
/**   X轴上对应的值(按照百分比来 设置) 虚线 比较淡的线条 */
@property(nonatomic, strong)NSArray* virtualXArray;
/**  表示对应Y轴的值 */
@property(nonatomic, strong)NSArray* virtualYArray;
@property (assign, nonatomic) CGFloat virtualYMin;
@property (assign, nonatomic) CGFloat virtualYMax;
@property (assign, nonatomic) BOOL showVirtualYUnit;
@property(nonatomic, strong)NSString* virtualUnitStr;


/**  点 可以 左右上下 移动， yValue  表示对应Y轴的值， yValue2表示 X轴上对应的值(按照百分比来 设置) */
-(void)setxTitleArray:(NSArray*)xTitleArray
          yValueArray:(NSArray*)yValueArray
         yValue2Array:(NSArray*)yValue2Array
                 yMax:(CGFloat)yMax
                 yMin:(CGFloat)yMin
                xUnit:(NSString*)XUnit
                yUnit:(NSString*)yUnit
                empty:(BOOL)empty
            animation:(BOOL)animation;




@end
