//
//  transferProtocolInfo.m
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "transferProtocolInfo.h"

@implementation transferProtocolInfo

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
        self.tag = [[dict objectForKey:@"tag"] integerValue];
        
        switch ( self.tag )
        {
            case enTransferType_user:
            {
                self.data = [imUserInfo modelWithDict:[dict objectForKey:@"data"]];
            }
                break;
            case enTransferType_userList:
            {
                NSArray *array = (NSArray *)[dict objectForKey:@"data"];
                NSMutableArray *multiData = [NSMutableArray new];
                [array enumerateObjectsUsingBlock:^(NSDictionary* userdic, NSUInteger idx, BOOL * _Nonnull stop) {
                    [multiData addObject:[imUserInfo modelWithDict:userdic]];
                }];
                self.data = multiData;
            }
                break;
            case enTransferType_textmsg:
            {
                self.data = [imTextMsgInfo modelWithDict:[dict objectForKey:@"data"]];
            }
                break;
                
            default:
                break;
        }
        
    }
    return self;
}


- (id)getStructerData
{
    NSMutableDictionary *obDic = [NSMutableDictionary new];
    [obDic setObject:INTEGER_TO_STR(self.tag) forKey:@"tag"];
    
    SZBMStructBase *baseInfo = (SZBMStructBase*)self.data;
    
    if ( self.tag == enTransferType_userList )
    {
        NSArray *array = (NSArray *)baseInfo;
        NSMutableArray *multiData = [NSMutableArray new];
        [array enumerateObjectsUsingBlock:^(imUserInfo *userInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            [multiData addObject:[userInfo getStructerData]];
        }];
        
        [obDic setObject:multiData forKey:@"data"];
    }
    else
    {
        [obDic setObject:[baseInfo getStructerData] forKey:@"data"];
    }
    
    return obDic;
}



@end
