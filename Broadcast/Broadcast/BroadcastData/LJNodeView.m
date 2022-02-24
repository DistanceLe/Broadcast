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

@property(nonatomic, strong)UIView* redPoint;
@property(nonatomic, strong)UILabel* infoLabel;

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
    self.redPoint = subCenterView;
    subCenterView.backgroundColor = [UIColor greenColor];
    subCenterView.layer.cornerRadius = 5;
    [kDataManager setCenterFrameWithSubViw:subCenterView toSuperView:self width:10 height:10];
    
    
    UILabel* infoLabel = [[UILabel alloc]init];
    self.infoLabel = infoLabel;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.font = [UIFont systemFontOfSize:11];
    infoLabel.text = @"";
    infoLabel.hidden = !kDataManager.infoShow;;
    [kDataManager setLabelCenterFrameWithSubViw:infoLabel toSuperView:self width:60 center:5];
    
    
    if (kDataManager.rangeShow) {
        self.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.1];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
    
    
}
-(void)initNotification{
    NSString* subKey = @(self.nodeAddress).stringValue;
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter]addObserverName:rangeChange subName:subKey object:nil handler:^(id sender, id status) {
        @strongify(self);
        
        CGPoint originCenter = self.center;
        self.lj_width = kDataManager.broadcastRange*2;
        self.lj_height = kDataManager.broadcastRange*2;
        self.layer.cornerRadius = kDataManager.broadcastRange;
        self.center = originCenter;
    }];
    [[NSNotificationCenter defaultCenter]addObserverName:rangeShowChange subName:subKey object:nil handler:^(id sender, id status) {
        @strongify(self);
        if (kDataManager.rangeShow) {
            self.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.1];
        }else{
            self.backgroundColor = [UIColor clearColor];
        }
    }];
    [[NSNotificationCenter defaultCenter]addObserverName:infoShowChange subName:subKey object:nil handler:^(id sender, id status) {
        @strongify(self);
        self.infoLabel.hidden = !kDataManager.infoShow;
    }];
    [[NSNotificationCenter defaultCenter]addObserverName:cleanInfo subName:subKey object:nil handler:^(id sender, id status) {
        @strongify(self);
        self.receiptCount = 0;
        self.sendCount = 0;
        self.infoLabel.text = @"";
        self.redPoint.backgroundColor = [UIColor greenColor];
    }];
}
- (void)dealloc{
    NSString* subKey = @(self.nodeAddress).stringValue;
    [[NSNotificationCenter defaultCenter]removeHandlerObserverWithName:cleanInfo subName:subKey object:nil];
    [[NSNotificationCenter defaultCenter]removeHandlerObserverWithName:infoShowChange subName:subKey object:nil];
    [[NSNotificationCenter defaultCenter]removeHandlerObserverWithName:rangeShowChange subName:subKey object:nil];
    [[NSNotificationCenter defaultCenter]removeHandlerObserverWithName:rangeChange subName:subKey object:nil];
}
-(void)setNodeAddress:(NSInteger)nodeAddress{
    _nodeAddress = nodeAddress;
    [self initNotification];
}

/**  通知，多久后能收到 指令 */
-(void)receiptCmd:(LJCmdData*)cmd delay:(CGFloat)delay{
    DLog(@"收到一条延迟 指令: %.2f", delay);
    self.receiptCount ++;
    self.infoLabel.text = [NSString stringWithFormat:@"收%ld发%ld", self.receiptCount, self.sendCount];
    self.redPoint.backgroundColor = kRGBColor((self.receiptCount<100?(int)(self.receiptCount*2.55):255), 0, (self.receiptCount<100?255-(int)(self.receiptCount*2.55):0), 1);
    if (self.currentCmdID == cmd.cmdID || [cmd.addressOnTheWay containsObject:@(self.nodeAddress)] ||
        cmd.ttl <= 1) {
        return;
    }
    self.currentCmdID = cmd.cmdID;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendCmd:cmd];
    });
    
}

/**  第一个节点， 需要调用 开始第一次发送 */
-(void)sendCmd:(LJCmdData*)cmd{
    cmd.ttl --;
    self.sendCount ++;
    self.infoLabel.text = [NSString stringWithFormat:@"收%ld发%ld", self.receiptCount, self.sendCount];
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
