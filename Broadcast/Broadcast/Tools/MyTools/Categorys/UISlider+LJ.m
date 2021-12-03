//
//  UISlider+LJ.m
//  Hytronik
//
//  Created by lijie on 2018/4/28.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import "UISlider+LJ.h"
#import <objc/runtime.h>


@interface UISlider ()

@property(nonatomic, strong) void(^touchEndHandler)(CGFloat endValue);

@end

@implementation UISlider (LJ)


static char temSliderKey;
-(void)setTouchEndHandler:(void (^)(CGFloat))touchEndHandler{
    objc_setAssociatedObject(self, &temSliderKey, touchEndHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void (^)(CGFloat))touchEndHandler{
    return  objc_getAssociatedObject(self, &temSliderKey);
}



-(void)touchEndCallBack:(void(^)(CGFloat endValue))handler{
    self.touchEndHandler = handler;
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.touchEndHandler) {
        self.touchEndHandler(self.value);
    }
}



@end
