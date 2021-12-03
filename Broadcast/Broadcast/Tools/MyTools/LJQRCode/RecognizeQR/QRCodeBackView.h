

#import <UIKit/UIKit.h>

@interface QRCodeBackView : UIView

@property(nonatomic, assign)CGSize scanSize;

-(void)startRun;
-(void)stopRun;

@end
