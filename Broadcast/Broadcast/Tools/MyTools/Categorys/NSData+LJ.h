//
//  NSData+LJ.h
//  Hytronik
//
//  Created by lijie on 2018/5/7.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LJ)


/**  加密 */
- (NSData *)AES256EncryptWithKey:(NSString *)key;

/**  解密 */
- (NSData *)AES256DecryptWithKey:(NSString *)key;



/**  编码 */
- (NSData*)encodeAES256;
/**  解码 */
- (NSData*)decodeAES256;


/**  解密 字符串 */
//- (NSString*)decodeStringAES256WithString:(NSString*)secretString;


@end
