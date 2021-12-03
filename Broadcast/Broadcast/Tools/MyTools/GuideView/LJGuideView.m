//
//  LJGuideView.m
//  DirectShow
//
//  Created by LiJie on 2018/4/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "LJGuideView.h"

#define GuideBackHeight [self.superview bounds].size.height
#define GuideBackWidth [self.superview bounds].size.width

#define kDirectImageName    @"direct"
#define kInterval           18
#define kLabelInterval      10
//#define kGuideBackColor          kSystemColor
#define kGuideTextColor          [UIColor whiteColor]

typedef NS_ENUM(NSUInteger, LJGuideDirect) {
    LJGuideDirectLeftUp = 1,
    LJGuideDirectRightUp,
    LJGuideDirectLeftDown,
    LJGuideDirectRightDown
};

@interface LJGuideView()

@property (nonatomic, assign)LJGuideDirect direct;

@property (weak, nonatomic) IBOutlet UIImageView *directImageView;
@property (weak, nonatomic) IBOutlet UILabel *upLabel;
@property (weak, nonatomic) IBOutlet UILabel *downLabel;
@property (weak, nonatomic) IBOutlet UIImageView *upImageView;
@property (weak, nonatomic) IBOutlet UIImageView *downImageView;
@property (weak, nonatomic) IBOutlet UIView *upShadowView;
@property (weak, nonatomic) IBOutlet UIView *downShadowView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upLead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upTrail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upHeight;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downLead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downTrail;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageLead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTop;

@property (nonatomic, assign)BOOL isShow;

@end


@implementation LJGuideView

