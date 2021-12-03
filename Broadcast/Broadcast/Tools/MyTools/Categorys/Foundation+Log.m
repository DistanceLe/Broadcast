
#import <Foundation/Foundation.h>

@implementation NSDictionary (Log)
- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"{\n"];
    
    // 遍历字典的所有键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSNumber class]]) {
            [str appendFormat:@"\t%@ = %@ (%#lX),\n", key, obj, ([obj unsignedIntegerValue])];
        }else{
            [str appendFormat:@"\t%@ = %@,\n", key, obj];
        }
    }];
    
    [str appendString:@"}"];
    
    // 查出最后一个,的范围
    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
    if (range.length != 0) {
        // 删掉最后一个,
        [str deleteCharactersInRange:range];
    }
    
    return str;
}

-(NSString *)description{
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"{\n"];
    
    // 遍历字典的所有键值对
//    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [str appendFormat:@"\t%@ = %@,\n", key, obj];
//    }];
    NSArray* keysArray = [self allKeys];
    keysArray = [keysArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]]) {
            return [obj1 compare:obj2];
        }else{
            return NSOrderedSame;
        }
    }];
    for (id key in keysArray) {
        if ([[self valueForKey:key] isKindOfClass:[NSNumber class]]) {
            [str appendFormat:@"\t%@ = %@ (%#lX),\n", key, [self valueForKey:key], ([[self valueForKey:key] unsignedIntegerValue])];
        }else{
            [str appendFormat:@"\t%@ = %@,\n", key, [self valueForKey:key]];
        }
    }
    
    [str appendString:@"}"];
    
    // 查出最后一个,的范围
    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
    if (range.length != 0) {
        // 删掉最后一个,
        [str deleteCharactersInRange:range];
    }
    
    return str;
}

@end

@implementation NSArray (Log)
- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"[\n"];
    
    // 遍历数组的所有元素
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [str appendFormat:@"%@ (%#lX),\n", obj, ([obj unsignedIntegerValue])];
        }else{
            [str appendFormat:@"%@,\n", obj];
        }
    }];
    
    [str appendString:@"]"];
    
    // 查出最后一个,的范围
    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
    if (range.length != 0) {
        // 删掉最后一个,
        [str deleteCharactersInRange:range];
    }
    
    return str;
}

-(NSString *)description{
    NSMutableString *str = [NSMutableString string];
    
    [str appendString:@"[\n"];
    
    // 遍历数组的所有元素
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            [str appendFormat:@"%@ (%#lX),\n", obj, ([obj unsignedIntegerValue])];
        }else{
            [str appendFormat:@"%@,\n", obj];
        }
    }];
    
    [str appendString:@"]"];
    
    // 查出最后一个,的范围
    NSRange range = [str rangeOfString:@"," options:NSBackwardsSearch];
    if (range.length != 0) {
        // 删掉最后一个,
        [str deleteCharactersInRange:range];
    }
    
    return str;
}

@end
