//
//  LJCmdData.h
//  Broadcast
//
//  Created by lijie on 2021/12/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJCmdData : NSObject

@property(nonatomic, assign)NSInteger cmdID;
@property(nonatomic, assign)NSInteger ttl;
//@property(nonatomic, assign)NSInteger originalAddress;

@property(nonatomic, strong)NSMutableArray*  addressOnTheWay;


@end

NS_ASSUME_NONNULL_END
