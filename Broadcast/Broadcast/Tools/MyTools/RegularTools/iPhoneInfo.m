//
//  iPhoneInfo.m
//  Hytronik
//
//  Created by lijie on 2018/5/9.
//  Copyright © 2018年 lijie. All rights reserved.
//

#import "iPhoneInfo.h"
#import "sys/utsname.h"
#import <AdSupport/AdSupport.h>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>



#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


@implementation iPhoneInfo


+ (NSString *) macaddress
{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    //DLog(@"outString:%@", outstring);
    
    free(buf);
    
    return [outstring uppercaseString];
}

//获取ip地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ /*IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6,*/ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ /*IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4,*/ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    //DLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

//获取所有相关IP信息
+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
+ (NSString *)getMacAddress {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1/n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!/n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return [outstring uppercaseString];
}

/**  获取Identifier Vendor */
+(NSString*)getIdentifierForVendor{
    NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
    return identifierForVendor;
}

/**  获取广告标识符 */
+(NSString*)getIdentifierForAdvertising{
    /**  广告标示符是由系统存储着的。不过即使这是由系统存储的，但是有几种情况下，会重新生成广告标示符。如果用户完全重置系统（(设置程序 ->通用 -> 还原 ->还原位置与隐私)，这个广告标示符会重新生成。
     另外如果用户明确的还原广告(设置程序->通用 -> 关于本机 ->广告 ->还原广告标示符)，那么广告标示符也会重新生成。
     关于广告标示符的还原，有一点需要注意：如果程序在后台运行，此时用户“还原广告标示符”，然后再回到程序中，此时获取广告标示符并不会立即获得还原后的标示符。必须要终止程序，然后再重新启动程序，才能获得还原后的广告标示符。之所以会这样，因为ASIdentifierManager是一个单例 */
    
//    NSString *identifierForAdvertising = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *identifierForAdvertising = [self getIPAddress:YES];
    return identifierForAdvertising;
}


+ (void)getDeviceInfo
{
    NSString *deviceName = [self getDeviceName];
    DLog(@"设备型号-->%@", deviceName);
    
    NSString *iPhoneName = [UIDevice currentDevice].name;
    DLog(@"iPhone名称-->%@", iPhoneName);
    
    NSString *appVerion = [self getVersion];
    DLog(@"app版本号-->%@", appVerion);
    
    NSDictionary *appSign = [[NSBundle mainBundle] infoDictionary];
    DLog(@"app签名信息-->%@",appSign);
    
    CGFloat batteryLevel = [[UIDevice currentDevice] batteryLevel];
    DLog(@"电池电量-->%f", batteryLevel);
    
    NSString *localizedModel = [UIDevice currentDevice].localizedModel;
    DLog(@"localizedModel-->%@", localizedModel);
    
    NSString *systemName = [UIDevice currentDevice].systemName;
    DLog(@"当前系统名称-->%@", systemName);
    
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    DLog(@"当前系统版本号-->%@", systemVersion);
    
    NSString *uuid = [self getUUID];
    DLog(@"唯一识别码uuid-->%@", uuid);
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *device_model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    DLog(@"device_model-->%@", device_model);
    
    NSString *macAddress = [self getMacAddress];
    DLog(@"macAddress-->%@", macAddress);
    
    NSString *deviceIP = [self getDeviceIPAddresses];
    DLog(@"deviceIP-->%@", deviceIP);
    
    
    
    DLog(@"ipaddresses:%@\n ipv4:%@\n", [self getIPAddresses], [self getIPAddress:YES]);
    
    DLog(@"vendor:%@,   AD:%@", [self getIdentifierForVendor], [self getIdentifierForAdvertising]);
    
}


+ (NSString *)getOSInfo
{
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    return versionStr;
}

