//
//  ConstString.h
//  LJTrack
//
//  Created by LiJie on 16/6/14.
//  Copyright © 2016年 LiJie. All rights reserved.
//

#ifndef ConstString_h
#define ConstString_h

typedef void(^StatusBlock)(id sender, id status);
typedef void(^isOKBlock)(BOOL isOK);
typedef void(^completBlock)(BOOL isOK);
typedef void(^dicBlock)(NSDictionary* dic);
typedef void(^requestBackBlock)(id returnValue, NSInteger statusCode, NSError *error);

static NSString* const cellIdentify = @"cellIdentify";
static NSString* const cellIdentify1 = @"cellIdentify1";
static NSString* const cellIdentify2 = @"cellIdentify2";
static NSString* const cellIdentify3 = @"cellIdentify3";
static NSString* const cellIdentify4 = @"cellIdentify4";
static NSString* const headIdentify = @"headIdentify";


static NSString* const sliderTouchBegin = @"sliderTouchBegin";
static NSString* const sliderTouchEnd = @"sliderTouchEnd";



static NSString* const nodeIdKey = @"nodeID";
static NSString* const nodesKey = @"nodes";

static NSString* const rangeKey = @"rangeKey";
static NSString* const ttlKey = @"ttlKey";
static NSString* const speedKey = @"speedKey";

static NSString* const rangeChange = @"rangeChange";
static NSString* const rangeShowChange = @"rangeShowChange";
static NSString* const infoShowChange = @"infoShowChange";
static NSString* const cleanInfo = @"cleanInfo";

#endif /* ConstString_h */