-(void)dealloc{
    DLog(@"AppTypeSelectView dealloc");
}
+(instancetype)getGuideView{
    
    LJGuideView* guideView;
    guideView = [[NSBundle mainBundle]loadNibNamed:NSStringFromClass([LJGuideView class]) owner:nil options:nil].lastObject;
    guideView.frame = CGRectMake(0, 0, IPHONE_WIDTH, IPHONE_HEIGHT);
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:guideView action:@selector(tapClick:)];
    [guideView addGestureRecognizer:tap];
    guideView.hidden = YES;
    
    guideView.directImageView.tintColor = kGuideBackColor;
    guideView.upImageView.tintColor = kGuideBackColor;
    guideView.downImageView.tintColor = kGuideBackColor;
    guideView.upLabel.textColor = kGuideTextColor;
    guideView.downLabel.textColor = kGuideTextColor;
    
    guideView.upImageView.image = [[UIImage imageNamed:@"backColor"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    guideView.downImageView.image = [[UIImage imageNamed:@"backColor"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    guideView.upImageView.layer.cornerRadius = 6;
    guideView.downImageView.layer.cornerRadius = 6;
    guideView.upImageView.layer.masksToBounds = YES;
    guideView.downImageView.layer.masksToBounds = YES;
    
    guideView.downShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    guideView.downShadowView.layer.shadowOffset = CGSizeMake(0, 3);
    guideView.downShadowView.layer.shadowRadius = 3;
    guideView.downShadowView.layer.shadowOpacity = 0.5;
    
    
    guideView.upShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    guideView.upShadowView.layer.shadowOffset = CGSizeMake(0, 2);
    guideView.upShadowView.layer.shadowRadius = 2;
    guideView.upShadowView.layer.shadowOpacity = 0.5;
    
    guideView.backgroundColor = [UIColor clearColor];
    guideView.userInteractionEnabled = YES;
    return guideView;
}

/**  在tapView上点击，并显示提示信息 */
-(void)showGuide:(NSString*)guideString onView:(UIView*)tapView canTap:(BOOL)canTap showOnVC:(UIViewController *)viewController{
    [self showGuide:guideString onView:tapView backColor:kGuideBackColor canTap:canTap animation:NO showOnVC:viewController];
}
-(void)showGuide:(NSString*)guideString onView:(UIView*)tapView canTap:(BOOL)canTap animation:(BOOL)animation showOnVC:(UIViewController*)viewController{
    [self showGuide:guideString onView:tapView backColor:kGuideBackColor canTap:canTap animation:animation showOnVC:viewController];
}

-(void)showGuide:(NSString*)guideString onView:(UIView*)tapView backColor:(UIColor*)backColor canTap:(BOOL)canTap showOnVC:(UIViewController *)viewController{
    [self showGuide:guideString onView:tapView backColor:backColor canTap:canTap animation:NO showOnVC:viewController];
}

/**  在tapView上点击，并显示提示信息 */
-(void)showGuide:(NSString*)guideString onView:(UIView*)tapView backColor:(UIColor*)backColor canTap:(BOOL)canTap animation:(BOOL)animation showOnVC:(UIViewController *)viewController{
    
    
    if (self.superview != viewController.view) {
        [viewController.view addSubview:self];
    }
    self.frame = self.superview.bounds;
    if (backColor) {
        self.directImageView.tintColor = backColor;
        self.upImageView.tintColor = backColor;
        self.downImageView.tintColor = backColor;
    }else{
        self.directImageView.tintColor = self.upImageView.tintColor = self.downImageView.tintColor = kGuideBackColor;
    }
    [self showGuide:guideString image:nil onView:tapView animation:animation];
    self.userInteractionEnabled = !canTap;
}
-(void)showGuide:(NSString*)guideString image:(UIImage*)image onView:(UIView*)tapView backColor:(UIColor*)backColor canTap:(BOOL)canTap animation:(BOOL)animation showOnVC:(UIViewController *)viewController{
    
    if (self.superview != viewController.view) {
        [viewController.view addSubview:self];
    }
    self.frame = self.superview.bounds;
    if (backColor) {
        self.directImageView.tintColor = backColor;
        self.upImageView.tintColor = backColor;
        self.downImageView.tintColor = backColor;
    }else{
        self.directImageView.tintColor = self.upImageView.tintColor = self.downImageView.tintColor = kGuideBackColor;
    }
    [self showGuide:guideString image:image onView:tapView animation:animation];
    self.userInteractionEnabled = !canTap;
}

-(void)showGuide:(NSString*)guideString image:(UIImage*)image onView:(UIView*)tapView animation:(BOOL)animation{
    
    [self.superview bringSubviewToFront:self];
    
    CGRect tapRect = [tapView convertRect:tapView.bounds toView:self.superview];
    
    CGSize stringSize = [self calculateSize:guideString fontSize:14];
    if (image) {
        stringSize.height = stringSize.height+stringSize.width*0.5;
    }
    
    CGFloat imageLead = 0;
    CGFloat imageTop = 0;
    CGSize imageSize = self.directImageView.bounds.size;
    CGFloat offset = imageSize.width/2.0;
    imageLead = tapRect.origin.x + tapRect.size.width/2.0 - imageSize.width/2.0;
    
    
    if (tapRect.origin.y + tapRect.size.height/2.0 >= GuideBackHeight/2.0) {
        //上边的情况
        if (tapRect.origin.x + tapRect.size.width/2.0 <= GuideBackWidth/2.0) {
            //左边的情况
            self.direct = LJGuideDirectLeftUp;
            self.upLead.constant = kInterval;
            self.upTrail.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-kInterval;
            imageLead -= offset;
        }else{
            //右边的情况
            self.direct = LJGuideDirectRightUp;
            self.upTrail.constant = kInterval;
            self.upLead.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-kInterval;
            imageLead += offset;
        }
        self.upLabel.hidden = NO;
        self.upImageView.hidden = NO;
        self.upShadowView.hidden = NO;
        self.downLabel.hidden = YES;
        self.downImageView.hidden = YES;
        self.downShadowView.hidden = YES;
        
        imageTop = tapRect.origin.y - imageSize.height;
        self.upLabel.text = guideString;
        if (image) {
            [self.upLabel addBigImageToLead:image width:stringSize.width];
        }
        self.upWidth.constant = stringSize.width + kLabelInterval*2;
        self.upHeight.constant = stringSize.height + kLabelInterval*2;
        
    }else{
        //下边的情况
        if (tapRect.origin.x + tapRect.size.width/2.0 <= GuideBackWidth/2.0) {
            //左边的情况
            self.direct = LJGuideDirectLeftDown;
            self.downLead.constant = kInterval;
            self.downTrail.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-kInterval;
            imageLead -= offset;
        }else{
            //右边的情况
            self.direct = LJGuideDirectRightDown;
            self.downTrail.constant = kInterval;
            self.downLead.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-kInterval;
            imageLead += offset;
        }
        self.upLabel.hidden = YES;
        self.upImageView.hidden = YES;
        self.upShadowView.hidden = YES;
        self.downLabel.hidden = NO;
        self.downImageView.hidden = NO;
        self.downShadowView.hidden = NO;
        imageTop = tapRect.origin.y + tapRect.size.height;
        self.downLabel.text = guideString;
        if (image) {
            [self.downLabel addBigImageToLead:image width:stringSize.width];
        }
        
        self.downWidth.constant = stringSize.width + kLabelInterval*2;
        self.downHeight.constant = stringSize.height + kLabelInterval*2;
    }
    
    //点击的视图 太靠屏幕边缘的两种情况
    CGFloat offsetLead = 0;
    if (imageLead < kInterval+5) {
        //太靠左边了
        if (imageLead < 6) {
            imageLead  = 6;
        }
        offsetLead = imageLead - 5;
        self.upLead.constant = offsetLead;
        self.upTrail.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-offsetLead;
        self.downLead.constant = offsetLead;
        self.downTrail.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-offsetLead;
    }else if (imageLead+offset*2 > GuideBackWidth-kInterval-5){
        //太靠右边了
        if (imageLead+offset*2 > GuideBackWidth - 6) {
            imageLead = GuideBackWidth - 6 - offset*2;
        }
        offsetLead = GuideBackWidth - imageLead - offset*2 - 5;
        self.upTrail.constant = offsetLead;
        self.upLead.constant = GuideBackWidth-kLabelInterval*2-stringSize.width+offsetLead;
        self.downTrail.constant = offsetLead;
        self.downLead.constant = GuideBackWidth-kLabelInterval*2-stringSize.width+offsetLead;
    }
    
    //字数太少的 四种情况
    if (imageLead < self.upLead.constant) {
        self.upLead.constant = imageLead;
        self.upTrail.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-imageLead;
    }
    if (imageLead < self.downLead.constant) {
        self.downLead.constant = imageLead;
        self.downTrail.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-imageLead;
    }
    CGFloat imageTrial = GuideBackWidth - imageLead -imageSize.width;
    if (imageTrial < self.upTrail.constant) {
        self.upTrail.constant = imageTrial;
        self.upLead.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-imageTrial;
    }
    if (imageTrial < self.downTrail.constant) {
        self.downTrail.constant = imageTrial;
        self.downLead.constant = GuideBackWidth-kLabelInterval*2-stringSize.width-imageTrial;
    }
    
    
    self.imageTop.constant = imageTop;
    self.imageLead.constant = imageLead;
    UIImage* imageDirect = [UIImage imageNamed:[NSString stringWithFormat:@"%@%lu", kDirectImageName, (unsigned long)self.direct]];
    imageDirect = [imageDirect imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.directImageView.image = imageDirect;
    
    if (!animation) {
        [self removeAnimation];
    }
    if (!self.isShow) {
        
        if (animation) {
            [self removeAnimation];
        }
        self.hidden = NO;
        self.layer.opacity = 0.3;
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        [UIView animateWithDuration:0.35 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.layer.opacity = 1;
        }completion:^(BOOL finished) {
            if (animation) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [self addGuideAnimation];
                });
            }
        }];
    }
    self.isShow = YES;
}

