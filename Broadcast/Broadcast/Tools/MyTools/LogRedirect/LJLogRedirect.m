//
//  LJLogRedirect.m
//  LJTools-Demo
//
//  Created by LiJie on 2017/12/2.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJLogRedirect.h"
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/sysctl.h>

//static BOOL KNeedLog = NO;

@implementation LJLogRedirect

+(void)load{
//    if (AmIBeingDebugged()) {
//        //正在真机调试
//        KNeedLog = YES;
//    }else{
//        //不是在真机调试的时候：
//        NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
//        BOOL isShare = [[bundleDic objectForKey:@"UIFileSharingEnabled"] boolValue];
//        if (isShare) {
//            KNeedLog = YES;
//            [self redirectNSlogToDocumentFolder];
//        }else{
//            KNeedLog = NO;
//        }
//    }
}

/**  将NSlog打印信息保存到Document目录下的文件中 */
+ (void)redirectNSlogToDocumentFolder
{
    //document文件夹
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //
//    NSString *foldPath = [documentDirectory stringByAppendingFormat:@"/appLog"];
//
//    //文件保护等级
//    NSDictionary *attribute = [NSDictionary dictionaryWithObject:NSFileProtectionNone
//                                                          forKey:NSFileProtectionKey];
//    [[NSFileManager defaultManager] createDirectoryAtPath:foldPath withIntermediateDirectories:YES attributes:attribute error:nil];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //每次启动后都保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [documentDirectory stringByAppendingFormat:@"/%@.log",dateStr];
    
    [self checkFlieProtection:logFilePath];
    // 将log输入到文件
    /**  freopen
     freopen()函数用于文件流的的重定向，一般是将 stdin、stdout 和 stderr 重定向到文件。
     FILE freopen(char filename, char type, FILE stream);*/
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}




/**  文件权限
 NSFileProtectionNone                                    //文件未受保护，随时可以访问 （Default）
 NSFileProtectionComplete                                //文件受到保护，而且只有在设备未被锁定时才可访问
 NSFileProtectionCompleteUntilFirstUserAuthentication    //文件收到保护，直到设备启动且用户第一次输入密码
 NSFileProtectionCompleteUnlessOpen                      //文件受到保护，而且只有在设备未被锁定时才可打开，不过即便在设备被锁定时，已经打开的文件还是可以继续使用和写入
*/
+ (void)checkFlieProtection:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathSqlite = path;
    NSDictionary *attributeSql = [fileManager attributesOfItemAtPath:pathSqlite error:nil];
    if ([[attributeSql objectForKey:NSFileProtectionKey] isEqualToString:NSFileProtectionComplete]) {
        NSDictionary *attribute = [NSDictionary dictionaryWithObject:NSFileProtectionCompleteUntilFirstUserAuthentication
                                                              forKey:NSFileProtectionKey];
        [fileManager setAttributes:attribute ofItemAtPath:pathSqlite error:nil];
        NSLog(@"改变文件权限 %@ : %@",path,attribute);
    }
    
}


//static bool AmIBeingDebugged(void)
//    // Returns true if the current process is being debugged (either
//    // running under the debugger or has a debugger attached post facto).
//{
//    int                 junk;
//    int                 mib[4];
//    struct kinfo_proc   info;
//    size_t              size;
//
//    // Initialize the flags so that, if sysctl fails for some bizarre
//    // reason, we get a predictable result.
//
//    info.kp_proc.p_flag = 0;
//
//    // Initialize mib, which tells sysctl the info we want, in this case
//    // we're looking for information about a specific process ID.
//
//    mib[0] = CTL_KERN;
//    mib[1] = KERN_PROC;
//    mib[2] = KERN_PROC_PID;
//    mib[3] = getpid();
//
//    // Call sysctl.
//
//    size = sizeof(info);
//    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
//    assert(junk == 0);
//
//    // We're being debugged if the P_TRACED flag is set.
//
//    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
//}

@end
