//
//  LJCreateQRCode.h
//  二维码
//
//  Created by LiJie on 2017/1/12.
//  Copyright © 2017年 celink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LJCreateQRCode : NSObject

/**  生成一张普通的二维码， 正方形的， 自定义宽度 */
+(UIImage*)createGenerateQRImageFromString:(NSString*)dataStr imageWidth:(CGFloat)width;

/**  生成一张 中间 带有logo的 二维码*/
+(UIImage*)createLogoQRImageFromString:(NSString*)dataStr logoImage:(UIImage*)logoImage imageWidth:(CGFloat)width;

/**  生成一张 彩色的二维码 */
+(UIImage*)createColorQRImageFromString:(NSString*)dataStr bgColor:(UIColor*)bgColor QRColor:(UIColor*)QRColor imageWidth:(CGFloat)width;

/**  生成一张 带有logo的彩色 二维码 */
+(UIImage*)createLogoAndColorQRImageFromString:(NSString*)dataStr logoImage:(UIImage*)logoImage bgColor:(UIColor*)bgColor QRColor:(UIColor*)QRColor imageWidth:(CGFloat)width;

@end
