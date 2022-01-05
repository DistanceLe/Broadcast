//
//  ViewController.m
//  Broadcast
//
//  Created by lijie on 2021/12/3.
//

#import "ViewController.h"
#import "LJCircleEffectView.h"
#import "LJNodeView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UISlider *ttlSlider;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;

@property (weak, nonatomic) IBOutlet UILabel *rangeValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *ttlValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedValueLabel;

@property (weak, nonatomic) IBOutlet UISwitch *rangeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *infoSwitch;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@property (weak, nonatomic) IBOutlet LJCircleEffectView *effectBackView;

@property (nonatomic, assign)NSInteger nextNodeID;

/**  【id，x，y】 */
@property (nonatomic, strong)NSMutableArray* nodesArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.effectBackView.circleEffectColor = [UIColor redColor];
    
    @weakify(self);
    [self.effectBackView addLongGestureTime:0.3 Handler:^(UILongPressGestureRecognizer *longGesture, UIView *itself) {
        @strongify(self);
        
        if (longGesture.state == UIGestureRecognizerStateBegan) {
            CGPoint begingPoint = [longGesture locationInView:self.effectBackView];
            [self addNodeToPoint:begingPoint nodeID:self.nextNodeID];
            [self.nodesArray addObject:@[@(self.nextNodeID), @(begingPoint.x), @(begingPoint.y)]];
            self.countLabel.text = @(self.nodesArray.count).stringValue;
            [[NSUserDefaults standardUserDefaults]setObject:self.nodesArray forKey:nodesKey];
            self.nextNodeID ++;
            [[NSUserDefaults standardUserDefaults]setObject:@(self.nextNodeID) forKey:nodeIdKey];
        }
    }];
    
    
    NSNumber* range = [[NSUserDefaults standardUserDefaults]objectForKey:rangeKey];
    if (range != nil) {
        kDataManager.broadcastRange = range.integerValue;
    }
    NSNumber* ttl = [[NSUserDefaults standardUserDefaults]objectForKey:ttlKey];
    if (ttl != nil) {
        kDataManager.ttl = ttl.integerValue;
    }
    NSNumber* speed = [[NSUserDefaults standardUserDefaults]objectForKey:speedKey];
    if (speed != nil) {
        kDataManager.speed = speed.floatValue;
    }
    
    NSNumber* rangeShow = [[NSUserDefaults standardUserDefaults]objectForKey:rangeShowChange];
    if (rangeShow != nil) {
        kDataManager.rangeShow = rangeShow.boolValue;
    }
    NSNumber* infoShow = [[NSUserDefaults standardUserDefaults]objectForKey:infoShowChange];
    if (infoShow != nil) {
        kDataManager.infoShow = infoShow.boolValue;
    }
    
    self.effectBackView.circleEffectTime = kDataManager.speed;
    self.effectBackView.endRadius = kDataManager.broadcastRange;
    
    self.rangeValueLabel.text = @(kDataManager.broadcastRange).stringValue;
    self.ttlValueLabel.text = @(kDataManager.ttl).stringValue;
    self.speedValueLabel.text = [NSString stringWithFormat:@"%.2f", kDataManager.speed];
    
    self.rangeSwitch.on = @(kDataManager.rangeShow).boolValue;
    self.infoSwitch.on = @(kDataManager.infoShow).boolValue;
    
    self.rangeSlider.value = kDataManager.broadcastRange;
    self.ttlSlider.value = kDataManager.ttl;
    self.speedSlider.value = kDataManager.speed;
    
    NSNumber* nodeID = [[NSUserDefaults standardUserDefaults]objectForKey:nodeIdKey];
    if (nodeID == nil) {
        self.nextNodeID = 1;
        [[NSUserDefaults standardUserDefaults]setObject:@(self.nextNodeID) forKey:nodeIdKey];
    }else{
        self.nextNodeID = nodeID.integerValue;
    }
    
    NSArray* nodes = [[NSUserDefaults standardUserDefaults]objectForKey:nodesKey];
    if (nodes == nil) {
        self.nodesArray = [NSMutableArray array];
    }else{
        self.nodesArray = [NSMutableArray arrayWithArray:nodes];
    }
    
    self.countLabel.text = @(self.nodesArray.count).stringValue;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSArray* nodeValue in self.nodesArray) {
            NSInteger nodeID = [nodeValue.firstObject integerValue];
            CGFloat x = [nodeValue[1] floatValue];
            CGFloat y = [nodeValue[2] floatValue];
            [self addNodeToPoint:CGPointMake(x, y) nodeID:nodeID];
            if (self.nextNodeID <= nodeID) {
                self.nextNodeID = nodeID+1;
            }
        }
    });
}
- (IBAction)rangeSliderChange:(UISlider *)sender {
    kDataManager.broadcastRange = sender.value;
    self.effectBackView.endRadius = kDataManager.broadcastRange;
    self.rangeValueLabel.text = @(kDataManager.broadcastRange).stringValue;
    [[NSNotificationCenter defaultCenter]postNotificationName:rangeChange object:nil];
    [[NSUserDefaults standardUserDefaults]setObject:@(kDataManager.broadcastRange) forKey:rangeKey];
}

