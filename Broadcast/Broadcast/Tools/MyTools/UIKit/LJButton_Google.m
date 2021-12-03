//
//  LJButton-Google.m
//  LJAnimation
//
//  Created by LiJie on 16/8/10.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import "LJButton_Google.h"
//#import "UIView+LJ.h"

#define Radius      (_beginRadius > 0 ? _beginRadius : 15)


@interface LJButton_Google ()<CAAnimationDelegate>

@property(nonatomic, assign)CGPoint     currentTouchPoint;
@property(nonatomic, assign)BOOL        isTouchBegin;
@property(nonatomic, assign)BOOL        isTouchContinue;
@property(nonatomic, assign)BOOL        isOtherGesture;
@property(nonatomic, assign)double      touchBeginTime;

@property(nonatomic, strong)NSMutableDictionary* backLayersDic;
@property(nonatomic, strong)NSMutableArray* animationsArray;
@property(nonatomic, strong)NSMutableArray* backLayersArray;

@end

@implementation LJButton_Google

-(UIColor *)circleEffectColor{
    if (!_circleEffectColor) {
        _circleEffectColor=[UIColor whiteColor];
    }
    return _circleEffectColor;
}

-(CGFloat)circleEffectTime{
    if (_circleEffectTime<0.001) {
        _circleEffectTime=0.35;
    }
    return _circleEffectTime;
}

-(void)drawRect:(CGRect)rect{
    
}

-(void)beginAnimation{
    [self.circleEffectColor setFill];
    if (1) {
        if (!self.backLayersDic) {
            self.backLayersDic = [NSMutableDictionary dictionary];
            self.animationsArray = [NSMutableArray array];
            self.backLayersArray = [NSMutableArray array];
        }
        
        CALayer* backLayer=[CALayer layer];
        backLayer.backgroundColor=self.circleEffectColor.CGColor;
        backLayer.frame=self.bounds;
        [self.layer insertSublayer:backLayer atIndex:0];
        
        CALayer* maskLayer=[CALayer layer];
        maskLayer.contents=(id)[self getImageForColor].CGImage;
        maskLayer.bounds=self.bounds;
        maskLayer.position=_currentTouchPoint;
        maskLayer.masksToBounds=YES;
        backLayer.mask=maskLayer;
        
        
        CGFloat radius=sqrt(pow(MAX(_currentTouchPoint.x, self.lj_width-_currentTouchPoint.x), 2)+
                            pow(MAX(_currentTouchPoint.y, self.lj_height-_currentTouchPoint.y), 2));
        CAKeyframeAnimation* cornerAnimation=[CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
        cornerAnimation.duration=self.circleEffectTime;
        cornerAnimation.values=@[@(Radius), @(radius)];
        cornerAnimation.keyTimes=@[@0, @1];
        cornerAnimation.fillMode=kCAFillModeForwards;
        cornerAnimation.removedOnCompletion=NO;
        [backLayer.mask addAnimation:cornerAnimation forKey:nil];
        
        CAKeyframeAnimation* opacityAnimation=[CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.duration=self.circleEffectTime;
        opacityAnimation.values=@[@(0.8), @(0.2), @(0.3)];
        opacityAnimation.keyTimes=@[@0, @0.99, @1];
        opacityAnimation.fillMode=kCAFillModeForwards;
        opacityAnimation.removedOnCompletion=NO;
        [backLayer.mask addAnimation:opacityAnimation forKey:nil];
        
        CAKeyframeAnimation* keyAnimation=[CAKeyframeAnimation animationWithKeyPath:@"bounds"];
        keyAnimation.duration=self.circleEffectTime;
        keyAnimation.values=@[[NSValue valueWithCGRect:CGRectMake(0, 0, Radius*2, Radius*2)],
                              [NSValue valueWithCGRect:CGRectMake(0, 0, radius*2, radius*2)]];
        keyAnimation.keyTimes=@[@0, @1];
        keyAnimation.fillMode=kCAFillModeForwards;
        keyAnimation.removedOnCompletion=NO;
        keyAnimation.delegate=self;
        [backLayer.mask addAnimation:keyAnimation forKey:nil];
        [self.backLayersArray addObject:backLayer];
    }
}

#pragma mark - ================ 动画代理 ==================
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        //        NSLog(@"停止动画==============");
        if (!self.backLayersArray.count || (self.backLayersArray.count == 1 && self.isTouchBegin)) {
            return;
        }
        CALayer* backLayer = self.backLayersArray.firstObject;
        if (backLayer && backLayer.mask) {
            [backLayer.mask removeAllAnimations];
            backLayer.mask=nil;
            [backLayer removeFromSuperlayer];
            [self.backLayersArray removeObject:backLayer];
        }
    }
}
-(void)customTrackingEnd{
    self.isTouchBegin=NO;
    self.isTouchContinue = NO;
    double endTouchTime = [[NSDate date]timeIntervalSince1970];
    if ((endTouchTime - self.touchBeginTime) < self.circleEffectTime) {
        return;
    }
    if (self.backLayersArray.count) {
        NSArray* tempArray = [NSArray arrayWithArray:self.backLayersArray];
        for (CALayer* backLayer in tempArray) {
            [backLayer.mask removeAllAnimations];
            backLayer.mask=nil;
            [backLayer removeFromSuperlayer];
            [self.backLayersArray removeObject:backLayer];
        }
    }
}

#pragma mark - ================ 触摸代理 ==================
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (touch.view == self && !self.isOtherGesture) {
        self.currentTouchPoint=[touch locationInView:self];
        self.isTouchBegin=YES;
        self.touchBeginTime = [[NSDate date]timeIntervalSince1970];
        //DLog(@"😝开始动画");
        [self beginAnimation];
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (touch.view == self) {
        //        NSLog(@"==============");
        self.isTouchContinue=YES;
        CGPoint point=[touch locationInView:self];
        CGFloat offset=70;
        if (point.x<-offset || point.x>self.lj_width+offset || point.y<-offset || point.y>self.lj_height+offset) {
            
            [self customTrackingEnd];
        }
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if (touch.view == self) {
        [self customTrackingEnd];
    }
    [super endTrackingWithTouch:touch withEvent:event];
}

-(void)cancelTrackingWithEvent:(UIEvent *)event{
    [self customTrackingEnd];
    [super cancelTrackingWithEvent:event];
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    //DLog(@"✅识别到手势：%@ , %@", gestureRecognizer, gestureRecognizer.view);
    if (gestureRecognizer.view != self && ![gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return NO;
    }
    if (gestureRecognizer.view != self) {
        self.isOtherGesture = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isOtherGesture = NO;
        });
    }
    return YES;
}

#pragma mark - ================ 生成一个蒙版图片 ==================
-(UIImage*)getImageForColor{
    CGRect rect=CGRectMake(0.0f, 0.0f, 5, 5);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}




@end
