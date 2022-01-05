//
//  LJCmdData.m
//  Broadcast
//
//  Created by lijie on 2021/12/31.
//

#import "LJCmdData.h"

@implementation LJCmdData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.addressOnTheWay = [NSMutableArray array];
        self.ttl = kDataManager.ttl;
        
        self.cmdID = [[NSDate date]timeIntervalSince1970]*10;
    }
    return self;
}

@end
