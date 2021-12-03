
//
//  WSLineChartView.m
//  WSLineChart
//
//  Created by iMac on 16/11/17.
//  Copyright © 2016年 zws. All rights reserved.
//

#import "WSLineChartView.h"
#import "UIView+LJ.h"
#import "XAxisView.h"
#import "XTextView.h"

#import "YAxisView.h"
#import "RightYAxisView.h"

@interface WSLineChartView ()

@property(nonatomic, strong)UIImageView* emptyImageView;
@property(nonatomic, strong)UILabel*     emptyLabel;

@property (strong, nonatomic) NSArray *xTitleArray;
@property (strong, nonatomic) NSMutableArray *yValueArray;
@property (strong, nonatomic) NSMutableArray *yValue2Array;
@property (assign, nonatomic) CGFloat yMax;
@property (assign, nonatomic) CGFloat yMin;

@property (strong, nonatomic) YAxisView         *yAxisView;
@property (strong, nonatomic) RightYAxisView    *rightYAxisView;

@property (strong, nonatomic) XTextView *xTextView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat pointGap;

@property (assign, nonatomic) NSInteger  longIndex;
@property (assign, nonatomic) CGFloat    startLongY;
@property (assign, nonatomic) CGFloat    startLongX;
@property (assign, nonatomic) CGFloat    startLongValue;
@property (assign, nonatomic) CGFloat    startLongValue2;
@property (assign, nonatomic) CGFloat    oldLongValue;
@property (assign, nonatomic) CGFloat    oldLongValue2;
/**  一个像素 代表多少值 */
@property (assign, nonatomic) CGFloat    oneValueHeight;

@property(nonatomic, assign)BOOL showAnimation;
@property(nonatomic, assign)BOOL canZoom;

@end

@implementation WSLineChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineColor = [UIColor redColor];
        self.xyLineColor = [UIColor whiteColor];
        self.horizontalLineColor = [[UIColor whiteColor]colorWithAlphaComponent:0.4];
        self.xyTextColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
        self.xAxisBackColor = [UIColor clearColor];
        self.yAxisBackColor = [UIColor clearColor];
        
        self.leftMargin = 30;
        self.rightMargin = 30;
        self.topMargin = 30;
        self.yAxisElements = 5;
        self.xAxisAndTextInterval = 5;
        self.pointInterval = 50;
        self.showYUnit = YES;
        self.valueTextBottomEdge = 5;
        self.showValuePoint = YES;
        self.showValueWidth = 4;
        self.valuePointColor = [UIColor orangeColor];
        self.tapPointColor = [UIColor orangeColor];
        
        self.beganEqualEnd = NO;
        self.beagnNeedFull = YES;
        self.endNeedFull = YES;
        self.endPointCanVerticalMove = YES;
        
        self.firstPointCanMove = YES;
        self.endPointCanMove = YES;
        self.panGestureEnable = YES;
        
        self.canEqualX = YES;
        self.longIndex = -1;
        self.yOneUnitValue = 1;
        
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:8]};
        CGSize bottomSize = [@"x\nx" sizeWithAttributes:attribute];
        self.bottomHeight = bottomSize.height + 5;
    }
    
    return self;
}
-(void)setEndNeedFull:(BOOL)endNeedFull{
    _endNeedFull = endNeedFull;
    self.xAxisView.endNeedFull = endNeedFull;
}
-(void)setNeedLastSecondPoint:(BOOL)needLastSecondPoint{
    _needLastSecondPoint = needLastSecondPoint;
    self.xAxisView.needLastSecondPoint = needLastSecondPoint;
}
-(void)setFullToOverflow:(BOOL)fullToOverflow{
    _fullToOverflow = fullToOverflow;
    self.xAxisView.fullToOverflow = fullToOverflow;
}
-(void)setBeagnNeedFull:(BOOL)beagnNeedFull{
    _beagnNeedFull = beagnNeedFull;
    self.xAxisView.beagnNeedFull = beagnNeedFull;
}
-(void)setBeganEqualEnd:(BOOL)beganEqualEnd{
    _beganEqualEnd = beganEqualEnd;
    self.xAxisView.beganEqualEnd = beganEqualEnd;
}

