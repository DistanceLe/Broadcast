//
//  iPhoneInfo.h
//  Hytronik
//
//  Created by lijie on 2018/5/9.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iPhoneInfo : NSObject



/**  获取所有相关IP信息 */
+ (NSDictionary *)getIPAddresses;

/**  获取ip地址 */
+ (NSString*)getIPAddress:(BOOL)preferIPv4;

/**  输出 所有的信息 */
+ (void)getDeviceInfo;





/**  获取mac 地址..  没什么用 在iOS7上 返回固定值02:00:00:00:00:00*/
+ (NSString *)getMacAddress;


/**  获取Identifier Vendor */
+(NSString*)getIdentifierForVendor;

/**  获取广告标识符 */
+(NSString*)getIdentifierForAdvertising;


/**  获取设备型号然后手动转化为对应名称 */
+ (NSString *)getDeviceName;
+ (BOOL)isSimulator;

/**  获取IP */
+ (NSString *)getDeviceIPAddresses;

/**  获取设备惟一标示符 */
+ (NSString *)getUUID;

/**  获取app版本号 */
+ (NSString *)getVersion;
//获取app build版本号
+ (NSString *)getBuildVersion;


@end











