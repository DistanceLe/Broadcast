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

@property (weak, nonatomic) IBOutlet LJCircleEffectView *effectBackView;

@property (nonatomic, assign)NSInteger nextNodeID;

/**  【id，x，y】 */
@property (nonatomic, strong)NSMutableArray* nodesArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
//    LJButton_Google* button = [[LJButton_Google alloc]init];
//    button.circleEffectTime = 4;
//    button.frame = CGRectMake(50, 100, 500, 400);
//    button.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:button];
    
    self.effectBackView.circleEffectColor = [UIColor redColor];
    self.effectBackView.circleEffectTime = kDataManager.speed;
    self.effectBackView.endRadius = kDataManager.broadcastRange;
//    self.effectBackView.beginRadius = 10;
    
    @weakify(self);
    [self.effectBackView addLongGestureTime:1.3 Handler:^(UILongPressGestureRecognizer *longGesture, UIView *itself) {
        @strongify(self);
        
        if (longGesture.state == UIGestureRecognizerStateBegan) {
            CGPoint begingPoint = [longGesture locationInView:self.effectBackView];
            [self addNodeToPoint:begingPoint nodeID:self.nextNodeID];
            [self.nodesArray addObject:@[@(self.nextNodeID), @(begingPoint.x), @(begingPoint.y)]];
            [[NSUserDefaults standardUserDefaults]setObject:self.nodesArray forKey:@"nodes"];
            self.nextNodeID ++;
            [[NSUserDefaults standardUserDefaults]setObject:@(self.nextNodeID) forKey:@"nodeID"];
        }
    }];
    
    
    
    NSNumber* nodeID = [[NSUserDefaults standardUserDefaults]objectForKey:@"nodeID"];
    if (nodeID == nil) {
        self.nextNodeID = 1;
        [[NSUserDefaults standardUserDefaults]setObject:@(self.nextNodeID) forKey:@"nodeID"];
    }else{
        self.nextNodeID = nodeID.integerValue;
    }
    
    NSArray* nodes = [[NSUserDefaults standardUserDefaults]objectForKey:@"nodes"];
    if (nodes == nil) {
        self.nodesArray = [NSMutableArray array];
    }else{
        self.nodesArray = [NSMutableArray arrayWithArray:nodes];
    }
    
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
    
    
}

- (IBAction)ttlSliderChange:(UISlider *)sender {
    
    
}

- (IBAction)speedSliderChange:(UISlider *)sender {
    
    
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
                    [[NSUserDefaults standardUserDefaults]setObject:self.nodesArray forKey:@"nodes"];
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
                [[NSUserDefaults standardUserDefaults]setObject:self.nodesArray forKey:@"nodes"];
                break;
            }
        }
    }];
    
    
}

@end