// 获取设备型号然后手动转化为对应名称
+ (NSString *)getDeviceName
{
//    [iPhoneInfo getDeviceInfo];
//    NSDictionary* dic = [[NSBundle mainBundle] infoDictionary];
//    DLog(@"%@", dic);
    
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    //新增
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus (A1897)";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceString isEqualToString:@"iPhone12,8"])   return @"iPhone SE (2nd)";
    if ([deviceString isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceString isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceString isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceString isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    
    
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod Touch 6";
    if ([deviceString isEqualToString:@"iPod9,1"])      return @"iPod Touch 7";
    
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    
    
    //新增===
    if ([deviceString isEqualToString:@"iPad6,11"])     return @"iPad 2017(5th)";
    if ([deviceString isEqualToString:@"iPad6,12"])     return @"iPad 2017(5th)";
    
    
    if ([deviceString isEqualToString:@"iPad7,1"])      return @"iPad Pro (12.9-inch) (2nd)";
    if ([deviceString isEqualToString:@"iPad7,2"])      return @"iPad Pro (12.9-inch) (2nd)";
    if ([deviceString isEqualToString:@"iPad7,3"])      return @"iPad Pro (10.5 inch)";
    if ([deviceString isEqualToString:@"iPad7,4"])      return @"iPad Pro (10.5-inch)";
    
    if ([deviceString isEqualToString:@"iPad7,5"])      return @"iPad 2018(6th)";
    if ([deviceString isEqualToString:@"iPad7,6"])      return @"iPad 2018(6th)";
    
    if ([deviceString isEqualToString:@"iPad7,11"])     return @"iPad 2019(7th WiFi) 10.2寸";
    if ([deviceString isEqualToString:@"iPad7,12"])     return @"iPad 2019(7th)";
    
    
    if ([deviceString isEqualToString:@"iPad8,1"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,2"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,3"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,4"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,5"])      return @"iPad Pro (12.9-inch) (3rd)";
    if ([deviceString isEqualToString:@"iPad8,6"])      return @"iPad Pro (12.9-inch) (3rd)";
    if ([deviceString isEqualToString:@"iPad8,7"])      return @"iPad Pro (12.9-inch) (3rd)";
    if ([deviceString isEqualToString:@"iPad8,8"])      return @"iPad Pro (12.9-inch) (3rd)";
    if ([deviceString isEqualToString:@"iPad8,9"])      return @"iPad Pro (11-inch) (2nd)";
    if ([deviceString isEqualToString:@"iPad8,10"])     return @"iPad Pro (11-inch) (2nd)";
    if ([deviceString isEqualToString:@"iPad8,11"])     return @"iPad Pro (12.9-inch) (4th)";
    if ([deviceString isEqualToString:@"iPad8,12"])     return @"iPad Pro (12.9-inch) (4th)";
    
    
    if ([deviceString isEqualToString:@"iPad11,3"])     return @"iPad Air (3rd)";
    if ([deviceString isEqualToString:@"iPad11,4"])     return @"iPad Air (3rd)";
    
    if ([deviceString isEqualToString:@"iPad11,6"])     return @"iPad 2020(8th)";
    if ([deviceString isEqualToString:@"iPad11,7"])     return @"iPad 2020(8th)";
    
    if ([deviceString isEqualToString:@"iPad13,1"])     return @"iPad Air (4th)";
    if ([deviceString isEqualToString:@"iPad13,2"])     return @"iPad Air (4th)";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}
+ (BOOL)isSimulator{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"i386"] || [deviceString isEqualToString:@"x86_64"]) {
        return YES;
    }
    return NO;
}


+ (NSString *)getDeviceIPAddresses {
    
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE = 4096;
    
    struct ifconf ifc;
    
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags & IFF_UP) == 0) continue;
            
            NSString *ip = [NSString  stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    
    close(sockfd);
    NSString *deviceIP = @"";
    
    for (int i=0; i < ips.count; i++) {
        if (ips.count > 0) {
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    return deviceIP;
}


//获取设备惟一标示符
+ (NSString *)getUUID
{
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return uuid;
}
//获取app版本号
+ (NSString *)getVersion
{
    NSString *appVerion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return appVerion;
}


//获取app build版本号
+ (NSString *)getBuildVersion
{
    NSString *appVerion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    return appVerion;
}


@end















