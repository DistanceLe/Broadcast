//
//  HYDataManager.m
//  CoolMesh
//
//  Created by lijie on 2019/3/26.
//  Copyright © 2019 lijie. All rights reserved.
//

#import "HYDataManager.h"

#import "AppDelegate.h"


@interface HYDataManager()


@property (strong, nonatomic) dispatch_queue_t assembleQueue;
@property (strong, nonatomic) dispatch_queue_t BLEQueue;


@end


@implementation HYDataManager


+(instancetype)shareManager{
    static HYDataManager* shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[HYDataManager alloc]init];
        shareManager.BLEQueue = dispatch_queue_create("com.lijie.BLE", DISPATCH_QUEUE_SERIAL);
        shareManager.assembleQueue = dispatch_queue_create("com.lijie.assemble", DISPATCH_QUEUE_SERIAL);
    });
    return shareManager;
}

-(CGFloat)safeTop{
    if (@available(iOS 11.0, *)) {
        _safeTop = [kDataManager getRootWindws].safeAreaInsets.top;
        return _safeTop;
    } else {
        _safeTop = 20;
        return _safeTop;
    }
}
-(CGFloat)safeBottom{
    if (@available(iOS 11.0, *)) {
        _safeBottom = [kDataManager getRootWindws].safeAreaInsets.bottom;
        return _safeBottom;
    } else {
        _safeBottom = 0;
        return _safeBottom;
    }
}
-(CGFloat)safeLeft{
    if (@available(iOS 11.0, *)) {
        _safeLeft = [kDataManager getRootWindws].safeAreaInsets.left;
        return _safeLeft;
    } else {
        _safeLeft = 0;
        return _safeLeft;
    }
}
-(CGFloat)safeRight{
    if (@available(iOS 11.0, *)) {
        _safeRight = [kDataManager getRootWindws].safeAreaInsets.right;
        return _safeRight;
    } else {
        _safeRight = 0;
        return _safeRight;
    }
}
-(CGFloat)safeWidth{
    return IPHONE_WIDTH - kDataManager.safeLeft-kDataManager.safeRight;
}
-(CGFloat)safeHeight{
    return IPHONE_HEIGHT - kDataManager.safeTop-kDataManager.safeBottom;
}


-(void)doOnBLEThread:(void(^)(void))operate{
    
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(self.BLEQueue)) == 0) {
        operate();
    } else {
        dispatch_async(self.BLEQueue, operate);
    }
}
-(void)doOnAssembleThread:(void(^)(void))operate{
    
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(self.assembleQueue)) == 0) {
        operate();
    } else {
        dispatch_async(self.assembleQueue, operate);
    }
}
/**  在主线程里面 操作 */
-(void)doOnMainThread:(void(^)(void))operate{
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {
        operate();
    } else {
        dispatch_async(dispatch_get_main_queue(), operate);
    }
}
/**  在异步线程里执行 */
-(void)doOnAsyncThread:(void(^)(void))operate{
    dispatch_async(dispatch_get_global_queue(0, 0), operate);
}




-(UIWindow*)getRootWindws{
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return delegate.window;
}



#pragma mark - ================ 用来检测 是否包含了表情 ==================
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([kDataManager stringContainsEmoji:text]) {
        return NO;
    }
    if (textView.text.length - range.length + text.length > 200) {
        //字符串超过了200个字
        return NO;
    }
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([kDataManager stringContainsEmoji:string]) {
        return NO;
    }
    if (textField.text.length - range.length + string.length > 41 &&
        textField.keyboardType != UIKeyboardTypeEmailAddress && string.length > 0) {
        //字符串超过了40个字 (不是邮箱的输入框)
        return NO;
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.keyboardType == UIKeyboardTypeEmailAddress && [textField.text containsString:@" "]) {
        
        NSMutableString* tempString = [NSMutableString stringWithString:textField.text];
        [tempString replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, tempString.length)];
        textField.text = tempString;
    }
}

