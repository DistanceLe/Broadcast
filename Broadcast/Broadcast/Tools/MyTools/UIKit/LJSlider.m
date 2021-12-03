//
//  LJSlider.m
//  Hytronik
//
//  Created by lijie on 2018/4/28.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import "LJSlider.h"

@interface LJSlider()

@property(nonatomic, strong)void(^touchEndHandler)(CGFloat endValue);
@property(nonatomic, strong)void(^valueChangeHandler)(CGFloat value);

@property(nonatomic, strong)UIView* valueBackView;

@property(nonatomic, strong)UIImageView* valueBackImageView;
@property(nonatomic, strong)UILabel* valueBackLabel;

@property(nonatomic, assign)BOOL showBackValue;
@property(nonatomic, assign)BOOL isChangeValue;
@property(nonatomic, assign)BOOL isSliding;

@end


@implementation LJSlider

#define valueBackY -40
#define valueBackWidth 40
#define valueBackHeight 30

//#define sliderInterval 15.5 //小圆球直径31
#define sliderInterval 10 //自定义小圆球直径20

/**  滑动间隔 interval 秒 才回调slider的值， 即滑动太快，不响应， 最后的值 一定会回调 */
-(void)valueChangeInterval:(CGFloat)interval callBack:(void (^)(CGFloat))handler{
    if (interval > 0) {
        self.valueInterval = interval;
        self.valueChangeHandler = handler;
        [self addTarget:self action:@selector(LJSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
}

-(void)LJSliderValueChange:(UISlider*)slider{
    self.isChangeValue = YES;
    [self performSelector:@selector(slideHanlderChange) withObject:nil afterDelay:self.valueInterval];
}

-(void)setCustomThumbImage:(UIImage *)customThumbImage{
    _customThumbImage = customThumbImage;
    [self setThumbImage:customThumbImage forState:UIControlStateNormal];
    [self setThumbImage:customThumbImage forState:UIControlStateHighlighted];
}

-(void)slideHanlderChange{
    @synchronized (self) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slideHanlderChange) object:nil];
//        [self performSelector:@selector(slideHanlderChange) withObject:nil afterDelay:self.valueInterval];
        if (self.isCCT100Unit) {
            int tempValue = (int)self.value;
            tempValue = (tempValue/100)*100;
            if (self.valueChangeHandler) {
                self.valueChangeHandler(tempValue);
            }
        }else{
            if (self.valueChangeHandler) {
                self.valueChangeHandler(self.value);
            }
        }
    }
}

-(void)setShowValueViewBackColor:(UIColor*)backColor textColor:(UIColor*)textColor{
    
    self.showBackValue = YES;
    self.valueBackView.hidden = YES;
    self.layer.masksToBounds = NO;
    self.valueBackImageView.tintColor = backColor;
    self.valueBackLabel.textColor = textColor;
}

