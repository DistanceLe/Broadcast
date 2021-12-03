//
//  UILabel+LJ.m
//  StarWristSport
//
//  Created by LiJie on 2017/4/25.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "UILabel+LJ.h"
#import <objc/runtime.h>
//#import "HYBaseViewController.h"

@interface UILabel ()

@property(nonatomic, assign)BOOL enableTailInfoTouch;
@property(nonatomic, copy)NSString* tailInfoString;
@property(nonatomic, copy)UIImage* infoImage;
//@property(nonatomic, strong)void(^touchHandler)(UILabel *label);

@end

@implementation UILabel (LJ)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 获取到UILabel中setText对应的method
        Method setText =class_getInstanceMethod([UILabel class], @selector(setText:));
        Method setTextMySelf =class_getInstanceMethod([UILabel class],@selector(setTextHooked:));
        
        IMP setTextImp =method_getImplementation(setText);
        IMP setTextMySelfImp =method_getImplementation(setTextMySelf);
        
        BOOL didAddMethod = class_addMethod([UILabel class], @selector(setText:), setTextMySelfImp, method_getTypeEncoding(setTextMySelf));
        
        if (didAddMethod) {
            class_replaceMethod([UILabel class], @selector(setTextHooked:), setTextImp, method_getTypeEncoding(setText));
        }else{
            method_exchangeImplementations(setText, setTextMySelf);
        }
        
        
        //设置字体
        setText =class_getInstanceMethod([UILabel class], @selector(setFont:));
        setTextMySelf =class_getInstanceMethod([UILabel class],@selector(setFontHooked:));
        
        setTextImp =method_getImplementation(setText);
        setTextMySelfImp =method_getImplementation(setTextMySelf);
        
        didAddMethod = class_addMethod([UILabel class], @selector(setFont:), setTextMySelfImp, method_getTypeEncoding(setTextMySelf));
        
        if (didAddMethod) {
            class_replaceMethod([UILabel class], @selector(setFontHooked:), setTextImp, method_getTypeEncoding(setText));
        }else{
            method_exchangeImplementations(setText, setTextMySelf);
        }
        
    });
}

-(void)setTextHooked:(NSString*)text{
    /**  修改字体
    Baskerville-Italic   Baskerville-BoldItalic  AvenirNext-DemiBold  AvenirNext-Regular  MarkerFelt-Thin
     */
    UIFont* origFont = self.font;
    if (![origFont.fontName hasPrefix:@"Avenir"]) {
        if ([origFont.fontName hasSuffix:@"Bold"] || [origFont.fontName hasSuffix:@"bold"] || [origFont.fontName hasSuffix:@"Black"]) {
            self.font = [UIFont fontWithName:@"Avenir-Black" size:origFont.pointSize];
        }else{
            self.font = [UIFont fontWithName:@"Avenir-Book" size:origFont.pointSize];
        }
    }
    
//    if ([text hasPrefix:@"\2\2"] && [text hasSuffix:@"\2\2"]) {
//        //title
//        self.font = [UIFont fontWithName:@"Avenir-Black" size:16];
//    }else if ([text hasPrefix:@"\2\2"] && [text hasSuffix:@"\2"]) {
//        //message
//        self.textColor = [UIColor redColor];
//        self.font = [UIFont fontWithName:@"Avenir-Medium" size:15];
//    }else if ([text hasPrefix:@"\2"] && [text hasSuffix:@"\2"]) {
//        //item
//        self.textColor = [UIColor redColor];
//        self.font = [UIFont fontWithName:@"Avenir-Book" size:15];
//    }
    [self setTextHooked:text];
}

-(void)setFontHooked:(UIFont*)font{
    
    if ([self.text hasPrefix:@"\2\2"] && [self.text hasSuffix:@"\2\2"]) {
        //title
        font = [UIFont fontWithName:@"Avenir-Black" size:16];
    }else if ([self.text hasPrefix:@"\2\2"] && [self.text hasSuffix:@"\2"]) {
        //message
//        self.textColor = [UIColor redColor];
        font = [UIFont fontWithName:@"Avenir-Medium" size:15];
    }else if ([self.text hasPrefix:@"\2"] && [self.text hasSuffix:@"\2"]) {
        //item
//        self.textColor = [UIColor redColor];

        font = [UIFont fontWithName:@"Avenir-Book" size:15];
    }
    
    [self setFontHooked:font];
}



#pragma mark - ================ 点击 显示提示语 ==================
static char temLabelKey;
static char temInfoKey;
static char temInfoImageKey;
-(void)setEnableTailInfoTouch:(BOOL)enableTailInfoTouch{
    objc_setAssociatedObject(self, &temLabelKey, @(enableTailInfoTouch), OBJC_ASSOCIATION_ASSIGN);
}
-(BOOL)enableTailInfoTouch{
    return  [objc_getAssociatedObject(self, &temLabelKey) boolValue];
}