-(void)setVirtualColor:(UIColor *)virtualColor{
    _virtualColor = virtualColor;
    self.xAxisView.virtualColor = virtualColor;
}
-(void)setVirtualXArray:(NSArray *)virtualXArray{
    _virtualXArray = virtualXArray;
    self.xAxisView.virtualXArray = virtualXArray;
}
-(void)setVirtualYArray:(NSArray *)virtualYArray{
    _virtualYArray = virtualYArray;
    self.xAxisView.virtualYArray = virtualYArray;
}
-(void)setVirtualYMin:(CGFloat)virtualYMin{
    _virtualYMin = virtualYMin;
    self.xAxisView.virtualYMin = virtualYMin;
    self.rightYAxisView.yMin = virtualYMin;
}
-(void)setVirtualYMax:(CGFloat)virtualYMax{
    _virtualYMax = virtualYMax;
    self.xAxisView.virtualYMax = virtualYMax;
    self.rightYAxisView.yMax = virtualYMax;
}
-(void)setVirtualUnitStr:(NSString *)virtualUnitStr{
    _virtualUnitStr = virtualUnitStr;
    self.rightYAxisView.unitStr = virtualUnitStr;
}

-(void)setShowVirtualYUnit:(BOOL)showVirtualYUnit{
    _showVirtualYUnit = showVirtualYUnit;
    self.rightYAxisView.showUnit = showVirtualYUnit;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    self.scrollView.frame = CGRectMake(self.leftMargin, 0, self.frame.size.width-self.leftMargin-self.rightMargin, self.frame.size.height);
    self.pointGap = (self.scrollView.frame.size.width) / (self.xTitleArray.count+1);
    CGFloat width = self.xTitleArray.count * self.pointGap + self.pointGap;
    
    self.xAxisView.frame = CGRectMake(0, 0, width, self.frame.size.height);
    self.xTextView.frame = CGRectMake(0, 0, width, self.frame.size.height);
    self.yAxisView.frame = CGRectMake(0, 0, self.leftMargin, self.frame.size.height);
    self.rightYAxisView.frame = CGRectMake(self.frame.size.width - self.rightMargin, 0, self.rightMargin, self.frame.size.height);
    
    [self.yAxisView setNeedsDisplay];
    [self.rightYAxisView setNeedsDisplay];
    
    self.scrollView.contentSize = self.xAxisView.frame.size;
    
    self.xAxisView.pointGap = self.pointGap;
    self.xTextView.pointGap = self.pointGap;
    
    self.oneValueHeight = (self.yMax - self.yMin)/(self.frame.size.height-self.bottomHeight - self.topMargin);
}

-(void)didMoveToSuperview{
    self.emptyImageView = [[UIImageView alloc]initWithFrame:self.superview.bounds];
    self.emptyImageView.hidden = YES;
    self.emptyImageView.userInteractionEnabled = YES;
    [self.superview addSubview:self.emptyImageView];
    
    self.emptyLabel = [[UILabel alloc]init];
    self.emptyLabel.textColor = _emptyLabelColor;
    self.emptyLabel.font = [UIFont systemFontOfSize:15];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self.emptyImageView addSubview:self.emptyLabel];
}

