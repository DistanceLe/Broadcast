
#import "QRCodeBackView.h"

@interface QRCodeBackView ()

@property(nonatomic, strong)UIView* boxView;
@property(nonatomic, strong)UIImageView* lingImageView;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,assign)BOOL isUp;

@end

@implementation QRCodeBackView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.lingImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QRGreenLine"]];
    }
    return self;
}

-(void)setScanSize:(CGSize)scanSize
{
    _scanSize=scanSize;
    
    //透明的扫描范围
    CGRect rect=CGRectMake((self.bounds.size.width-scanSize.width)/2, (self.bounds.size.height-scanSize.height)/2, scanSize.width, scanSize.height);
    
    
    UIView* borderView=[self viewWithTag:120];
    if (borderView==nil)
    {
        borderView=[[UIView alloc]initWithFrame:rect];
        borderView.tag=120;
        borderView.backgroundColor=[UIColor clearColor];
        borderView.layer.borderWidth=0.5;
        borderView.layer.borderColor=[UIColor whiteColor].CGColor;
        [self addSubview:borderView];
    }
    borderView.frame=rect;
    
    //扫描范围
    if (self.boxView==nil)
    {
        self.boxView=[[UIView alloc]init];
        self.boxView.backgroundColor=[UIColor clearColor];
    }
    self.boxView.frame=rect;
    for (NSInteger i=0; i<4; i++)
    {
        UIImageView* cornImageView=[self.boxView viewWithTag:123+i];
        
        if (cornImageView==nil)
        {
            cornImageView=[[UIImageView alloc]init];
            cornImageView.tag=123+i;
            NSString* imageName=[NSString stringWithFormat:@"cor%ld",i+1];
            cornImageView.image=[UIImage imageNamed:imageName];
            [self.boxView addSubview:cornImageView];
        }
        CGRect imageRect=CGRectMake(i%2*(CGRectGetWidth(_boxView.frame)-12)-2, (int)[@(i/2) boolValue] *(CGRectGetHeight(_boxView.frame)-11)-2, 15, 15);
        cornImageView.frame=imageRect;
    }
    
    //扫描线：
    self.lingImageView.frame=CGRectMake(0, (CGRectGetHeight(self.boxView.frame)-3)/2.0f, CGRectGetWidth(self.boxView.frame), 10);
    
    if (self.boxView.superview !=self)
    {
        [self.boxView addSubview:self.lingImageView];
        [self addSubview:self.boxView];
    }
}

-(void)startRun
{
    [self.timer invalidate];
    self.timer=nil;
    self.timer=[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(moveScaneLine) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer fire];
}
-(void)stopRun
{
    [self.timer invalidate];
    self.timer=nil;
}

-(void)moveScaneLine
{
    CGRect frame=self.lingImageView.frame;
    if (CGRectGetMaxY(frame)>=CGRectGetHeight(self.boxView.frame)-5)
    {
        _isUp=YES;
    }
    else if (CGRectGetMinY(frame)<=5)
    {
        _isUp=NO;
    }
    
    if (!_isUp)
    {
        frame.origin.y+=10;
    }
    else
    {
        frame.origin.y-=10;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.lingImageView.frame=frame;
    }];
}

-(void)drawRect:(CGRect)rect
{
    [self drawClearnBox];
}
-(void)drawClearnBox
{
    //透明的扫描范围
    CGRect rect=CGRectMake((self.bounds.size.width-_scanSize.width)/2, (self.bounds.size.height-_scanSize.height)/2, _scanSize.width, _scanSize.height);
    
    UIRectFill(rect);
    UIRectFillUsingBlendMode(rect, kCGBlendModeClear);
}






@end
