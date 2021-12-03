//
//  YAxisView.h
//  WSLineChart
//
//  Created by iMac on 16/11/17.
//  Copyright © 2016年 zws. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YAxisView : UIView

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

/**  画左边 Y轴的视图，有刻度 和 单位 */
- (id)initWithFrame:(CGRect)frame yMax:(CGFloat)yMax yMin:(CGFloat)yMin;



@end
