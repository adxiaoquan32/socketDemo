//
//  imTextMsgInfo.m
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "imTextMsgInfo.h"

@implementation imTextMsgInfo

+ (instancetype)modelWithDict:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]]) return nil;
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super initWithDict:dict];
    if (self)
    {
        self.body = [dict objectForKey:@"body"];
    }
    return self;
}

- (id)getStructerData
{
    NSMutableDictionary *obDic = [super getStructerData];
    [obDic setObject:self.body forKey:@"body"]; 
    
    return obDic;
}



@end
