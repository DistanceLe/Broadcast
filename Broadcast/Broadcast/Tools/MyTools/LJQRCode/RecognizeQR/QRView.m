//
//  QRView.m
//  二维码
//
//  Created by LiJie on 15/11/5.
//  Copyright © 2015年 LiJie. All rights reserved.
//

#import "QRView.h"
#import "QRCodeBackView.h"

#import <AVFoundation/AVFoundation.h>

@interface QRView ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong)QRBlock tempBlock;
@property(nonatomic, weak)UIViewController* contentVC;

@property(nonatomic, strong)AVCaptureSession* captureSession;//CaptureSession 这是个捕获会话，也就是说你可以用这个对象从输入设备捕获数据流
@property(nonatomic, strong)AVCaptureVideoPreviewLayer* videoPreviewLayer;//AVCaptureVideoPreviewLayer 可以通过输出设备展示被捕获的数据流。首先我们应该判断当前设备是否有捕获数据流的设备
@property(nonatomic, strong)AVCaptureMetadataOutput* captureOutput;
@property(nonatomic, strong)AVCaptureDeviceInput*    deviceInput;
@property(nonatomic, strong)AVCaptureDevice*         captureDevice;
@property(nonatomic, strong)QRCodeBackView* backView;

@end

@implementation QRView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backView=[[QRCodeBackView alloc]initWithFrame:self.bounds];
        self.QRBackgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.8];
        self.QRScanSize=CGSizeMake(CGRectGetWidth(frame)/2.0, CGRectGetWidth(frame)/2.0);
    }
    return self;
}

+(instancetype)getQRViewWithFrame:(CGRect)frame showViewController:(UIViewController*)viewController result:(QRBlock)resultBlock{
    
    QRView* tempSelf=[[QRView alloc]initWithFrame:frame];
    tempSelf.contentVC = viewController;
    tempSelf.tempBlock=resultBlock;
    [tempSelf initScan];
    return tempSelf;
}

+(instancetype)setQRCodeToViewController:(UIViewController *)contentVC result:(QRBlock)resultBlock{
    QRView* tempSelf=[[QRView alloc]initWithFrame:contentVC.view.bounds];
    tempSelf.contentVC=contentVC;
    tempSelf.tempBlock=resultBlock;
    [tempSelf initScan];
    [contentVC.view addSubview:tempSelf];
    return tempSelf;
}
-(void)startScan{
    
    [self.captureSession startRunning];
    [self.backView startRun];
}
-(void)stopScan{
    
    [self.captureSession stopRunning];
    [self.backView stopRun];
}

-(void)setQRBackgroundColor:(UIColor *)QRBackgroundColor{
    
    _QRBackgroundColor=QRBackgroundColor;
    self.backView.backgroundColor=_QRBackgroundColor;
}

-(void)setQRScanSize:(CGSize)QRScanSize{
    
    self.backView.frame = self.bounds;
    _QRScanSize=QRScanSize;
    self.backView.scanSize=_QRScanSize;
    
    
    //设置扫描范围
//    CGFloat width=_QRScanSize.width/CGRectGetWidth(self.frame);
//    CGFloat height=_QRScanSize.height/CGRectGetHeight(self.frame);
//    if (self.captureOutput!=nil){
//        [self.captureOutput setRectOfInterest:CGRectMake((1-height)/2, (1-width)/2, height, width)];
//        [self.captureOutput setRectOfInterest:CGRectMake(0, 0, 1, 1)];
//    }
    if (self.videoPreviewLayer) {
        [self.videoPreviewLayer setFrame:CGRectMake((CGRectGetWidth(self.frame)-self.QRScanSize.width)/2.0,
                                                    (CGRectGetHeight(self.frame)-self.QRScanSize.height)/2.0,
                                                    self.QRScanSize.width, self.QRScanSize.height)];
        [self refreshOrientation];
    }
}

-(void)refreshOrientation{
    //横竖屏 刷新
    AVCaptureVideoOrientation avOrientation = AVCaptureVideoOrientationPortrait;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:{
            avOrientation = AVCaptureVideoOrientationPortrait;
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:{
            avOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        }
        case UIDeviceOrientationLandscapeLeft:{
            avOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        }
        case UIDeviceOrientationLandscapeRight:{
            avOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        }
        default:
            break;
    }
    self.videoPreviewLayer.connection.videoOrientation = avOrientation;
}

