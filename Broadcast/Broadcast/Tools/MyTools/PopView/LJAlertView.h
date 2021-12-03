//
//  LJAlertView.h
//  7dmallStore
//
//  Created by celink on 15/6/30.
//  Copyright (c) 2015年 celink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CommitBlock)(NSInteger flag);

@interface LJAlertView : UIView

/**  cancel 不回调， 其他从1开始依次累加 */
+(void)showAlertWithTitle:(NSString*)title
                  message:(NSString *)message
       showViewController:(UIViewController*)viewController
              cancelTitle:(NSString *)cancelTitle
              otherTitles:(NSArray<NSString*>*)otherTitles
             clickHandler:(void(^)(NSInteger index, NSString* title))handler;


/**  cancel 不回调， 点击确定，回调输入框的文字 */
+(void)showTextFieldAlertWithTitle:(NSString*)title
                           message:(NSString *)message
                showViewController:(UIViewController*)viewController
                       cancelTitle:(NSString *)cancelTitle
                      confirmTitle:(NSString *)confirmTitle
                     textFieldText:(NSString*)textFieldText
              textFieldPlaceholder:(NSString*)placeholder
                      clickHandler:(void(^)(NSString* textFieldText))handler;



/**  显示底部弹出框 cancel 不回调 ， 其他从1开始依次累加 */
+(void)showSheetAlertWithTitle:(NSString*)title
                  message:(NSString *)message
       showViewController:(UIViewController*)viewController
              cancelTitle:(NSString *)cancelTitle
              otherTitles:(NSArray<NSString*>*)otherTitles
             clickHandler:(void(^)(NSInteger index, NSString* title))handler;





@end