-(BOOL)stringContainsEmoji:(NSString *)string{
    NSUInteger len = [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (len < 3) {// 大于2个字符需要验证Emoji(有些Emoji仅三个字符)
        return NO;
    }// 仅考虑字节长度为3的字符,大于此范围的全部做Emoji处理
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];Byte *bts = (Byte *)[data bytes];
    Byte bt;
    short v;
    for (NSUInteger i = 0; i < len; i++) {
        bt = bts[i];
        
        if ((bt | 0x7F) == 0x7F) {// 0xxxxxxxASIIC编码
            continue;
        }
        if ((bt | 0x1F) == 0xDF) {// 110xxxxx两个字节的字符
            i += 1;
            continue;
        }
        if ((bt | 0x0F) == 0xEF) {// 1110xxxx三个字节的字符(重点过滤项目)
            // 计算Unicode下标
            v = bt & 0x0F;
            v = v << 6;
            v |= bts[i + 1] & 0x3F;
            v = v << 6;
            v |= bts[i + 2] & 0x3F;
            
            // NSLog(@"%02X%02X", (Byte)(v >> 8), (Byte)(v & 0xFF));
            if ([self emojiInSoftBankUnicode:v] || [self emojiInUnicode:v]) {
                return YES;
            }
            
            i += 2;
            continue;
        }
        if ((bt | 0x3F) == 0xBF) {// 10xxxxxx10开头,为数据字节,直接过滤
            continue;
        }
        
        return YES; // 不是以上情况的字符全部超过三个字节,做Emoji处理
    }return NO;
}
- (BOOL) emojiInSoftBankUnicode:(short)code
{
    return ((code >> 8) >= 0xE0 && (code >> 8) <= 0xE5 && (Byte)(code & 0xFF) < 0x60);
}
- (BOOL) emojiInUnicode:(short)code
{
    if (code == 0x0023
        || code == 0x002A
        || (code >= 0x0030 && code <= 0x0039)
        || code == 0x00A9
        || code == 0x00AE
        || code == 0x203C
        || code == 0x2049
        || code == 0x2122
        || code == 0x2139
        || (code >= 0x2194 && code <= 0x2199)
        || code == 0x21A9 || code == 0x21AA
        || code == 0x231A || code == 0x231B
        || code == 0x2328
        || code == 0x23CF
        || (code >= 0x23E9 && code <= 0x23F3)
        || (code >= 0x23F8 && code <= 0x23FA)
        || code == 0x24C2
        || code == 0x25AA || code == 0x25AB
        || code == 0x25B6
        || code == 0x25C0
        || (code >= 0x25FB && code <= 0x25FE)
        || (code >= 0x2600 && code <= 0x2604)
        || code == 0x260E
        || code == 0x2611
        || code == 0x2614 || code == 0x2615
        || code == 0x2618
        || code == 0x261D
        || code == 0x2620
        || code == 0x2622 || code == 0x2623
        || code == 0x2626
        || code == 0x262A
        || code == 0x262E || code == 0x262F
        || (code >= 0x2638 && code <= 0x263A)
        || (code >= 0x2648 && code <= 0x2653)
        || code == 0x2660
        || code == 0x2663
        || code == 0x2665 || code == 0x2666
        || code == 0x2668
        || code == 0x267B
        || code == 0x267F
        || (code >= 0x2692 && code <= 0x2694)
        || code == 0x2696 || code == 0x2697
        || code == 0x2699
        || code == 0x269B || code == 0x269C
        || code == 0x26A0 || code == 0x26A1
        || code == 0x26AA || code == 0x26AB
        || code == 0x26B0 || code == 0x26B1
        || code == 0x26BD || code == 0x26BE
        || code == 0x26C4 || code == 0x26C5
        || code == 0x26C8
        || code == 0x26CE
        || code == 0x26CF
        || code == 0x26D1
        || code == 0x26D3 || code == 0x26D4
        || code == 0x26E9 || code == 0x26EA
        || (code >= 0x26F0 && code <= 0x26F5)
        || (code >= 0x26F7 && code <= 0x26FA)
        || code == 0x26FD
        || code == 0x2702
        || code == 0x2705
        || (code >= 0x2708 && code <= 0x270D)
        || code == 0x270F
        || code == 0x2712
        || code == 0x2714
        || code == 0x2716
        || code == 0x271D
        || code == 0x2721
        || code == 0x2728
        || code == 0x2733 || code == 0x2734
        || code == 0x2744
        || code == 0x2747
        || code == 0x274C
        || code == 0x274E
        || (code >= 0x2753 && code <= 0x2755)
        || code == 0x2757
        || code == 0x2763 || code == 0x2764
        || (code >= 0x2795 && code <= 0x2797)
        || code == 0x27A1
        || code == 0x27B0
        || code == 0x27BF
        || code == 0x2934 || code == 0x2935
        || (code >= 0x2B05 && code <= 0x2B07)
        || code == 0x2B1B || code == 0x2B1C
        || code == 0x2B50
        || code == 0x2B55
        || code == 0x3030
        || code == 0x303D
        || code == 0x3297
        || code == 0x3299
        // 第二段
        || code == 0x23F0) {
        return YES;
    }
    return NO;
}

