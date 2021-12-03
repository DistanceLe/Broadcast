//
//  XTextView.h
//  LJTrack
//
//  Created by LiJie on 2017/11/18.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>


/**  每个点可以点击的范围 50*50 */
static uint16_t const kPointRange = 2500;

@interface XTextView : UIView<UIGestureRecognizerDelegate>


@property(nonatomic, strong)NSString* XunitStr;
@property(nonatomic, strong)NSString* YunitStr;

/**  点之间的距离  默认23*/
@property (assign, nonatomic) CGFloat pointGap;
/**  顶部的留白 默认30 */
@property(nonatomic, assign)CGFloat topMargin;
/**  左边的边缘 默认45 */
@property(nonatomic, assign)CGFloat leftMargin;

/**  xy轴文字的颜色 默认白色半透明*/
@property(nonatomic, strong)UIColor* xyTextColor;


/**  是否显示点上面的文字 默认NO */
@property (assign,nonatomic)BOOL isShowLabel;
/**  点上面的文字，距离点多远，默认 5 */
@property (assign,nonatomic)CGFloat valueTextBottomEdge;

/**  是否显示 交界点 */
@property (assign, nonatomic)BOOL showValuePoint;
/**  交界点的 直径，默认 4 */
@property (assign, nonatomic)CGFloat showValueWidth;
/**  交界点的颜色 默认 橘红色 */
@property (strong, nonatomic)UIColor* valuePointColor;
/**  交界点的颜色 默认 橘红色 */
@property (strong, nonatomic)UIColor* tapPointColor;

@property (nonatomic, assign)BOOL showAnimation;//是否有动画

@property (assign,nonatomic)BOOL tapCanSelect;//是不是可以点击
@property (assign,nonatomic)BOOL isLongPress;//是不是长按状态
//@property (assign, nonatomic) CGPoint currentLoc; //长按时当前定位位置
@property (assign, nonatomic) NSInteger longIndex; //长按时的点

/**  X轴的 文字高度 */
@property (assign, nonatomic) CGFloat bottomHeight;

/**  画 交界点，和点上的文字，十字线 的视图*/
- (id)initWithFrame:(CGRect)frame
        xTitleArray:(NSArray*)xTitleArray
        yValueArray:(NSArray*)yValueArray
       yValue2Array:(NSArray*)yValue2Array
               yMax:(CGFloat)yMax
               yMin:(CGFloat)yMin;



- (void)refreshLineWithValueArray:(NSArray*)yValueArray yValue2Array:(NSArray*)yValue2Array;









@end
