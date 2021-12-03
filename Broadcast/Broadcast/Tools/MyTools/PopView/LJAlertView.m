//
//  LJAlertView.m
//  7dmallStore
//
//  Created by celink on 15/6/30.
//  Copyright (c) 2015年 celink. All rights reserved.
//

#import "LJAlertView.h"
#import "AppDelegate.h"

#define LJAlertButtonTextColor [UIColor blackColor]
#define LJAlertCancelButtonTextColor kSystemColor



@interface UILabel (LJAlertActionFont)
/** font */
@property (nonatomic,copy) UIFont *appearanceFont UI_APPEARANCE_SELECTOR;
@end

@implementation UILabel (LJAlertActionFont)
- (void)setAppearanceFont:(UIFont *)appearanceFont
{
    if(appearanceFont)
    {
        [self setFont:appearanceFont];
    }
}

- (UIFont *)appearanceFont
{
    return self.font;
}
@end



@interface LJAlertView ()

@end

@implementation LJAlertView


+(void)showAlertWithTitle:(NSString*)title
                  message:(NSString *)message
       showViewController:(UIViewController*)viewController
              cancelTitle:(NSString *)cancelTitle
              otherTitles:(NSArray<NSString*>*)otherTitles
             clickHandler:(void(^)(NSInteger index, NSString* title))handler{
    
    [self showAlertWithType:UIAlertControllerStyleAlert Title:title message:message showViewController:viewController cancelTitle:cancelTitle otherTitles:otherTitles clickHandler:handler];
}

/**  cancel 不回调， 点击确定，回调输入框的文字 */
+(void)showTextFieldAlertWithTitle:(NSString*)title
                           message:(NSString *)message
                showViewController:(UIViewController*)viewController
                       cancelTitle:(NSString *)cancelTitle
                      confirmTitle:(NSString *)confirmTitle
                     textFieldText:(NSString*)textFieldText
              textFieldPlaceholder:(NSString*)placeholder
                      clickHandler:(void(^)(NSString* textFieldText))handler{
    
    UIAlertController* alertVC;
    NSString* tempTitle = nil;
    NSString* tempMessage = nil;
    if (title) {
        tempTitle = [NSString stringWithFormat:@"\2\2%@\2\2", title];
    }
    if (message) {
        tempMessage = [NSString stringWithFormat:@"\2\2%@\2", message];
    }
    alertVC = [UIAlertController alertControllerWithTitle:tempTitle message:tempMessage preferredStyle:UIAlertControllerStyleAlert];
    if (@available(iOS 13.0, *)) {
        [alertVC setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    } else {
        // Fallback on earlier versions
    }
    
    if ((cancelTitle && cancelTitle.length > 0)) {
        UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"\2%@\2", cancelTitle] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        }];
        [cancelAction setValue:LJAlertCancelButtonTextColor forKey:@"titleTextColor"];
        [alertVC addAction:cancelAction];
    }
    
    if ((confirmTitle && confirmTitle.length > 0)) {
        @weakify(alertVC);
        UIAlertAction* action=[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"\2%@\2", confirmTitle] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            @strongify(alertVC);
            if (handler){
                UITextField *envirnmentNameTextField = alertVC.textFields.firstObject;
                handler(envirnmentNameTextField.text);
            }
        }];
        [action setValue:LJAlertButtonTextColor forKey:@"titleTextColor"];
        [alertVC addAction:action];
    }
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = textFieldText;
        textField.placeholder = placeholder;
        textField.delegate = kDataManager;
    }];
    
    if (!viewController) {
        viewController = [kDataManager getRootWindws].rootViewController;
    }
    
    [viewController presentViewController:alertVC animated:YES completion:nil];
}

/**  显示底部弹出框 cancel的Index = 0， 其他从1开始依次累加 */
+(void)showSheetAlertWithTitle:(NSString*)title
                       message:(NSString *)message
            showViewController:(UIViewController*)viewController
                   cancelTitle:(NSString *)cancelTitle
                   otherTitles:(NSArray<NSString*>*)otherTitles
                  clickHandler:(void(^)(NSInteger index, NSString* title))handler{
    [self showAlertWithType:UIAlertControllerStyleActionSheet Title:title message:message showViewController:viewController cancelTitle:cancelTitle otherTitles:otherTitles clickHandler:handler];
}



+(void)showAlertWithType:(UIAlertControllerStyle)type
                   Title:(NSString*)title
                  message:(NSString *)message
       showViewController:(UIViewController*)viewController
              cancelTitle:(NSString *)cancelTitle
              otherTitles:(NSArray<NSString*>*)otherTitles
             clickHandler:(void(^)(NSInteger index, NSString* title))handler{
    
    UIAlertControllerStyle oldType = type;
    
    // 防止ipad 异常
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        type = UIAlertControllerStyleAlert;
    }
    
    UIAlertController* alertVC;
    NSString* tempTitle = nil;
    NSString* tempMessage = nil;
    if (title) {
        tempTitle = [NSString stringWithFormat:@"\2\2%@\2\2", title];
    }
    if (message) {
        tempMessage = [NSString stringWithFormat:@"\2\2%@\2", message];
    }
    alertVC = [UIAlertController alertControllerWithTitle:tempTitle message:tempMessage preferredStyle:type];
    
//    if (title.length) {
//        alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"\2\2%@\2\2", title] message:message preferredStyle:type];
//    }else{
//        alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:type];
//    }
    if (@available(iOS 13.0, *)) {
        [alertVC setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
    } else {
        // Fallback on earlier versions
    }
    
    //        NSMutableAttributedString *alertTitleStr = [[NSMutableAttributedString alloc] initWithString:@"提示"];
    //        [alertTitleStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:NSMakeRange(0, 2)];
    //        [alertTitleStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 2)];
    //        [alertVC setValue:alertTitleStr forKey:@"attributedTitle"];
    
    if ((cancelTitle && cancelTitle.length > 0) ||
        type == UIAlertControllerStyleActionSheet ||
        ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && oldType == UIAlertControllerStyleActionSheet)) {
        UIAlertAction* cancelAction=[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"\2%@\2", cancelTitle] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            //        if (handler){
            //            handler(0, cancelTitle);
            //        }
        }];
        [cancelAction setValue:LJAlertCancelButtonTextColor forKey:@"titleTextColor"];
        [alertVC addAction:cancelAction];
    }
    
    for (NSInteger i = 0; i < otherTitles.count; i++) {
        NSString* title = otherTitles[i];
        
        UIAlertAction* action=[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"\2%@\2", title] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (handler){
                handler(i+1, title);
            }
        }];
        if ([title isEqualToString:LS(@"HY_Remove")] || [title isEqualToString:LS(@"HY_Delete")] || [title isEqualToString:LS(@"HY_DeleteNetwork")]) {
            [action setValue:kWarningColor forKey:@"titleTextColor"];
        }else{
            [action setValue:LJAlertButtonTextColor forKey:@"titleTextColor"];
        }
        [alertVC addAction:action];
    }
    
    
    if (!viewController) {
        viewController = [kDataManager getRootWindws].rootViewController;
    }
    
    [viewController presentViewController:alertVC animated:YES completion:nil];
    
}



@end