-(void)addGuideAnimation{
    for (UIView* subView in self.subviews) {
        CGPoint originPosition = subView.layer.position;
        
        //上下弹性跳动， 把阻尼改为0，就不会减速，持续时间设为无穷大，就不会停止
        CASpringAnimation* springAnimation = [CASpringAnimation animationWithKeyPath:@"position.y"];
        springAnimation.fromValue = @(originPosition.y);
        
        if (self.direct == LJGuideDirectLeftUp || self.direct == LJGuideDirectRightUp) {
            springAnimation.toValue = @(originPosition.y - 4);
        }else{
            springAnimation.toValue = @(originPosition.y + 4);
        }
        
        //质量，影响图层运动时的弹簧惯性，质量越大，弹簧拉伸和压缩的幅度越大 Defaults to one
        springAnimation.mass = 5;
        //刚度系数(劲度系数/弹性系数)，刚度系数越大，形变产生的力就越大，运动越快 Defaults to 100
        springAnimation.stiffness = 100;
        //阻尼系数，阻止弹簧伸缩的系数，阻尼系数越大，停止越快 Defaults to 10
        springAnimation.damping = 0;
        //初始速率，动画视图的初始速度大小 Defaults to zero
        //速率为正数时，速度方向与运动方向一致，速率为负数时，速度方向与运动方向相反
        springAnimation.initialVelocity = 0;//
        //估算时间 返回弹簧动画到停止时的估算时间，根据当前的动画参数估算
//        NSLog(@"====%f",springAnimation.settlingDuration);
        springAnimation.duration = CGFLOAT_MAX;
        
        // removedOnCompletion 默认为YES 为YES时，动画结束后，恢复到原来状态
        springAnimation.removedOnCompletion = NO;
//        springAnimation.fillMode=kCAFillModeForwards;
        
        [subView.layer addAnimation:springAnimation forKey:@"springPop"];
    }
}


-(void)removeAnimation{
    for (UIView* subView in self.subviews) {
        [subView.layer removeAnimationForKey:@"springPop"];
    }
}

-(void)hideGuide{
    [self removeAnimation];
    [self dismissGuide];
}

-(void)tapClick:(UITapGestureRecognizer*)tap{
    [self dismissGuide];
}

-(void)dismissGuide{
    self.isShow = NO;
    if (self.hidden == YES) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        self.layer.opacity = 0.0;
    }completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
        self.transform = CGAffineTransformIdentity;
    }];
    
}

- (CGSize)calculateSize:(NSString *)string fontSize:(NSInteger)fontSize{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Book" size:fontSize]};
    CGRect rect = [string boundingRectWithSize:CGSizeMake(GuideBackWidth *0.8, 0)
                                       options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                    attributes:dic
                                       context:nil];
    return rect.size;
}









@end
