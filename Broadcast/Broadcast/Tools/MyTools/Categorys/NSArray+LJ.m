//
//  NSArray+LJ.m
//  Hytronik
//
//  Created by lijie on 2018/4/8.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import "NSArray+LJ.h"
#import <objc/runtime.h>


@implementation NSArray (LJ)

//+ (void)load
//{
//    Method origin =class_getInstanceMethod([NSArray class], @selector(addObject:));
//    Method hooked =class_getInstanceMethod([NSArray class],@selector(addObjectHooked:));
//
//    method_exchangeImplementations(origin, hooked);
//
//    origin =class_getInstanceMethod([NSArray class], @selector(insertObject:atIndex:));
//    hooked =class_getInstanceMethod([NSArray class],@selector(insertObjectHooked:atIndex:));
//
//    method_exchangeImplementations(origin, hooked);
//
//
//    origin =class_getInstanceMethod([NSMutableArray class], @selector(addObject:));
//    hooked =class_getInstanceMethod([NSMutableArray class],@selector(addObjectHooked:));
//
//    method_exchangeImplementations(origin, hooked);
//
//    origin =class_getInstanceMethod([NSMutableArray class], @selector(insertObject:atIndex:));
//    hooked =class_getInstanceMethod([NSMutableArray class],@selector(insertObjectHooked:atIndex:));
//
//    method_exchangeImplementations(origin, hooked);
//}
//
//-(void)addObjectHooked:(id)obj{
//    if (!obj) {
//        obj = @"";
//    }
//    [self addObjectHooked:obj];
//}
//
//-(void)insertObjectHooked:(id)obj atIndex:(NSInteger)index{
//    if(!obj){
//        obj = @"";
//    }
//    [self insertObjectHooked:obj atIndex:index];
//}

@end