-(void)setxTitleArray:(NSArray*)xTitleArray
          yValueArray:(NSArray*)yValueArray
         yValue2Array:(NSArray*)yValue2Array
                 yMax:(CGFloat)yMax
                 yMin:(CGFloat)yMin
                xUnit:(NSString*)XUnit
                yUnit:(NSString*)yUnit
                empty:(BOOL)empty
            animation:(BOOL)animation{
    
    self.emptyImageView.frame = CGRectMake(-5, -5, self.superview.lj_width+10, self.superview.lj_height+10);
    self.emptyLabel.frame = CGRectMake(0, self.emptyImageView.lj_height-50, self.emptyImageView.lj_width, 40);
    if (self.showEmptyImageView && (xTitleArray.count==0 || empty)) {
        self.emptyImageView.hidden = NO;
        self.emptyImageView.image = self.emptyBackImage;
    }else{
        self.emptyImageView.hidden = YES;
    }
    
    self.xTitleArray = xTitleArray;
    self.yValueArray = [NSMutableArray arrayWithArray:yValueArray];
    self.yValue2Array = [NSMutableArray arrayWithArray:yValue2Array];
    self.yMax = yMax;
    self.yMin = yMin;
    self.showAnimation = animation;
    
    self.pointGap = self.pointInterval;
    
    [self creatYAxisView:yUnit];
    [self creatXAxisView:yUnit Xunit:XUnit];
    
    
    if (self.longPressCanAdd) {
        //长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
        longPress.minimumPressDuration = 0.55;
        longPress.delegate = self.xTextView;
        [self.xTextView addGestureRecognizer:longPress];
    }
    if (self.tapCanSelect) {
        //点击手势
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(event_tapAction:)];
        tapGesture.delegate = self.xTextView;
        [self.xTextView addGestureRecognizer:tapGesture];
    }
    
    if (self.panGestureEnable) {
        //滑动 手势
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(event_panAction:)];
        panGesture.delegate = self.xTextView;
        [self.xTextView addGestureRecognizer:panGesture];
    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.pointGap = (self.scrollView.frame.size.width) / (self.xTitleArray.count+1);
        self.xAxisView.pointGap = self.pointGap;
        self.xTextView.pointGap = self.pointGap;
        
        CGRect frame = self.xAxisView.frame;
        frame.size.width = self.scrollView.frame.size.width;
        self.xAxisView.frame = frame;
        self.xTextView.frame = frame;
        self.scrollView.contentSize = CGSizeMake(self.xAxisView.frame.size.width, 0);
        [self.scrollView setContentOffset:CGPointZero];
    });
    
}

- (void)creatYAxisView:(NSString*)YUnit{
    if (self.yAxisView) {
        for (UIGestureRecognizer* gesture in self.yAxisView.gestureRecognizers) {
            [self.yAxisView removeGestureRecognizer:gesture];
        }
        [self.yAxisView removeFromSuperview];
    }
    if (self.rightYAxisView) {
        for (UIGestureRecognizer* gesture in self.rightYAxisView.gestureRecognizers) {
            [self.rightYAxisView removeGestureRecognizer:gesture];
        }
        [self.rightYAxisView removeFromSuperview];
    }
    self.yAxisView = [[YAxisView alloc]initWithFrame:CGRectMake(0, 0, self.leftMargin, self.frame.size.height) yMax:self.yMax yMin:self.yMin];
    self.yAxisView.unitStr = YUnit;
    self.yAxisView.showUnit = self.showYUnit;
    self.yAxisView.xAxisAndTextInterval = self.xAxisAndTextInterval;
    self.yAxisView.topMargin = self.topMargin;
    self.yAxisView.yAxisElements = self.yAxisElements;
    self.yAxisView.xyLineColor = self.xyLineColor;
    
    //用曲线颜色来表示 Y轴的值和单位颜色
    self.yAxisView.xyTextColor = self.lineColor;
    
    self.yAxisView.backgroundColor = self.yAxisBackColor;
    self.yAxisView.bottomHeight = self.bottomHeight;
    [self addSubview:self.yAxisView];
    
    self.rightYAxisView = [[RightYAxisView alloc]initWithFrame:CGRectMake(self.frame.size.width - self.rightMargin, 0, self.rightMargin, self.frame.size.height)];
    self.rightYAxisView.unitStr = self.virtualUnitStr;
    self.rightYAxisView.yMin = self.virtualYMin;
    self.rightYAxisView.yMax = self.virtualYMax;
    
    self.rightYAxisView.showUnit = self.showVirtualYUnit;
    self.rightYAxisView.xAxisAndTextInterval = self.xAxisAndTextInterval;
    self.rightYAxisView.topMargin = self.topMargin;
    self.rightYAxisView.yAxisElements = self.yAxisElements;
    self.rightYAxisView.xyLineColor = self.xyLineColor;
    
    //用曲线颜色来表示 Y轴的值和单位颜色
    self.rightYAxisView.xyTextColor = self.virtualColor;
    
    self.rightYAxisView.backgroundColor = self.yAxisBackColor;
    self.rightYAxisView.bottomHeight = self.bottomHeight;
    [self addSubview:self.rightYAxisView];
    
    self.oneValueHeight = (self.yMax - self.yMin)/(self.frame.size.height-self.bottomHeight - self.topMargin);
}

