//
//  NSString+SZBMExtension.h
//  BMBlueMoonAngel
//
//  Created by Kerwin on 16/8/11.
//  Copyright © 2016年 elvin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (SZBMExtension)


/*
 * 获取字符串的Size
 *
 */
- (CGSize)sizeWithMaxSize:(CGSize )maxSize
                     font:(UIFont *)font;

/**
 将字符串进行MD5 编码

 @return inputStr
 */
- (NSString*)MD5;

/**
 字符串是否包括某字段

 @param pStrSub description
 @return return
 */
- (BOOL)isContainSubString:(NSString*)pStrSub;

/**
 将字符串进行unicode 编码

 @return return
 */
- (NSString *)URLEncodedString;

/**
 *  将字符串进行unicode 解码
 *
 *  @return 
 */


/**
 将字符串进行unicode 解码

 @return return
 */
- (NSString*)URLDecodedString;

- (NSString*)whitespaceAndNewlineCharacterSet;


#pragma mark - 字符串类型判断

/**
 判断字符串是否是整型

 @return return
 */
- (BOOL)isPureInt;


/**
 判断是否为浮点形

 @return retrun
 */
- (BOOL)isPureFloat;


/**
  判断是否为长整型

 @return return
 */
- (BOOL)isPureLong;


#pragma mark - 字符串获取路径

- (NSString *)documentPath;

- (NSString *)cachePath;


#pragma mark - 手机号码、邮箱有效判断


/**
 判断手机号码格式是否正确

 @param mobile 手机号码字符串

 @return 是否有效
 */
+ (BOOL)isValiMobile:(NSString *)mobile;


/**
 有效格式是否有效

 @param email 有效字符串

 @return 是否有效
 */
+ (BOOL)isAvailableEmail:(NSString *)email;
    

#pragma mark - 文件操作
    

/**
 计算文件或者文件夹的大小

 @return
 */


/**
  计算文件或者文件夹的大小

 @return 大小
 */
- (long long)fileSize;


@end
