//
//  LJButton-Google.h
//  LJAnimation
//
//  Created by LiJie on 16/8/10.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJButton_Google : UIButton

/**  圆圈动画效果颜色  默认白色*/
@property(nonatomic, strong)UIColor* circleEffectColor;

/**  动画时间默认0.35秒 */
@property(nonatomic, assign)CGFloat  circleEffectTime;
/**  开始点击时，显示的半径 默认15 */
@property(nonatomic, assign)CGFloat  beginRadius;

@end