/**  初始化 扫描镜头 */
-(void)initScan{
    
    self.captureDevice=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError* error=nil;
    
    //判断是否有相机
    self.deviceInput=[AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    if (!self.deviceInput){
        NSLog(@"出错啦：%@",error);
        return;
    }else{
        
        self.captureSession=[[AVCaptureSession alloc]init];
        [self.captureSession addInput:self.deviceInput];
        
        //输出
        self.captureOutput=[[AVCaptureMetadataOutput alloc]init];
        [self.captureSession addOutput:self.captureOutput];
        
        //设置默认扫描范围
//        CGFloat width=self.QRScanSize.width/CGRectGetWidth(self.frame);
//        CGFloat height=self.QRScanSize.height/CGRectGetHeight(self.frame);
//        [self.captureOutput setRectOfInterest:CGRectMake((1-height)/2, (1-width)/2, height, width)];
        
        self.captureOutput.metadataObjectTypes=@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeDataMatrixCode];
        
        //创建一个队列
        dispatch_queue_t dispatchQueue=dispatch_queue_create("myQueue", NULL);
        [self.captureOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
//        [self.captureOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        //显示相机捕获的场景
        self.videoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        [self refreshOrientation];
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.videoPreviewLayer setFrame:CGRectMake((CGRectGetWidth(self.frame)-self.QRScanSize.width)/2.0,
                                                    (CGRectGetHeight(self.frame)-self.QRScanSize.height)/2.0,
                                                    self.QRScanSize.width, self.QRScanSize.height)];
        [self.layer addSublayer:self.videoPreviewLayer];
        
        //设置背景
        [self addSubview:self.backView];
    }
}

#pragma mark - ================ 扫描代理 ==================
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    //判断是否有数据，是否是二维码
    if (metadataObjects!=nil && [metadataObjects count]>0){
        
        AVMetadataMachineReadableCodeObject* metadataObject=[metadataObjects objectAtIndex:0];
        if ([[metadataObject type]isEqualToString:AVMetadataObjectTypeQRCode] ||
            [[metadataObject type]isEqualToString:AVMetadataObjectTypeDataMatrixCode]){
            
            NSString* resultStr=metadataObject.stringValue;
            [self stopScan];
            
            if (self.tempBlock){
                self.tempBlock(resultStr);
            }
        }
    }
}

#pragma mark - ================ 打开闪光灯 ==================
-(void)openFlash{
    AVCaptureDevicePosition position = [[self.deviceInput device] position];
    if (position == AVCaptureDevicePositionFront) {
        [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
    }else{
        //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
        if ([self.captureDevice lockForConfiguration:nil]) {
            //摄像模式
            if (self.captureDevice.torchMode == AVCaptureTorchModeOn) {
                //打开模式，现在去关闭闪光灯
                if ([self.captureDevice isTorchModeSupported:AVCaptureTorchModeOff]) {
                    [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
                }
            }else{
                if ([self.captureDevice isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
                }
            }
            [self.captureDevice unlockForConfiguration];
        }
    }
}
/**  获取闪光灯是否打开 */
-(BOOL)getFlashIsOpen{
    if (self.captureDevice.torchMode == AVCaptureTorchModeOn) {
        return YES;
    }
    return NO;
}
#pragma mark - ================ 打开系统相册 ==================
-(void)openSystemAlbum{
    if (!self.contentVC) {
        return;
    }
    
    UIImagePickerController* picker=[[UIImagePickerController alloc]init];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate=self;
    //picker.allowsEditing=YES;
    
    [self.contentVC presentViewController:picker animated:YES completion:nil];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    if (self.tempBlock) {
        self.tempBlock(nil);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage* image=[info valueForKey:@"UIImagePickerControllerEditedImage"];
    if (!image) {
        image=[info valueForKey:@"UIImagePickerControllerOriginalImage"];
        //NSData* imageData=UIImageJPEGRepresentation(image, 0.1);
        //image=[UIImage imageWithData:imageData];
    }
    [self recognizeImageQRcode:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)recognizeImageQRcode:(UIImage*)image{
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        //NSLog(@"result:/n%@",scannedResult);
        if (self.tempBlock) {
            self.tempBlock(scannedResult);
        }
    }
    if (features.count==0) {
        if (self.tempBlock) {
            self.tempBlock(nil);
        }
    }
}

@end
