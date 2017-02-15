//
//  publicFunc.h
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import <Foundation/Foundation.h>


#define msg_newmsg_notice_key @"msg_newmsg_notice_key"


@interface publicFunc : NSObject

+ (NSString *)getSystemUUID;
+ (NSData* )objetToJson:(id)data;
+ (NSData*)transforObToData:(id)pro;

@end
