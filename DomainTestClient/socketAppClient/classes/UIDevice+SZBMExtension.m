//
//  UIDevice+SZBMExtension.m
//  trainingsystem
//
//  Created by xiaoquan jiang on 8/30/16.
//  Copyright © 2016 xiaoquan jiang. All rights reserved.
//

#import "UIDevice+SZBMExtension.h"

#import "NSString+SZBMExtension.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "sys/utsname.h"
#import <UIKit/UIKit.h>



@implementation UIDevice (SZBMExtension)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.


#pragma mark - 设备信息相关

- (NSString *) macaddress
{
    NSString *outstring = @"";
    if ( [[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)] )
    {
        outstring = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    else
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
            printf("Error: if_nametoindex error\n");
            return NULL;
        }
        
        if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 1\n");
            return NULL;
        }
        
        if ((buf = (char *)malloc(len)) == NULL) {
            printf("Could not allocate memory. error!\n");
            return NULL;
        }
        
        if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
            printf("Error: sysctl, take 2");
            free(buf);
            return NULL;
        }
        
        ifm = (struct if_msghdr *)buf;
        sdl = (struct sockaddr_dl *)(ifm + 1);
        ptr = (unsigned char *)LLADDR(sdl);
        outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                     *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        free(buf);
    }
    
    return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (NSString *) uniqueDeviceIdentifier
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        NSString *uniqueIden = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        return uniqueIden;
    }
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash MD5];
    return uniqueIdentifier;
}

+ (NSString *) uniqueDeviceIdentifierForStatic// static function
{
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}


- (NSString *) uniqueGlobalDeviceIdentifier
{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueIdentifier = [macaddress MD5];
    
    return uniqueIdentifier;
}



+ (NSString *) uniqueGlobalDeviceIdentifierForStatic
{
    return [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
}

+ (NSString*) getDeviceModelStr
{
    size_t size;
    
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    char *machine = (char*)malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    
    return platform;
}

+ (NSString*) getDeviceString
{
    int nType = [UIDevice getDeviceType];
    switch (nType)
    {
        case 1:
            return @"iphone";
            break;
        case 2:
            return @"ipod";
            break;
        case 3:
            return @"ipad";
            break;
            
        default:
            return @"iphone";
            break;
    }
}




/*
 Get Devicet type
 
 1: iphone
 2: ipod
 3: ipad
 */
+ (int) getDeviceType
{
    UIDevice *pDevice = [UIDevice currentDevice];
    if([pDevice.model compare:@"iPhone"] == NSOrderedSame )//|| [pDevice.model compare:@"iPhone Simulator"] == NSOrderedSame
    {
        return 1;
    }
    else if(  [pDevice.model compare:@"iPod touch"] == NSOrderedSame || [pDevice.model compare:@"iPod Touch Simulator"] == NSOrderedSame || [pDevice.model compare:@"iPhone Simulator"] == NSOrderedSame )
    {
        return 2;
    }
    else if ([pDevice.model compare:@"iPad Simulator"] == NSOrderedSame || [pDevice.model compare:@"iPad"] == NSOrderedSame)
    {
        return 3;
    }
    else
    {
        return 1;
    }
}


//设备型号
+ (NSString*)doDevicePlatform
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) {
        
        platform = @"iPhone";
        
    } else if ([platform isEqualToString:@"iPhone1,2"]) {
        
        platform = @"iPhone 3G";
        
    } else if ([platform isEqualToString:@"iPhone2,1"]) {
        
        platform = @"iPhone 3GS";
        
    } else if ([platform isEqualToString:@"iPhone3,1"]||[platform isEqualToString:@"iPhone3,2"]||[platform isEqualToString:@"iPhone3,3"]) {
        
        platform = @"iPhone 4";
        
    } else if ([platform isEqualToString:@"iPhone4,1"]) {
        
        platform = @"iPhone 4S";
        
    } else if ([platform isEqualToString:@"iPhone5,1"]||[platform isEqualToString:@"iPhone5,2"]) {
        
        platform = @"iPhone 5";
        
    }else if ([platform isEqualToString:@"iPhone5,3"]||[platform isEqualToString:@"iPhone5,4"]) {
        
        platform = @"iPhone 5C";
        
    }else if ([platform isEqualToString:@"iPhone6,2"]||[platform isEqualToString:@"iPhone6,1"]) {
        
        platform = @"iPhone 5S";
        
    }else if ([platform isEqualToString:@"iPhone7,2"]) {
        
        platform = @"iPhone 6";
        
    }else if ([platform isEqualToString:@"iPhone7,1"]) {
        
        platform = @"iPhone 6plus";
        
    }else if ([platform isEqualToString:@"iPod4,1"]) {
        
        platform = @"iPod touch 4";
        
    }else if ([platform isEqualToString:@"iPod5,1"]) {
        
        platform = @"iPod touch 5";
        
    }else if ([platform isEqualToString:@"iPod3,1"]) {
        
        platform = @"iPod touch 3";
        
    }else if ([platform isEqualToString:@"iPod2,1"]) {
        
        platform = @"iPod touch 2";
        
    }else if ([platform isEqualToString:@"iPod1,1"]) {
        
        platform = @"iPod touch";
        
    } else if ([platform isEqualToString:@"iPad3,2"]||[platform isEqualToString:@"iPad3,1"]) {
        
        platform = @"iPad 3";
        
    } else if ([platform isEqualToString:@"iPad2,2"]||[platform isEqualToString:@"iPad2,1"]||[platform isEqualToString:@"iPad2,3"]||[platform isEqualToString:@"iPad2,4"]) {
        
        platform = @"iPad 2";
        
    }else if ([platform isEqualToString:@"iPad1,1"]) {
        
        platform = @"iPad 1";
        
    }else if ([platform isEqualToString:@"iPad2,5"]||[platform isEqualToString:@"iPad2,6"]||[platform isEqualToString:@"iPad2,7"] ||[platform isEqualToString:@"iPad4,4"] ||[platform isEqualToString:@"iPad4,5"]) {
        
        platform = @"ipad mini";
        
    }else if ([platform isEqualToString:@"iPad4,7"]||[platform isEqualToString:@"iPad4,8"]||[platform isEqualToString:@"iPad4,9"]) {
        
        platform = @"ipad mini3";
        
    } else if ([platform isEqualToString:@"iPad3,3"]||[platform isEqualToString:@"iPad3,4"]||[platform isEqualToString:@"iPad3,5"]||[platform isEqualToString:@"iPad3,6"]) {
        
        platform = @"ipad 3";
        
    } else if ([platform isEqualToString:@"iPad4,1"]||[platform isEqualToString:@"iPad4,2"]) {
        
        platform = @"ipad Air";
        
    }else if ([platform isEqualToString:@"iPad5,3"]||[platform isEqualToString:@"iPad5,4"]) {
        
        platform = @"ipad Air2";
        
    }else
    {
        platform = @"iPhone 7";
    }
    
    return platform;
}

@end