- (void)creatXAxisView:(NSString*)YUnit Xunit:(NSString*)XUnit {
    if (self.xTextView) {
        for (UIGestureRecognizer* gesture in self.xTextView.gestureRecognizers) {
            [self.xTextView removeGestureRecognizer:gesture];
        }
        [self.xTextView removeFromSuperview];
        [self.xAxisView removeFromSuperview];
        
    }else{
        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(self.leftMargin, 0, self.frame.size.width-self.leftMargin-self.rightMargin, self.frame.size.height)];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.bounces = NO;
        [self addSubview:self.scrollView];
    }
    CGFloat width = self.xTitleArray.count * self.pointGap + self.pointGap;
    if (width < (self.lj_width-30)) {
        self.canZoom = NO;
        width = (self.lj_width-30);
    }else{
        self.canZoom = YES;
    }
    self.xAxisView = [[XAxisView alloc] initWithFrame:CGRectMake(0, 0, width, self.frame.size.height)
                                          xTitleArray:self.xTitleArray
                                          yValueArray:self.yValueArray
                                         yValue2Array:self.yValue2Array
                                                 yMax:self.yMax
                                                 yMin:self.yMin];
    
    self.xTextView = [[XTextView alloc] initWithFrame:CGRectMake(0, 0, width, self.frame.size.height) xTitleArray:self.xTitleArray yValueArray:self.yValueArray yValue2Array:self.yValue2Array yMax:self.yMax yMin:self.yMin];
    
    self.xTextView.XunitStr = XUnit;
    self.xTextView.YunitStr = YUnit;
    self.xTextView.isShowLabel = self.showValueText;
    self.xTextView.showAnimation = self.showAnimation;
    self.xTextView.topMargin = self.topMargin;
    self.xTextView.leftMargin = self.leftMargin;
    self.xTextView.xyTextColor = self.xyTextColor;
    self.xTextView.backgroundColor = self.xAxisBackColor;
    self.xTextView.showValuePoint = self.showValuePoint;
    self.xTextView.showValueWidth = self.showValueWidth;
    self.xTextView.valuePointColor = self.valuePointColor;
    self.xTextView.tapPointColor = self.tapPointColor;
    self.xTextView.valueTextBottomEdge = self.valueTextBottomEdge;
    self.xTextView.bottomHeight = self.bottomHeight;
    self.xTextView.tapCanSelect = self.tapCanSelect;
    
    self.xAxisView.showUnit = self.showXUnit;
    self.xAxisView.XunitStr = XUnit;
    self.xAxisView.lineColor = self.lineColor;
    self.xAxisView.showAnimation = self.showAnimation;
    self.xAxisView.topMargin = self.topMargin;
    self.xAxisView.xyLineColor = self.xyLineColor;
    self.xAxisView.horizontalLineColor = self.horizontalLineColor;
    self.xAxisView.xyTextColor = self.xyTextColor;
    self.xAxisView.leftMargin = self.leftMargin;
    self.xAxisView.backgroundColor = self.xAxisBackColor;
    self.xAxisView.yAxisElements = self.yAxisElements;
    self.xAxisView.bottomHeight = self.bottomHeight;
    
    self.xAxisView.fullToOverflow = self.fullToOverflow;
    self.xAxisView.beagnNeedFull = self.beagnNeedFull;
    self.xAxisView.endNeedFull = self.endNeedFull;
    self.xAxisView.needLastSecondPoint = self.needLastSecondPoint;
    self.xAxisView.beganEqualEnd = self.beganEqualEnd;
    
    self.xAxisView.virtualColor = self.virtualColor;
    self.xAxisView.virtualXArray = self.virtualXArray;
    self.xAxisView.virtualYArray = self.virtualYArray;
    self.xAxisView.virtualYMin = self.virtualYMin;
    self.xAxisView.virtualYMax = self.virtualYMax;
    
    
    if (self.canZoom) {
        // 2. 捏合手势
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
        [self.xTextView addGestureRecognizer:pinch];
    }
    
    [self.scrollView addSubview:self.xAxisView];
    [self.scrollView addSubview:self.xTextView];
    
    self.scrollView.contentSize = self.xAxisView.frame.size;
    if (!self.showAnimation) {
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.lj_width, 0);
    }
}