#pragma mark - ================ Json数据 ==================
-(NSString *)dicChangeToJsonString:(id)dict{

    //NSData 的数据不能转成 Json 的数据
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSArray* allKeys = [tempDic allKeys];
        for (NSString* tempKey in allKeys) {
            if ([[tempDic valueForKey:tempKey] isKindOfClass:[NSData class]]) {
                [tempDic removeObjectForKey:tempKey];
                DLog(@"❌不能转json：%@", tempKey);
            }
        }
        dict = tempDic;
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = @"";
    if (!jsonData) {
        DLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    //去掉字符串中的空格
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    
    //去掉字符串中的换行符
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    NSRange range3 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\\" withString:@"" options:NSCaseInsensitiveSearch range:range3];
    

    return mutStr;
}
- (id)jsonStringChangeToDic:(NSString *)jsonString
{
    if (!jsonString || jsonString == NULL || ![jsonString isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        DLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
-(NSString *)getImageSizeJsonString:(UIImage*)image{
    int width = image.size.width;
    int height = image.size.height;
    NSDictionary* sizeDic = @{@"height":@(height), @"width":@(width)};
    return [self dicChangeToJsonString:sizeDic];
}
-(CGSize)getImageSizeWithJsonString:(NSString*)sizeStr{
    NSDictionary* sizeDic = [self jsonStringChangeToDic:sizeStr];
    
    if (sizeDic && [[sizeDic valueForKey:@"height"]intValue] && [[sizeDic valueForKey:@"width"]intValue]) {
        return CGSizeMake([[sizeDic valueForKey:@"width"]intValue], [[sizeDic valueForKey:@"height"]intValue]);
    }else{
        return CGSizeMake(1000, 1000);
    }
}
//@"rgba(7, 180, 7, 0.5)"
-(UIColor*)getColorWithColorStr:(NSString*)colorString{
    if ([colorString hasPrefix:@"rgba("]) {
        NSString* colorStr = [colorString substringWithRange:NSMakeRange(@"rgba(".length, colorString.length-@"rgba()".length)];
        NSArray* valuesArray = [colorStr componentsSeparatedByString:@","];
        if (valuesArray.count == 4) {
            int red = [valuesArray[0] intValue];
            int green = [valuesArray[1] intValue];
            int blue = [valuesArray[2] intValue];
            CGFloat alpha = [valuesArray[3] floatValue];
            
            return kRGBColor(red, green, blue, alpha);
        }else{
            return kRGBColor(21, 165, 56, 0.8);
        }
    }else{
        return kRGBColor(21, 165, 56, 0.8);
    }
}


-(NSInteger)logarithmChangeToNormal:(CGFloat)logarithm{
    CGFloat power = ((logarithm*655.35-1)/(65534/3.0)-1);
    NSInteger value = powf(10, power);
    return value;
}
-(NSInteger)normalChangeToLogarithm:(CGFloat)normal{
    NSInteger lightness = (log10(normal) + 1) * (65534/3.0) + 1;
    NSInteger value = (lightness/655.35);
    return value;
}


/**  子视图 添加到 父视图， 子视图的frame = 父视图的bounds */
-(void)setEqualFrameWithSubViw:(UIView*)subView toSuperView:(UIView*)superView{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [superView addSubview:subView];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [superView addConstraints:@[left, bottom, right, top]];
}

-(void)setEqualFrameWithSubViw:(UIView*)subView toSuperView:(UIView*)superView height:(CGFloat)height{
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [superView addSubview:subView];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    [superView addConstraints:@[left, right, top]];
    
    
    NSLayoutConstraint *heighValue = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:height];
    [subView addConstraint:heighValue];
}



@end














