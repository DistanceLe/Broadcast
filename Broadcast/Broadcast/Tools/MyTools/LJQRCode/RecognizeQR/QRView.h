//
//  QRView.h
//  二维码
//
//  Created by LiJie on 15/11/5.
//  Copyright © 2015年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^QRBlock)(id result);

@interface QRView : UIView

@property(nonatomic, copy)UIColor* QRBackgroundColor;   //背景色(默认灰色，半透明)(一定要加 colorWithAlphaComponent)
@property(nonatomic, assign)CGSize QRScanSize;         //扫描框的大小 默认Frame 的一半大小）


/**  自己手动add subView  */
+(instancetype)getQRViewWithFrame:(CGRect)frame showViewController:(UIViewController*)viewController result:(QRBlock)resultBlock;

/**  自动在Controller里面添加二维码扫描， 且可以打开系统相册 识别二维码。 */
+(instancetype)setQRCodeToViewController:(UIViewController*)contentVC result:(QRBlock)resultBlock;

/**  打开系统相册，识别二维码，结果回调到 上面的result里 */
-(void)openSystemAlbum;

/**  打开 或者 关闭 闪光灯， 默认关闭 */
-(void)openFlash;

/**  获取闪光灯是否打开 */
-(BOOL)getFlashIsOpen;

/**  开始扫描, 首次也需要手动调用 */
-(void)startScan;

/**  停止扫描 */
-(void)stopScan;


@end
