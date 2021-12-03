//
//  LJLanguage.m
//  Hytronik
//
//  Created by lijie on 2018/6/22.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import "LJLanguage.h"

@implementation LJLanguage

static NSBundle *bundle = nil;

/**  获取当前资源文件 */
+(NSBundle *)bundle{
    if(!bundle){
        LanguageType langKind = [self languageKind];
        [self setUserlanguage:langKind];
    }
    return  bundle;
}

+(LanguageType)languageKind{
    NSNumber* customLanguage = [[NSUserDefaults standardUserDefaults]objectForKey:@"customLanguage"];
    if (customLanguage) {
        if (customLanguage.intValue == LanguageType_SimpleChines || customLanguage.intValue == LanguageType_TraditionalChinese) {
            return LanguageType_English;
        }
        return (LanguageType)customLanguage.integerValue;
    }
    
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    
    if ([preferredLang hasPrefix:@"en"]){
        return  LanguageType_English;
    }
//    else if ([preferredLang hasPrefix:@"zh-Hans"]){
//        return LanguageType_SimpleChines;
//    }else if ([preferredLang hasPrefix:@"zh-Hant"]){
//        return LanguageType_TraditionalChinese;
//    }
    else if ([preferredLang hasPrefix:@"de"]){
        return LanguageType_Gemman;
    }
    else if ([preferredLang hasPrefix:@"sv"]){
        return LanguageType_Swedish;
    }
//    else if ([preferredLang hasPrefix:@"fi"]){
//        return LanguageType_Finnish;
//    }
    else if ([preferredLang hasPrefix:@"fr"]){
        return LanguageType_French;
    }
    else if ([preferredLang hasPrefix:@"it"]){
        return LanguageType_Italian;
    }
    else if ([preferredLang hasPrefix:@"pl"]){
        return LanguageType_Polish;
    }
    else if ([preferredLang hasPrefix:@"cs"]){
        return LanguageType_Czech;
    }
    else{
#if RELCO
        return LanguageType_Italian;
#elif LENA
        return LanguageType_Polish;
#elif RESISTEX
        return LanguageType_French;
#else
        return LanguageType_English;
#endif
    }
}


+(void)setUserlanguage:(LanguageType)langKind{
    NSString *langName = @"";
    if(langKind == LanguageType_English || langKind == LanguageType_Other){
        langName = @"en";
    }
//    else if(langKind == LanguageType_SimpleChines) {
//        langName = @"zh-Hans";
//    }else if(langKind == LanguageType_TraditionalChinese){
//        langName = @"zh-Hant";
//    }
    else if(langKind == LanguageType_Gemman){
        langName = @"de";
    }
    else if(langKind == LanguageType_Swedish){
        langName = @"sv";
    }
//    else if(langKind == LanguageType_Finnish){
//        langName = @"fi";
//    }
    else if(langKind == LanguageType_French){
        langName = @"fr";
    }
    else if(langKind == LanguageType_Italian){
        langName = @"it";
    }
    else if(langKind == LanguageType_Polish){
        langName = @"pl";
    }
    else if(langKind == LanguageType_Czech){
        langName = @"cs";
    }
    else{
#if RELCO
        langName = @"it";
#elif LENA
        langName = @"pl";
#elif RESISTEX
        langName = @"fr";
#else
        langName = @"en";
#endif
        
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:langName ofType:@"lproj"];
    bundle = [NSBundle bundleWithPath:path];
}

+(void)setUserCustomlanguage:(LanguageType)langKind{
    bundle = nil;
    [[NSUserDefaults standardUserDefaults]setObject:@(langKind) forKey:@"customLanguage"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