- (IBAction)ttlSliderChange:(UISlider *)sender {
    kDataManager.ttl = sender.value;
    self.ttlValueLabel.text = @(kDataManager.ttl).stringValue;
    [[NSUserDefaults standardUserDefaults]setObject:@(kDataManager.ttl) forKey:ttlKey];
}

- (IBAction)speedSliderChange:(UISlider *)sender {
    
    kDataManager.speed = sender.value;
    self.effectBackView.circleEffectTime = kDataManager.speed;
    self.speedValueLabel.text = [NSString stringWithFormat:@"%.2f", kDataManager.speed];
    [[NSUserDefaults standardUserDefaults]setObject:@(kDataManager.speed) forKey:speedKey];
}


- (IBAction)rangeSwitchClick:(UISwitch *)sender {
    
    kDataManager.rangeShow = sender.isOn;
    [[NSNotificationCenter defaultCenter]postNotificationName:rangeShowChange object:nil];
    [[NSUserDefaults standardUserDefaults]setObject:@(kDataManager.rangeShow) forKey:rangeShowChange];
}
- (IBAction)infoSwitchClick:(UISwitch *)sender {
    
    kDataManager.infoShow = sender.isOn;
    [[NSNotificationCenter defaultCenter]postNotificationName:infoShowChange object:nil];
    [[NSUserDefaults standardUserDefaults]setObject:@(kDataManager.infoShow) forKey:infoShowChange];
}
- (IBAction)cleanClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:cleanInfo object:nil];
}


-(void)addNodeToPoint:(CGPoint)point nodeID:(NSInteger)nodeID{
    
    LJNodeView* subNodeView = [[LJNodeView alloc]initWithFrame:CGRectMake(point.x-kDataManager.broadcastRange, point.y-kDataManager.broadcastRange, kDataManager.broadcastRange*2.0, kDataManager.broadcastRange*2.0)];
    [self.effectBackView addSubview:subNodeView];
    subNodeView.gestureType = LJGestureType_OneFingleDragMove;
    
    subNodeView.nodeAddress = nodeID;
    subNodeView.layer.cornerRadius = kDataManager.broadcastRange;
    @weakify(self);
    @weakify(subNodeView);
    [subNodeView addTapGestureHandler:^(UITapGestureRecognizer *tapGesture, UIView *itself) {
        @strongify(subNodeView);
        
        LJCmdData* cmd = [[LJCmdData alloc]init];
        [subNodeView sendCmd:cmd];
    }];
    
    [subNodeView addMultipleTap:3 gestureHandler:^(UITapGestureRecognizer *tapGesture, UIView *itself) {
        @strongify(self);
        @strongify(subNodeView);
        if (tapGesture.state == UIGestureRecognizerStateBegan) {
            for (NSArray* nodeValue in self.nodesArray) {
                NSInteger nodeID = [nodeValue.firstObject integerValue];
                if (nodeID == subNodeView.nodeAddress) {
                    [self.nodesArray removeObject:nodeValue];
                    self.countLabel.text = @(self.nodesArray.count).stringValue;
                    [[NSUserDefaults standardUserDefaults]setObject:self.nodesArray forKey:nodesKey];
                    break;
                }
            }
            [subNodeView removeFromSuperview];
        }
    }];
    [subNodeView setPositionChangeHandler:^(CGPoint centerPoint) {
        @strongify(self);
        @strongify(subNodeView);
        NSArray* newPosition = @[@(subNodeView.nodeAddress), @(centerPoint.x), @(centerPoint.y)];
        for (NSArray* nodeValue in self.nodesArray) {
            NSInteger nodeID = [nodeValue.firstObject integerValue];
            if (nodeID == subNodeView.nodeAddress) {
                [self.nodesArray replaceObjectAtIndex:[self.nodesArray indexOfObject:nodeValue] withObject:newPosition];
                [[NSUserDefaults standardUserDefaults]setObject:self.nodesArray forKey:nodesKey];
                break;
            }
        }
    }];
    
    
}

@end
