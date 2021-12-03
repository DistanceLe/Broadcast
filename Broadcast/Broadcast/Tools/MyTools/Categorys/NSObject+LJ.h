//
//  NSObject+LJ.h
//  Hytronik
//
//  Created by lijie on 2018/4/24.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (LJ)

/**  获取所有的属性 */
- (NSArray*)getAllProperty;

/**  获取所有的属性值 */
- (NSMutableDictionary *)getSelfInfo;

/**  设置所有的属性值 */
- (void)setSelfInfoBy:(NSDictionary *)info;



@end
