//
//  LJCircleEffectView.m
//  Broadcast
//
//  Created by lijie on 2021/12/28.
//

#import "LJCircleEffectView.h"

@interface LJCircleEffectView ()<CAAnimationDelegate>

@property(nonatomic, strong)NSMutableArray* backLayersArray;

@end

@implementation LJCircleEffectView


-(UIColor *)circleEffectColor{
    if (!_circleEffectColor) {
        _circleEffectColor=[UIColor whiteColor];
    }
    return _circleEffectColor;
}

-(CGFloat)circleEffectTime{
    if (_circleEffectTime<0.00001) {
        _circleEffectTime=0.35;
    }
    return _circleEffectTime;
}
-(CGFloat)beginRadius{
    if (_beginRadius<0.00001) {
        _beginRadius=1;
    }
    return _beginRadius;
}
-(CGFloat)endRadius{
    if (_endRadius<0.00001) {
        _endRadius=100;
    }
    return _endRadius;
}


-(void)startCircleEffectFromPoint:(CGPoint)point{
    [self.circleEffectColor setFill];
    
    if (!self.backLayersArray) {
        self.backLayersArray = [NSMutableArray array];
    }
    
    CALayer* backLayer=[CALayer layer];
    backLayer.backgroundColor=self.circleEffectColor.CGColor;
    backLayer.frame=self.bounds;
    [self.layer insertSublayer:backLayer atIndex:0];
    
    CALayer* maskLayer=[CALayer layer];
    maskLayer.contents=(id)[self getImageForColor].CGImage;
    maskLayer.bounds=self.bounds;
    maskLayer.position=point;
    maskLayer.masksToBounds=YES;
    backLayer.mask=maskLayer;
    
    
    CGFloat radius = self.endRadius;
    CGFloat beginRadius = self.beginRadius;
    
    CAKeyframeAnimation* cornerAnimation=[CAKeyframeAnimation animationWithKeyPath:@"cornerRadius"];
    cornerAnimation.duration=self.circleEffectTime;
    cornerAnimation.values=@[@(beginRadius), @(radius)];
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
    keyAnimation.values=@[[NSValue valueWithCGRect:CGRectMake(0, 0, beginRadius*2, beginRadius*2)],
                          [NSValue valueWithCGRect:CGRectMake(0, 0, radius*2, radius*2)]];
    keyAnimation.keyTimes=@[@0, @1];
    keyAnimation.fillMode=kCAFillModeForwards;
    keyAnimation.removedOnCompletion=NO;
    keyAnimation.delegate=self;
    [backLayer.mask addAnimation:keyAnimation forKey:nil];
    [self.backLayersArray addObject:backLayer];
}
#pragma mark - ================ 动画代理 ==================
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
//        DLog(@"停止动画==============");
        if (!self.backLayersArray.count) {
            return;
        }
        CALayer* backLayer = self.backLayersArray.firstObject;
        if (backLayer && backLayer.mask) {
//            DLog(@"移除最旧的 图层, %ld", self.backLayersArray.count);
            [backLayer.mask removeAllAnimations];
            backLayer.mask=nil;
            [backLayer removeFromSuperlayer];
            [self.backLayersArray removeObject:backLayer];
        }
    }
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
