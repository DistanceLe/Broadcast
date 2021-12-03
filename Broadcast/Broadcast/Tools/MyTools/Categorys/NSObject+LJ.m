//
//  NSObject+LJ.m
//  Hytronik
//
//  Created by lijie on 2018/4/24.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import "NSObject+LJ.h"
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@implementation NSObject (LJ)

/**  获取所有的属性 */
- (NSArray*)getAllProperty{
    NSMutableArray *protertysArray = [NSMutableArray array];
    
    //  取得当前类类型
    Class cls = [self class];
    
    do {
        unsigned int ivarsCnt = 0;
        //　获取类成员变量列表，ivarsCnt为类成员数量
        //Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
        objc_property_t *properties =class_copyPropertyList(cls, &ivarsCnt);
        
        //　遍历成员变量列表，其中每个变量都是Ivar类型的结构体
        //for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
        for (int i = 0; i < ivarsCnt; i++)
        {
            //Ivar const ivar = *p;
            //　 获取变量名
            //   NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            //  若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
            //  比如 @property(retain) NSString *abc;则 key == _abc;
            //　获取变量值
            //id value = [self valueForKey:key];
            //
            objc_property_t property = properties[i];
            const char* char_f =property_getName(property);
            NSString *key = [NSString stringWithUTF8String:char_f];
            
            if (![protertysArray containsObject:key]) {
                [protertysArray addObject:key];
            }
        }
        free(properties);
        
        
        //如果是 下一个是NSObjective  或者 数据库CoreData的对象，则不再遍历
        cls = class_getSuperclass(cls);
        if (cls == [NSObject class] || cls == [NSManagedObject class]) {
            break;
        }
    } while (1);
    return protertysArray;
}

- (NSMutableDictionary *)getSelfInfo{
    
    NSMutableDictionary *dictionaryFormat = [NSMutableDictionary dictionary];
    NSArray* propertiesArray = [self getAllProperty];
    for (NSString* key in propertiesArray) {
        id value = [self valueForKey:key];
        if (value) {
            [dictionaryFormat setObject:value forKey:key];
        }
    }
    return dictionaryFormat;
}

- (void)setSelfInfoBy:(NSDictionary *)info {
    
    if (!info) {
        return;
    }
    NSArray* propertiesArray = [self getAllProperty];
    for (NSString* key in propertiesArray) {
        id value = [info valueForKey:key];
        if (value && ![value isKindOfClass:[NSNull class]]) {
//            if ([value isKindOfClass:[NSDictionary class]] && [key isEqualToString:@"permission"]) {
            if ([key isEqualToString:@"permission"]) { //网络的权限
                continue;
            }
            @try {
                if ([key isEqualToString:@"nid"] && [value isKindOfClass:[NSNumber class]]) {
                    [self setValue:[value stringValue] forKey:key];
                }else{
                    [self setValue:value forKey:key];
                }
            } @catch (NSException *exception) {
                @try {
                    [self setValue:[value stringValue] forKey:key];
                } @catch (NSException *exception) {
                    DLog(@"❌错误啦 key:%@  value:%@", key, value);
                }
            }
        }
    }
    
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    DLog(@"❌%@没有定义的key:%@", self, key);
}
-(id)valueForUndefinedKey:(NSString *)key{
    DLog(@"❌%@没有定义的key:%@", self, key);
    return nil;
}

@end











