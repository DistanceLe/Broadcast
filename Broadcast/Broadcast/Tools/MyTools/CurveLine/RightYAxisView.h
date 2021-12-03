//
//  RightYAxisView.h
//  LineChartDemo
//
//  Created by lijie on 2018/9/3.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightYAxisView : UIView


/**  用来判断是否显示 右边的Y轴值和单位 */
@property(nonatomic, assign)BOOL showUnit;
@property(nonatomic, strong)NSString* unitStr;

/**  X轴文字 与坐标间隙，默认5 */
@property(nonatomic, assign)CGFloat xAxisAndTextInterval;

/**  顶部的留白 默认30 */
@property(nonatomic, assign)CGFloat topMargin;

/**  y轴 分为几段， 默认5段 */
@property(nonatomic, assign)CGFloat yAxisElements;

/**  xy轴 线的颜色  默认白色半透明*/
@property(nonatomic, strong)UIColor* xyLineColor;

/**  xy轴文字的颜色 默认白色半透明*/
@property(nonatomic, strong)UIColor* xyTextColor;

/**  X轴的 文字高度 */
@property (assign, nonatomic) CGFloat bottomHeight;


@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;

/**  右边的Y轴 视图 */
- (id)initWithFrame:(CGRect)frame;

@end
