//
//  Common.h
//  StarWristSport
//
//  Created by celink on 17/1/5.
//  Copyright © 2017年 celink. All rights reserved.
//
#ifndef Common_h
#define Common_h

#define DIR_DOC            [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

// system
#define IOS_SystemVersion [[UIDevice currentDevice].systemVersion doubleValue]

/**  判断是否是iPhone X     20->44    49->83 */
//#define Is_iPhoneX ([HYDataManager checkIsIphoneX])
#define Is_iPad    ([[UIDevice currentDevice].model isEqualToString:@"iPad"])

#define IPHONE_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define IPHONE_WIDTH [[UIScreen mainScreen] bounds].size.width


#define kRandom(limit)          (arc4random()%(limit))
#define kIFISNULL(v)            ([v isEqualToString:@""] || v==nil || v==NULL)


#define kRGBColor(r, g, b, a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kHEXCOLOR(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kSystemColor            kRGBColor(244, 124, 29, 1.0)//红色
#define kSelectColor            kRGBColor(244, 124, 29, 1.0)//红色
//#define kBarColor               kRGBColor(28, 100, 190, 1.0)//蓝色
//#define kBarColor               kRGBColor(0, 130, 48, 1.0)//绿色


#define kTextColor              kRGBColor(15, 15, 15, 1.0)//淡黑色
#define kSubTextColor           kRGBColor(100, 100, 100, 1.0)//淡黑色
#define kVCBackColor            kRGBColor(240, 240, 240, 1.0)//浅灰色

#define kBLEBreakColor          kRGBColor(150, 150, 150, 1.0) //灰色
//#define kBLESearchColor         kRGBColor(184, 208, 90, 1.0) //浅绿色

//ff7f63 警告色
#define kMeshBreakColor         kRGBColor(255, 127, 99, 1.0)  //浅红色，警告色
#define kWarningColor           kRGBColor(255, 127, 99, 1.0)  //浅红色，警告色
#define kGuideBackColor         kSystemColor  //浅红色，警告色






/**  Weakify  Strongify */
#ifndef weakify
#if DEBUG       //===========
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else           //===========
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif          //===========
#endif


#ifndef strongify
#if DEBUG       //+++++++++++
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else           //+++++++++++
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif          //+++++++++++
#endif


#endif /* Common_h */
