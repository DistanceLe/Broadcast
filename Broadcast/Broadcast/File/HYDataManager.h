//
//  HYDataManager.h
//  CoolMesh
//
//  Created by lijie on 2019/3/26.
//  Copyright © 2019 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kDataManager    [HYDataManager shareManager]


NS_ASSUME_NONNULL_BEGIN

@interface HYDataManager : NSObject<UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, assign)CGFloat safeTop;
@property(nonatomic, assign)CGFloat safeBottom;
@property(nonatomic, assign)CGFloat safeLeft;
@property(nonatomic, assign)CGFloat safeRight;

@property(nonatomic, assign)CGFloat safeWidth;
@property(nonatomic, assign)CGFloat safeHeight;

+(instancetype)shareManager;

-(void)doOnAssembleThread:(void(^)(void))operate;
-(void)doOnBLEThread:(void(^)(void))operate;
/**  在主线程里面 操作 */
-(void)doOnMainThread:(void(^)(void))operate;
/**  在异步线程里执行 */
-(void)doOnAsyncThread:(void(^)(void))operate;




-(UIWindow*)getRootWindws;



#pragma mark - ================ 用来检测 是否包含了表情 ==================
/**  字符串是否包含 表情 emoji */
-(BOOL)stringContainsEmoji:(NSString *)string;

#pragma mark - ================ Json数据 ==================
-(NSString *)dicChangeToJsonString:(id)dict;
- (id)jsonStringChangeToDic:(NSString *)jsonString;

-(NSString *)getImageSizeJsonString:(UIImage*)image;
-(CGSize)getImageSizeWithJsonString:(NSString*)sizeStr;
//@"rgba(7, 180, 7, 0.5)"
-(UIColor*)getColorWithColorStr:(NSString*)colorString;


-(NSInteger)logarithmChangeToNormal:(CGFloat)logarithm;
-(NSInteger)normalChangeToLogarithm:(CGFloat)normal;


/**  子视图 添加到 父视图， 子视图的frame = 父视图的bounds */
-(void)setEqualFrameWithSubViw:(UIView*)subView toSuperView:(UIView*)superView;
-(void)setEqualFrameWithSubViw:(UIView*)subView toSuperView:(UIView*)superView height:(CGFloat)height;



@end

NS_ASSUME_NONNULL_END
