//
//  UILabel+LJ.h
//  StarWristSport
//
//  Created by LiJie on 2017/4/25.
//  Copyright © 2017年 celink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LJ)

- (void)enableTailInfo:(BOOL)isEnable tailInfo:(NSString*)tailInfo;
- (void)enableTailInfo:(BOOL)isEnable tailInfo:(NSString*)tailInfo image:(UIImage*)image;

- (void)enableTailNotImageWithInfo:(NSString*)tailInfo;

/**  在末尾添加一个图片 */
-(void)addImageToTail:(UIImage*)image;
-(void)addImageToTail:(UIImage*)image andTailString:(NSString*)tailString;

/**  添加一个图片在 最前面 */
-(void)addImageToLead:(UIImage*)image;
-(void)addBigImageToLead:(UIImage*)image width:(CGFloat)width;
@end