// 捏合手势监听方法
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer{
    if (!self.canZoom) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (self.xTextView.frame.size.width < self.scrollView.frame.size.width) { //当缩小到小于屏幕宽时，松开恢复屏幕宽度
            
            self.pointGap = (self.scrollView.frame.size.width) / (self.xTitleArray.count + 1);

            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = self.xTextView.frame;
                frame.size.width = self.scrollView.frame.size.width+self.pointGap;
                self.xAxisView.frame = frame;
                self.xTextView.frame = frame;
            }];
            
            self.xAxisView.pointGap = self.pointGap;
            self.xTextView.pointGap = self.pointGap;
            
        }else if (self.xTextView.frame.size.width-self.pointInterval >= self.xTitleArray.count * self.pointInterval){
            
            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = self.xTextView.frame;
                frame.size.width = self.xTitleArray.count * self.pointInterval + self.pointGap;
                self.xAxisView.frame = frame;
                self.xTextView.frame = frame;
                
            }];
            
            self.pointGap = self.pointInterval;
            
            self.xAxisView.pointGap = self.pointGap;
            self.xTextView.pointGap = self.pointGap;
        }
    }else{
        
        CGFloat currentIndex,leftMagin;
        if( recognizer.numberOfTouches == 2 ) {
            //2.获取捏合中心点 -> 捏合中心点距离scrollviewcontent左侧的距离
            CGPoint p1 = [recognizer locationOfTouch:0 inView:self.xTextView];
            CGPoint p2 = [recognizer locationOfTouch:1 inView:self.xTextView];
            CGFloat centerX = (p1.x+p2.x)/2;
            leftMagin = centerX - self.scrollView.contentOffset.x;
            currentIndex = centerX / self.pointGap;
            
            CGFloat tempPointGap = self.pointGap * recognizer.scale;
            if (self.xTitleArray.count * tempPointGap + tempPointGap  < self.scrollView.frame.size.width) {
                //如果 缩放太小了
                return;
            }
            
            self.pointGap *= recognizer.scale;
            self.pointGap = self.pointGap > self.pointInterval ? self.pointInterval : self.pointGap;
            if (self.pointGap == self.pointInterval) {
            }
            self.xAxisView.pointGap = self.pointGap;
            self.xTextView.pointGap = self.pointGap;
            recognizer.scale = 1.0;
            
            
            self.xAxisView.frame = CGRectMake(0, 0, self.xTitleArray.count * self.pointGap + self.pointGap, self.frame.size.height);
            self.xTextView.frame = CGRectMake(0, 0, self.xTitleArray.count * self.pointGap + self.pointGap, self.frame.size.height);
            
            self.scrollView.contentOffset = CGPointMake(currentIndex*self.pointGap-leftMagin, 0);
        }
    }
    self.scrollView.contentSize = CGSizeMake(self.xAxisView.frame.size.width, 0);
}

-(NSInteger)getPointIndexWithLocation:(CGPoint)location{
    CGFloat chartHeight = self.xTextView.frame.size.height - self.bottomHeight - self.topMargin;
    CGFloat totalLength = self.pointGap * self.xTitleArray.count - self.pointGap;
    CGFloat minLength = -1;
    NSInteger nowPoint = -1;
    
    for (NSInteger i = 0; i < self.yValueArray.count; i++) {
        CGPoint pointLocation = CGPointMake(self.pointGap + ([self.yValue2Array[i] floatValue])*totalLength,
                                            chartHeight - ([self.yValueArray[i] floatValue]-self.yMin)/(self.yMax-self.yMin) * chartHeight+self.topMargin);
        CGFloat tempLength = pow(fabs(location.x-pointLocation.x),2) + pow(fabs(location.y-pointLocation.y),2);
        
        //在点的 半径 40个像素内 最小距离的一个点
        if (tempLength < kPointRange && (nowPoint == -1 || (minLength > tempLength))) {
            minLength = tempLength;
            nowPoint = i;
        }
    }
    return nowPoint;
}

