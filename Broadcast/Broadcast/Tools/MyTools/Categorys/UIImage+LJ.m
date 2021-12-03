//
//  UIImage+LJ.m
//  LJSecretMedia
//
//  Created by LiJie on 16/8/8.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "UIImage+LJ.h"

@implementation UIImage (LJ)


+ (UIImage *)zt_imageWithPureColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(3, 3), NO, [UIScreen mainScreen].scale);
    UIBezierPath* p = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 3, 3)];
    [color setFill];
    [p fill];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    return img;
}
+ (UIImage *)zt_imageWithPureColor:(UIColor *)color size:(CGSize )size{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIBezierPath* p = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    [color setFill];
    [p fill];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    return img;
}



/*
 *  直接截屏
 */
+(UIImage *)cutScreen{
    return [self cutFromView:[kDataManager getRootWindws]];
}

+(UIImage *)cutFromView:(UIView *)view{
    
    //开启图形上下文
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0f);
    
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //在新建的图形上下文中渲染view的layer
    [view.layer renderInContext:context];
    
    [[UIColor clearColor] setFill];
    
    //获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭图形上下文
    UIGraphicsEndImageContext();
    
    return image;
    
}

-(UIImage *)cutWithFrame:(CGRect)frame{
    
    //创建CGImage
    CGImageRef cgimage = CGImageCreateWithImageInRect(self.CGImage, frame);
    
    //创建image
    UIImage *newImage=[UIImage imageWithCGImage:cgimage];
    
    //释放CGImage
    CGImageRelease(cgimage);
    
    return newImage;
    
    
}


-(UIImage *)cutCircleImage{
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    //获取上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGRect rect=CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(context, rect);
    
    //裁剪
    CGContextClip(context);
    
    //将图片画上去
    [self drawInRect:rect];
    UIImage* image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
