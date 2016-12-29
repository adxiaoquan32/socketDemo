//
//  imSingleUserMsgCollectionInfo.h
//  DomainTest
//
//  Created by xiaoquan jiang on 28/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "SZBMStructBase.h"
#import "imTextMsgInfo.h"

@interface imSingleUserMsgCollectionInfo : SZBMStructBase

@property (assign, nonatomic)NSInteger unReadNum;
@property (strong, nonatomic)imUserInfo *userInfo;

//
- (void)addMsgObj:(imTextMsgInfo*)textMsg;
- (NSArray*)msgArr;

@end