-(void)setTailInfoString:(NSString *)tailInfoString{
    objc_setAssociatedObject(self, &temInfoKey, tailInfoString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSString *)tailInfoString{
    return  objc_getAssociatedObject(self, &temInfoKey);
}
-(void)setInfoImage:(UIImage *)infoImage{
    objc_setAssociatedObject(self, &temInfoImageKey, infoImage, OBJC_ASSOCIATION_RETAIN);
}
-(UIImage *)infoImage{
    return  objc_getAssociatedObject(self, &temInfoImageKey);
}




- (void)enableTailNotImageWithInfo:(NSString*)tailInfo{
    self.enableTailInfoTouch = YES;
    self.tailInfoString = tailInfo;
    self.infoImage = nil;
    [self setUserInteractionEnabled:YES];
    
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:self.text];
    self.attributedText = attributString;
}

- (void)enableTailInfo:(BOOL)isEnable tailInfo:(NSString*)tailInfo{
    [self enableTailInfo:isEnable tailInfo:tailInfo image:nil];
}
- (void)enableTailInfo:(BOOL)isEnable tailInfo:(NSString*)tailInfo image:(UIImage*)image{
    self.enableTailInfoTouch = isEnable;
    self.tailInfoString = tailInfo;
    self.infoImage = image;
    
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    if (isEnable) {
        NSTextAttachment *infoAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
        UIImage *image = [UIImage imageNamed:@"label_info_hint"];
        infoAttachment.bounds = CGRectMake(0, -2, image.size.width/2, image.size.height/2);
        infoAttachment.image = image;
        
        NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:infoAttachment];
        [attributString appendAttributedString:imageString];
        
        [self setUserInteractionEnabled:YES];
    } else {
        [self setUserInteractionEnabled:NO];
    }
    self.attributedText = attributString;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.enableTailInfoTouch) {
//        HYBaseViewController* baseVC = [self getControllerFromView:self];
//        if (baseVC) {
//            [baseVC showGuide:self.tailInfoString image:self.infoImage onView:self backColor:kGuideBackColor canTap:NO];
//        }
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}


//- (HYBaseViewController *)getControllerFromView:(UIView *)view {
//    // 遍历响应者链。返回第一个找到视图控制器
//    UIResponder *responder = view;
//    while ((responder = [responder nextResponder])){
//        if ([responder isKindOfClass: [HYBaseViewController class]]){
//            return (HYBaseViewController *)responder;
//        }
//    }
//    // 如果没有找到则返回nil
//    return nil;
//}

/**  在末尾添加一个图片 */
-(void)addImageToTail:(UIImage*)image{
    
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSTextAttachment *infoAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    infoAttachment.bounds = CGRectMake(0, -2, self.font.pointSize+2, self.font.pointSize+2);
    infoAttachment.image = image;
    
    NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:infoAttachment];
    [attributString appendAttributedString:imageString];
    
    self.attributedText = attributString;
}
-(void)addImageToTail:(UIImage*)image andTailString:(NSString*)tailString{
    
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSTextAttachment *infoAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    infoAttachment.bounds = CGRectMake(0, -2, self.font.pointSize+2, self.font.pointSize+2);
    infoAttachment.image = image;
    
    NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:infoAttachment];
    [attributString appendAttributedString:imageString];
    
    
    
    NSAttributedString* tailAttributed = [[NSAttributedString alloc]initWithString:tailString];
    [attributString appendAttributedString:tailAttributed];
    self.attributedText = attributString;
}

-(void)addImageToLead:(UIImage*)image{
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    NSTextAttachment *infoAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    infoAttachment.bounds = CGRectMake(0, -2, self.font.pointSize+2, self.font.pointSize+2);
    infoAttachment.image = image;
    
    NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:infoAttachment];
    [attributString insertAttributedString:[[NSAttributedString alloc]initWithString:@" "] atIndex:0];
    [attributString insertAttributedString:imageString atIndex:0];
    
    self.attributedText = attributString;
}
-(void)addBigImageToLead:(UIImage*)image width:(CGFloat)width{
    NSMutableAttributedString *attributString = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    NSTextAttachment *infoAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    infoAttachment.bounds = CGRectMake(0, 0, width, width*0.5);
    infoAttachment.image = image;
    
    NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:infoAttachment];
    [attributString insertAttributedString:[[NSAttributedString alloc]initWithString:@"\n"] atIndex:0];
    [attributString insertAttributedString:imageString atIndex:0];
    
    self.attributedText = attributString;
}

@end
