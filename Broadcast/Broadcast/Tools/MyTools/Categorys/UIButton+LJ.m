//
//  UIButton+LJ.m
//  LJTrack
//
//  Created by LiJie on 16/6/14.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "UIButton+LJ.h"
#import <objc/runtime.h>

@interface UIButton ()

@property(nonatomic, strong)LJButHandler tempBlock;

@property (nonatomic,assign) NSTimeInterval custom_acceptEventTime;
@end

@implementation UIButton (LJ)


static char blockKey;
-(void)setTempBlock:(LJButHandler)tempBlock
{
    objc_setAssociatedObject(self, &blockKey, tempBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(LJButHandler)tempBlock
{
    return objc_getAssociatedObject(self, &blockKey);
}

-(void)addTargetClickHandler:(LJButHandler)handler
{
    self.tempBlock=handler;
    [self addTarget:self action:@selector(LJClickAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)LJClickAction:(UIButton*)but
{
    self.tempBlock(but, @(but.selected));
}



+(void)load{
    
    //    SEL sysSEL = @selector(sendAction:to:forEvent:);
    //    Method systemMethod = class_getInstanceMethod([UIButton class], sysSEL);
    //
    //    SEL customSEL = @selector(custom_sendAction:to:forEvent:);
    //    Method customMethod = class_getInstanceMethod([UIButton class], customSEL);
    //
    //    method_exchangeImplementations(systemMethod, customMethod);
    
    
    Method setText =class_getInstanceMethod([UIButton class], @selector(sendAction:to:forEvent:));
    Method setTextMySelf =class_getInstanceMethod([UIButton class],@selector(custom_sendAction:to:forEvent:));
    
    IMP setTextImp =method_getImplementation(setText);
    IMP setTextMySelfImp =method_getImplementation(setTextMySelf);
    
    BOOL didAddMethod = class_addMethod([UIButton class], @selector(sendAction:to:forEvent:), setTextMySelfImp, method_getTypeEncoding(setTextMySelf));
    
    if (didAddMethod) {
        class_replaceMethod([UIButton class], @selector(custom_sendAction:to:forEvent:), setTextImp, method_getTypeEncoding(setText));
    }else{
        method_exchangeImplementations(setText, setTextMySelf);
    }
    
}


#pragma mark ----- 用于替换系统方法的自定义方法

- (void)custom_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    // 是否小于设定的时间间隔
    BOOL needSendAction = (fabs(NSDate.date.timeIntervalSince1970 - self.custom_acceptEventTime) >= self.custom_acceptEventInterval);
    // 更新上一次点击时间戳
    if (![self isMemberOfClass:[UIButton class]]) {
        needSendAction = YES;
    }
    if (self.custom_acceptEventInterval > 0 && needSendAction) {
        self.custom_acceptEventTime = NSDate.date.timeIntervalSince1970;
    }
    
    if (needSendAction) {
        // 两次点击的时间间隔小于设定的时间间隔时，才执行响应事件
        [self custom_sendAction:action to:target forEvent:event];
    }
}

- (NSTimeInterval )custom_acceptEventTime{
    
    NSTimeInterval temp = [objc_getAssociatedObject(self, "UIControl_acceptEventTime") doubleValue];
    return temp;
}

- (void)setCustom_acceptEventTime:(NSTimeInterval)custom_acceptEventTime{
    
    objc_setAssociatedObject(self, "UIControl_acceptEventTime", @(custom_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}


#pragma mark ------ 关联

- (NSTimeInterval )custom_acceptEventInterval{
    
    //    return 0.2;
    NSTimeInterval temp = [objc_getAssociatedObject(self, "UIControl_acceptEventInterval") doubleValue];
    return (temp < 0.001 ? 0.2 : temp);
}

- (void)setCustom_acceptEventInterval:(NSTimeInterval)custom_acceptEventInterval{
    
    objc_setAssociatedObject(self, "UIControl_acceptEventInterval", @(custom_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