- (void)event_tapAction:(UITapGestureRecognizer *)tap{
    CGPoint location = [tap locationInView:self.xTextView];
    NSInteger nowPoint = [self getPointIndexWithLocation:location];
    
    if(nowPoint >= 0 && nowPoint < [self.yValueArray count]) {
        if (self.xTextView.longIndex == nowPoint) {
            self.xTextView.longIndex = -1;
        }else{
            self.xTextView.longIndex = nowPoint;
        }
        if (self.valueChangeHandler) {
            self.valueChangeHandler(self.yValueArray, self.yValue2Array, self.xTextView.longIndex);
        }
    }
}
-(void)setSelectTapIndex:(NSInteger)tapIndex{
    self.xTextView.longIndex = tapIndex;
}


- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress{
    if(UIGestureRecognizerStateBegan == longPress.state) {
        if (self.yValueArray.count < self.maxPointCount) {
            CGPoint location = [longPress locationInView:self.xTextView];
            
            CGFloat chartHeight = self.xTextView.frame.size.height - self.bottomHeight - self.topMargin;
            CGFloat totalLength = self.pointGap * self.xTitleArray.count - self.pointGap;
            
            NSInteger value1 = ((chartHeight - (location.y - self.topMargin))/chartHeight * (self.yMax - self.yMin))+self.yMin;
            CGFloat value2 = (location.x - self.pointGap)/totalLength;
            
            if (value1 < self.yMin) {
                return;
//                value1 = self.yMin;
            }
            if (value1 > self.yMax) {
                return;
//                value1 = self.yMax;
            }
            if (value2 <= 0) {
                return;
//                value2 = 0;
            }
            if (value2 >= 1) {
                return;
//                value2 = 1;
            }
            for (NSInteger i = 0; i < self.yValue2Array.count - 1; i++) {
                if ([self.yValue2Array[i] floatValue] <= value2 && [self.yValue2Array[i+1] floatValue] >= value2) {
                    
                    if (!self.canEqualX && [self.yValue2Array[i+1] floatValue]-[self.yValue2Array[i] floatValue] <= self.minXUnitValue) {
                        //两点之间太近了，不能再添加新的点。。。
                        return;
                    }
                    
                    [self.yValueArray insertObject:@(value1) atIndex:i+1];
                    [self.yValue2Array insertObject:@(value2) atIndex:i+1];
                    
                    self.xTextView.longIndex = i+1;
                    [self.xAxisView refreshLineWithValueArray:self.yValueArray yValue2Array:self.yValue2Array];
                    [self.xTextView refreshLineWithValueArray:self.yValueArray yValue2Array:self.yValue2Array];
                    
                    if (self.valueChangeHandler) {
                        self.valueChangeHandler(self.yValueArray, self.yValue2Array, i+1);
                    }
                    return;
                }
            }
        }
    }
}

