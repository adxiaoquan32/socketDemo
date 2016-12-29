//
//  UIDevice+SZBMExtension.h
//  trainingsystem
//
//  Created by xiaoquan jiang on 8/30/16.
//  Copyright © 2016 xiaoquan jiang. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIDevice (SZBMExtension)


#pragma mark - 设备信息相关

/**
 设备 唯一识别ID

 @return return
 */
- (NSString *) uniqueDeviceIdentifier;


/*
 获取设备类型
 */
+ (NSString*) getDeviceString;


/*
 * 获取设备型号 iPhone 3GS iPhone 4S ....
 */
+ (NSString*)doDevicePlatform;



@end
