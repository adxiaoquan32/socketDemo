//
//  imUserInfo.m
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "imUserInfo.h"

@implementation imUserInfo

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
        self.userID = [dict objectForKey:@"userID"];
        self.userName = [dict objectForKey:@"userName"];
        self.state = [[dict objectForKey:@"state"] integerValue];
    }
    return self;
}


- (id)getStructerData
{
    NSMutableDictionary *obDic = [NSMutableDictionary new];
    [obDic setObject:self.userID forKey:@"userID"];
    [obDic setObject:self.userName forKey:@"userName"];
    [obDic setObject:INTEGER_TO_STR(self.state) forKey:@"state"];
    
    return obDic;
}



@end
