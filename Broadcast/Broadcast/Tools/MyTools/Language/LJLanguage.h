//
//  LJLanguage.h
//  Hytronik
//
//  Created by lijie on 2018/6/22.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**  语言国际化 */
#define LS(str_key) ([[LJLanguage bundle] localizedStringForKey:str_key value:nil table:@"Localizable"])

typedef NS_ENUM(NSUInteger, LanguageType) {
    LanguageType_English,
    LanguageType_SimpleChines,
    LanguageType_TraditionalChinese,
    LanguageType_Gemman,
    
    LanguageType_Swedish,
    LanguageType_French,
    LanguageType_Italian,
    
    LanguageType_Polish,//波兰语
    LanguageType_Czech,//捷克语
    
    
    LanguageType_Other,
//    LanguageType_Finnish,
};


@interface LJLanguage : NSObject

/**  获取当前资源文件 */
+(NSBundle *)bundle;

/**  获取当前语言 */
+(LanguageType)languageKind;

/**  设置当前语言 */
+(void)setUserCustomlanguage:(LanguageType)langKind;



@end








