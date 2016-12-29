//
//  SZBMStructBase.h
//  BMBlueMoonAngel
//
//  Created by xiaoquan jiang on 8/16/16.
//  Copyright © 2016 elvin. All rights reserved.
//


// -----------------------------------------------------------------
//            深圳开发团队 对象类 的基类
//
//  1,
//
//
//
// -----------------------------------------------------------------

#define IS_VALID_STRING_OBJ(pStringIsValid)  ( pStringIsValid != nil && [pStringIsValid isKindOfClass:[NSString class]] )

#define IS_CAN_USE_STRING(pStringIsValid)  ( pStringIsValid != nil && [pStringIsValid isKindOfClass:[NSString class]] && [pStringIsValid length] > 0)

#define INTEGER_TO_STR(nint) [NSString stringWithFormat:@"%ld",(long)nint]

#import <Foundation/Foundation.h>


@interface SZBMStructBase : NSObject

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)modelWithDict:(NSDictionary *)dict;


- (id)getStructerData;


@end
