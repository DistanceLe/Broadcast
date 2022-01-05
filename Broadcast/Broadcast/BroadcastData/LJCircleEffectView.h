//
//  LJCircleEffectView.h
//  Broadcast
//
//  Created by lijie on 2021/12/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJCircleEffectView : UIView


/**  圆圈动画效果颜色  默认白色*/
@property(nonatomic, strong)UIColor* circleEffectColor;

/**  动画时间默认0.35秒 */
@property(nonatomic, assign)CGFloat  circleEffectTime;
/**  开始时，显示的半径 默认15 */
@property(nonatomic, assign)CGFloat  beginRadius;
/**  结束时，显示的半径 默认100 */
@property(nonatomic, assign)CGFloat  endRadius;


-(void)startCircleEffectFromPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
