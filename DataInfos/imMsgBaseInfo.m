//
//  imMsgBaseInfo.m
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "imMsgBaseInfo.h"

@implementation imMsgBaseInfo

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        
        self.sender = [imUserInfo modelWithDict:[dict objectForKey:@"sender"]];
        self.receiver = [imUserInfo modelWithDict:[dict objectForKey:@"receiver"]];
        self.msgTime = [[dict objectForKey:@"msgTime"] longLongValue];
        self.msgState = [[dict objectForKey:@"msgState"] integerValue];
         
    }
    return self;
}


- (id)getStructerData
{
    NSMutableDictionary *obDic = [NSMutableDictionary new];
    
    {
        id datas = [self.sender getStructerData];
        if ( datas) {
            [obDic setObject:datas forKey:@"sender"];
        }
    }
    
    {
        id datas = [self.receiver getStructerData];
        if ( datas) {
            [obDic setObject:datas forKey:@"receiver"];
        }
    }
    
    [obDic setObject:INTEGER_TO_STR(self.msgTime) forKey:@"msgTime"];
    [obDic setObject:INTEGER_TO_STR(self.msgState) forKey:@"msgState"];
    
    return obDic;
}


@end
