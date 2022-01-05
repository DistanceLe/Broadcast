//
//  LJNodeView.h
//  Broadcast
//
//  Created by lijie on 2021/12/31.
//

#import "LJGestureView.h"
#import "LJCmdData.h"


NS_ASSUME_NONNULL_BEGIN

@interface LJNodeView : LJGestureView

@property(nonatomic, assign)NSInteger nodeAddress;
//@property(nonatomic, assign)NSInteger range;

@property(nonatomic, assign)NSInteger receiptCount;
@property(nonatomic, assign)NSInteger sendCount;

/**  通知，多久后能收到 指令 */
-(void)receiptCmd:(LJCmdData*)cmd delay:(CGFloat)delay;

/**  第一个节点， 需要调用 开始第一次发送 */
-(void)sendCmd:(LJCmdData*)cmd;


@end

NS_ASSUME_NONNULL_END