-(UIView *)valueBackView{
    if (!_valueBackView) {
        _valueBackView = [[UIView alloc]initWithFrame:CGRectMake([self getCurrentX], valueBackY, valueBackWidth, valueBackHeight)];
        _valueBackView.backgroundColor = [UIColor clearColor];
        _valueBackView.userInteractionEnabled = NO;
        
        
        _valueBackImageView = [[UIImageView alloc]initWithFrame:_valueBackView.bounds];
        _valueBackImageView.image = [[UIImage imageNamed:@"sliderValue"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_valueBackView addSubview:_valueBackImageView];
        
        _valueBackLabel = [[UILabel alloc]initWithFrame:_valueBackView.bounds];
        _valueBackLabel.textAlignment = NSTextAlignmentCenter;
        _valueBackLabel.font = [UIFont systemFontOfSize:14];
        [_valueBackView addSubview:_valueBackLabel];
        
        
        [self addSubview:_valueBackView];
    }
    
    return _valueBackView;
}

-(CGFloat)getCurrentX{
    CGFloat sliderWidth = self.frame.size.width-sliderInterval*2;
    CGFloat persent = (self.value - self.minimumValue)/(self.maximumValue - self.minimumValue);
    if (self.maximumValue - self.minimumValue == 0) {
        persent = 0;
    }
    
    CGFloat x = sliderWidth * persent - valueBackWidth/2.0;
    return x+sliderInterval;
}



-(void)changeBackValue{
    if (self.isCCT100Unit) {
        int tempValue = (int)self.value;
        tempValue = (tempValue/100)*100;
        self.valueBackLabel.text = [NSString stringWithFormat:@"%d", tempValue];
    }else{
        float tempValue = self.value;
        //换算 显示 的值，对数
        if (self.isLogarithm) {
//            float power = ((tempValue*2.54-1)/(253/3.0)-1);
            float power = ((tempValue*655.35-1)/(65534/3.0)-1);
            tempValue = powf(10, power);
        }
        self.valueBackLabel.text = [NSString stringWithFormat:@"%ld", (long)tempValue];
    }
    
    CGFloat X = [self getCurrentX];
    [UIView animateWithDuration:0.01 animations:^{
        self.valueBackView.frame = CGRectMake(X, valueBackY, valueBackWidth, valueBackHeight);
    }];
}

-(void)hideBackValue{
    if (self.showBackValue) {
        [UIView animateWithDuration:0.3 animations:^{
            self.valueBackView.layer.opacity = 0;
        }completion:^(BOOL finished) {
            if (!self.isSliding) {
                self.valueBackView.hidden = YES;
            }
        }];
    }
}

#pragma mark - ================ touchEnd 回调 ==================
-(void)touchEndCallBack:(void(^)(CGFloat endValue))handler{
    self.touchEndHandler = handler;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter]postNotificationName:sliderTouchBegin object:nil];
    self.isSliding = YES;
    [super touchesBegan:touches withEvent:event];
    if (self.showBackValue) {
        //防止误触碰
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isSliding) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBackValue) object:nil];
                [self changeBackValue];
                self.valueBackView.hidden = NO;
                [UIView animateWithDuration:0.2 animations:^{
                    self.valueBackView.layer.opacity = 1;
                }];
            }
        });
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    if (self.showBackValue) {
        [self changeBackValue];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter]postNotificationName:sliderTouchEnd object:nil];
    self.isSliding = NO;
    self.isChangeValue = NO;
    [super touchesCancelled:touches withEvent:event];
    [self performSelector:@selector(hideBackValue) withObject:nil afterDelay:0.1];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slideHanlderChange) object:nil];
    DLog(@"❌ slider cancel");
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter]postNotificationName:sliderTouchEnd object:nil];
    self.isSliding = NO;
    [super touchesEnded:touches withEvent:event];
    if (self.isChangeValue) {
        if (self.isCCT100Unit) {
            int tempValue = (int)self.value;
            tempValue = (tempValue/100)*100;
            if (self.touchEndHandler) {
                self.touchEndHandler(tempValue);
            }
        }else{
            if (self.touchEndHandler) {
                self.touchEndHandler(self.value);
            }
        }
        
        if (self.valueChangeHandler) {
            DLog(@"😁 end value:%.2f", self.value);
            //结束滑动了，先清空命令
//            [KCmdManager cleanCmd];
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slideHanlderChange) object:nil];
            if (self.isCCT100Unit) {
                int tempValue = (int)self.value;
                tempValue = (tempValue/100)*100;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.valueChangeHandler) {
                        self.valueChangeHandler(tempValue);
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.valueInterval*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.valueChangeHandler(tempValue);
                        });
                    }
                });
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (self.valueChangeHandler) {
                        self.valueChangeHandler(self.value);
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.valueInterval*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.valueChangeHandler(self.value);
                        });
                    }
                });
            }
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slideHanlderChange) object:nil];
        });
    }
    [self performSelector:@selector(hideBackValue) withObject:nil afterDelay:0.1];
    self.isChangeValue = NO;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self) {
        return NO;
    }
    return YES;
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view != self &&
        ![gestureRecognizer.view isMemberOfClass:[UICollectionView class]] &&
        ![gestureRecognizer.view isMemberOfClass:[UITableView class]]) {
        return NO;
    }
    return YES;
}



#pragma mark - ================ 继承的方法 ==================
-(CGRect)trackRectForBounds:(CGRect)bounds{
    bounds = [super trackRectForBounds:bounds];
    if (self.lineHeight) {
        bounds.size.height = self.lineHeight;
    }
    return bounds;
}










@end




















