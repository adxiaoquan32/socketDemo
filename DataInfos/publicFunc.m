//
//  publicFunc.m
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "publicFunc.h"
#include "TargetConditionals.h"

#if TARGET_OS_IPHONE
    #import "UIDevice+SZBMExtension.h"
#endif

@implementation publicFunc

+ (NSString *)getSystemUUID
{
    
#if !TARGET_OS_IPHONE
    
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,IOServiceMatching("IOPlatformExpertDevice"));
    if (!platformExpert)
        return nil;
    
    CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,CFSTR(kIOPlatformUUIDKey),kCFAllocatorDefault, 0);
    IOObjectRelease(platformExpert);
    if (!serialNumberAsCFString)
        return nil;
    
    return (__bridge NSString *)(serialNumberAsCFString);

#else
    
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
    
#endif
    
}


+ (NSData*)objetToJson:(id)data
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    return jsonData;
}


@end
