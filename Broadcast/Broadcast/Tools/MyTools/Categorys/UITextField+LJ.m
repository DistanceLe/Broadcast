//
//  UITextField+LJ.m
//  CoolMesh
//
//  Created by lijie on 2019/11/27.
//  Copyright © 2019 lijie. All rights reserved.
//

#import "UITextField+LJ.h"
#import <objc/runtime.h>


@implementation UITextField (LJ)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 获取到UITextField中setText对应的method
        Method setText =class_getInstanceMethod([UITextField class], @selector(setText:));
        Method setTextMySelf =class_getInstanceMethod([UITextField class],@selector(setFieldTextHooked:));
        
        IMP setTextImp =method_getImplementation(setText);
        IMP setTextMySelfImp =method_getImplementation(setTextMySelf);
        
        BOOL didAddMethod = class_addMethod([UITextField class], @selector(setText:), setTextMySelfImp, method_getTypeEncoding(setTextMySelf));
        
        if (didAddMethod) {
            class_replaceMethod([UITextField class], @selector(setFieldTextHooked:), setTextImp, method_getTypeEncoding(setText));
        }else{
            method_exchangeImplementations(setText, setTextMySelf);
        }
    });
}

-(void)setFieldTextHooked:(NSString*)text{
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
    [self setFieldTextHooked:text];
}


@end
