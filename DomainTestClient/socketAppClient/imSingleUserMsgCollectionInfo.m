//
//  imSingleUserMsgCollectionInfo.m
//  DomainTest
//
//  Created by xiaoquan jiang on 28/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "imSingleUserMsgCollectionInfo.h"

@interface imSingleUserMsgCollectionInfo()

@property (strong, nonatomic)NSMutableArray *msgArr;


@end



@implementation imSingleUserMsgCollectionInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _msgArr = [[NSMutableArray alloc] init];
        _unReadNum = 0;
        
    }
    return self;
}

- (void)addMsgObj:(imTextMsgInfo*)textMsg
{
    [_msgArr addObject:textMsg];
}


- (NSArray*)msgArr
{
    return _msgArr;
}

@end