- (void)event_panAction:(UIPanGestureRecognizer *)longPress {
    
    if(UIGestureRecognizerStateBegan == longPress.state) {
        CGPoint location = [longPress locationInView:self.xTextView];
        self.startLongY = location.y;
        self.startLongX = location.x;
        
        NSInteger nowPoint = [self getPointIndexWithLocation:location];
        
        if(nowPoint >= 0 && nowPoint < [self.yValueArray count]) {
            self.longIndex = nowPoint;
            [self.xTextView setIsLongPress:YES];
            self.xTextView.longIndex = self.longIndex;
            self.startLongValue = [self.yValueArray[self.longIndex] floatValue];
            self.startLongValue2 = [self.yValue2Array[self.longIndex] floatValue];
            self.oldLongValue = self.startLongValue;
            self.oldLongValue2 = self.startLongValue2;
        }
    }else if(UIGestureRecognizerStateChanged == longPress.state){
        
        if(self.longIndex >= 0 && self.longIndex < [self.yValueArray count]) {
            CGPoint location = [longPress locationInView:self.xTextView];
            CGFloat totalLength = self.pointGap * self.xTitleArray.count - self.pointGap;
            CGFloat yOffset = self.startLongY - location.y;
            CGFloat xOffset = location.x - self.startLongX;
            NSInteger yValue = yOffset * self.oneValueHeight + self.startLongValue;
            CGFloat xValue = xOffset/totalLength + self.startLongValue2;
            
            yValue = yValue-(yValue%self.yOneUnitValue);
            
            //第二个点的最小值
            if (self.longIndex <= 1 && self.secondPointMinValue != 0) {
                if (yValue < self.secondPointMinValue){
                    yValue = self.secondPointMinValue;
                }
            }
            
            //不能超过 最大最小值
            if (yValue > self.yMax) {
                yValue = self.yMax;
            }else if (yValue < self.yMin){
                yValue = self.yMin;
            }
            
            if (self.longIndex == 0) {
                //第一个点 左右不偏移
                if (self.firstPointCanMove) {
                    CGFloat afterValue = [self.yValue2Array[self.longIndex+1] floatValue];
                    if (self.canEqualX) {
                        if (xValue > afterValue) {
                            xValue = afterValue;
                        }
                    }else{
                        if (xValue >= afterValue-(self.minXUnitValue)) {
                            xValue = afterValue-(self.minXUnitValue);
                        }
                    }

                    if (xValue < 0) {
                        xValue = 0;
                    }
                    self.yValue2Array[self.longIndex] = @(xValue);
                }
            }else if(self.longIndex == self.yValueArray.count-1){
                //最后一个 点
                if (self.endPointCanMove) {
                    CGFloat beforValue = [self.yValue2Array[self.longIndex-1] floatValue];
                    if (self.canEqualX) {
                        if (xValue <= beforValue) {
                            xValue = beforValue;
                        }
                    }else{
                        if (xValue <= beforValue+(self.minXUnitValue)) {
                            xValue = beforValue+(self.minXUnitValue);
                        }
                    }

                    if (xValue >= 1) {
                        xValue = 1;
                    }
                    self.yValue2Array[self.longIndex] = @(xValue);
                }
            }else{
                //中间的点
                CGFloat beforValue = [self.yValue2Array[self.longIndex-1] floatValue];
                if (self.canEqualX) {
                    if (xValue <= beforValue) {
                        xValue = beforValue;
                    }
                }else{
                    if (xValue <= beforValue+(self.minXUnitValue)) {
                        xValue = beforValue+(self.minXUnitValue);
                    }
                }
                
                CGFloat afterValue = [self.yValue2Array[self.longIndex+1] floatValue];
                if (self.canEqualX) {
                    if (xValue > afterValue) {
                        xValue = afterValue;
                    }
                }else{
                    if (xValue >= afterValue-(self.minXUnitValue)) {
                        xValue = afterValue-(self.minXUnitValue);
                    }
                }
                
                self.yValue2Array[self.longIndex] = @(xValue);
            }
            
            //判断最后一个值是否是 不能上下移动的。
            if (self.longIndex != self.yValueArray.count-1 || (self.endPointCanVerticalMove)) {
                self.oldLongValue = yValue;
                self.yValueArray[self.longIndex] = @(yValue);
            }
            //收尾一样的值，同时变化
            if (self.beganEqualEnd) {
                if (self.longIndex == 0) {
                    self.yValueArray[self.yValueArray.count-1] = @(yValue);
                }else if (self.longIndex == self.yValueArray.count-1){
                    self.yValueArray[0] = @(yValue);
                }
            }
            
            [self.xAxisView refreshLineWithValueArray:self.yValueArray yValue2Array:self.yValue2Array];
            [self.xTextView refreshLineWithValueArray:self.yValueArray yValue2Array:self.yValue2Array];
            
            if (self.valueChangeHandler) {
                self.valueChangeHandler(self.yValueArray, self.yValue2Array, self.longIndex);
            }
        }
        
    }else if (UIGestureRecognizerStateEnded <= longPress.state){
        [self.xTextView setIsLongPress:NO];
        self.longIndex = -1;
    }
}





@end









