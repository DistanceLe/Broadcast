//
//  NSNotificationCenter+LJ.h
//  LJTrack
//
//  Created by LiJie on 16/6/15.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (LJ)

/**  添加通知，一个name 可以对应多个接收，需subName来区分 */
-(void)addObserverName:(NSString*)name subName:(NSString*)subName object:(id)obj handler:(StatusBlock)handler;

/**  移除通知，subName为空，则移除所有的name监听 */
-(void)removeHandlerObserverWithName:(NSString *)name subName:(NSString*)subName object:(id)obj;

@end
