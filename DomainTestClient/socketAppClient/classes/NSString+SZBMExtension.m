//
//  NSString+SZBMExtension.m
//  BMBlueMoonAngel
//
//  Created by Kerwin on 16/8/11.
//  Copyright © 2016年 elvin. All rights reserved.
//

#import "NSString+SZBMExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SZBMExtension)


//获取字符串的Size
- (CGSize)sizeWithMaxSize:(CGSize )maxSize
                     font:(UIFont *)font
{
    if (!font)  return CGSizeZero;
    CGRect frame = [self boundingRectWithSize:maxSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin)
                                   attributes:@{NSFontAttributeName :font}
                                      context:nil];
    CGSize rsize = frame.size; rsize.height = ceil(rsize.height);
    rsize.width = ceil(rsize.width);
    
    return rsize;
}


//MD5加密
- (NSString*)MD5
{
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 bytes MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}


- (BOOL)isContainSubString:(NSString*)pStrSub
{
    if ( !self || !pStrSub )
    {
        return FALSE;
    }
    NSRange range = [self rangeOfString:pStrSub];
    if ( range.location == NSNotFound )
        return FALSE;
    return TRUE;
}

- (NSString *)URLEncodedString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (CFStringRef)self,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8));
    
    return result;
}

- (NSString*)URLDecodedString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (CFStringRef)self,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8));
    
    return result;
}

- (NSString*)whitespaceAndNewlineCharacterSet
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//判断字符串是否是整型
- (BOOL)isPureInt
{
    if (0 == [self length])
    {
        return NO;
    }
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
    
}

//判断是否为浮点形：
- (BOOL)isPureFloat
{
    if (0 == [self length])
    {
        return NO;
    }
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
    
}


//判断是否为长整型
- (BOOL)isPureLong
{
    if (0 == [self length])
    {
        return NO;
    }
    NSScanner* scan = [NSScanner scannerWithString:self];
    long long val;
    return [scan scanLongLong:&val] && [scan isAtEnd];
    
}

#pragma mark - 字符串获取路径

- (NSString *)documentPath
{
   NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) firstObject];
    
    return [basePath stringByAppendingPathComponent:self];;
}

- (NSString *)cachePath
{
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask, YES) firstObject];

    return [basePath stringByAppendingPathComponent:self];
    
}

#pragma mark - 手机号码、邮箱有效判断

//判断手机号码格式是否正确
+ (BOOL)isValiMobile:(NSString *)mobile
{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3)
        {
            return YES;
        }else
        {
            return NO;
        }
    }
}

//有效格式是否有效
+ (BOOL)isAvailableEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
 
    
#pragma mark - 文件操作
    
/**
 计算文件或者文件夹的大小
 
 @return
 */
- (long long)fileSize
{
    // 1.文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 2.判断file是否存在
    BOOL isDirectory = NO;
    BOOL fileExists = [mgr fileExistsAtPath:self isDirectory:&isDirectory];
    // 文件\文件夹不存在
    if (fileExists == NO) return 0;
    
    // 3.判断file是否为文件夹
    if (isDirectory) { // 是文件夹
        NSArray *subpaths = [mgr contentsOfDirectoryAtPath:self error:nil];
        long long totalSize = 0;
        for (NSString *subpath in subpaths) {
            NSString *fullSubpath = [self stringByAppendingPathComponent:subpath];
            totalSize += [fullSubpath fileSize];
        }
        return totalSize;
    } else { // 不是文件夹, 文件
        // 直接计算当前文件的尺寸
        NSDictionary *attr = [mgr attributesOfItemAtPath:self error:nil];
        return [attr[NSFileSize] longLongValue];
    }
}

@end
