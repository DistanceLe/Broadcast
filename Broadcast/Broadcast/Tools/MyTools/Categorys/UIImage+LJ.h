//
//  UIImage+LJ.h
//  LJSecretMedia
//
//  Created by LiJie on 16/8/8.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (LJ)


+ (UIImage *)zt_imageWithPureColor:(UIColor *)color;
+ (UIImage *)zt_imageWithPureColor:(UIColor *)color size:(CGSize )size;

/**
 *  从给定UIView中截图：UIView转UIImage
 */
+(UIImage *)cutFromView:(UIView *)view;

/**
 *  直接截屏
 */
+(UIImage *)cutScreen;
/**
 *  从给定UIImage和指定Frame截图：
 */
-(UIImage *)cutWithFrame:(CGRect)frame;

/**  设置图片圆角,效率高，不会造成卡顿 */
-(UIImage*)cutCircleImage;

@end
