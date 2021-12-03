//
//  UISlider+LJ.h
//  Hytronik
//
//  Created by lijie on 2018/4/28.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISlider (LJ)

-(void)touchEndCallBack:(void(^)(CGFloat endValue))handler;

@end
