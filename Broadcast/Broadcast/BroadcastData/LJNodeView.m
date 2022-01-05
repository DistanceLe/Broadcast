//
//  LJNodeView.m
//  Broadcast
//
//  Created by lijie on 2021/12/31.
//

#import "LJNodeView.h"
#import "LJCircleEffectView.h"

@interface LJNodeView ()

@property(nonatomic, assign)NSInteger currentCmdID;

@end

@implementation LJNodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}
-(void)initUI{
    
    UIView* subCenterView = [[UIView alloc]init];
    subCenterView.backgroundColor = [UIColor redColor];
    subCenterView.layer.cornerRadius = 5;
    [kDataManager setCenterFrameWithSubViw:subCenterView toSuperView:self width:10 height:10];
    
    
    self.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.1];
}


/**  通知，多久后能收到 指令 */
-(void)receiptCmd:(LJCmdData*)cmd delay:(CGFloat)delay{
    DLog(@"收到一条延迟 指令: %.2f", delay);
    self.receiptCount ++;
    if (self.currentCmdID == cmd.cmdID || [cmd.addressOnTheWay containsObject:@(self.nodeAddress)] ||
        cmd.ttl <= 1) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendCmd:cmd];
    });
    
}

/**  第一个节点， 需要调用 开始第一次发送 */
-(void)sendCmd:(LJCmdData*)cmd{
    cmd.ttl --;
    self.sendCount ++;
    self.currentCmdID = cmd.cmdID;
    [cmd.addressOnTheWay addObject:@(self.nodeAddress)];
    
    LJCircleEffectView* superBackView =  (LJCircleEffectView*)self.superview;
    [superBackView startCircleEffectFromPoint:self.center];
    
    CGPoint originPoint = self.center;
    
    for (LJNodeView* subView in superBackView.subviews) {
        if ([subView isMemberOfClass:[LJNodeView class]] && subView != self) {
            
            CGFloat radius=sqrt(pow(fabs(originPoint.x - subView.center.x), 2) +
                                pow(fabs(originPoint.y - subView.center.y), 2));
            
            if (radius <= kDataManager.broadcastRange) {
                CGFloat delay = (radius)/kDataManager.broadcastRange * kDataManager.speed;
                LJCmdData* tempCmd = [[LJCmdData alloc]init];
                [tempCmd setSelfInfoBy:[cmd getSelfInfo]];
                [subView receiptCmd:tempCmd delay:delay];
            }
        }
    }
}




@end
