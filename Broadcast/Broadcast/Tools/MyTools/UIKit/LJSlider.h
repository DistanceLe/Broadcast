//
//  LJSlider.h
//  Hytronik
//
//  Created by lijie on 2018/4/28.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJSlider : UISlider

@property(nonatomic, strong)IBInspectable UIImage* customThumbImage;
@property(nonatomic, assign)IBInspectable CGFloat lineHeight;

@property(nonatomic, assign)CGFloat valueInterval;

/**  是否是对数，默认不是，对数的话显示 要换算一下 */
@property(nonatomic, assign)BOOL isLogarithm;

/**  是否是色温，需要已100 为单位 */
@property(nonatomic, assign)BOOL isCCT100Unit;

/**  滑动间隔 interval 秒 才回调slider的值， 即滑动太快，不响应， 最后的值 一定会回调 */
-(void)valueChangeInterval:(CGFloat)interval callBack:(void(^)(CGFloat value))handler;


/**  结束触摸后 发送回调 */
-(void)touchEndCallBack:(void(^)(CGFloat endValue))handler;


/**  设置 要显示的 值视图 */
-(void)setShowValueViewBackColor:(UIColor*)backColor textColor:(UIColor*)textColor;


@end
