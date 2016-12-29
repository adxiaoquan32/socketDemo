//
//  imMsgBaseInfo.h
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "SZBMStructBase.h"
#import "imUserInfo.h"

typedef NS_ENUM(NSInteger, enMsgState)
{
    msgState_unsent,    //未发送
    msgState_sent,      //发送成功
    msgState_sentRcvd,  // 发送且对方已收到
    msgState_sentRead,  // 发送且对方已读
    
    
    msgState_rcvd,             // 已收到
    msgState_rcvdRead,         // 已收到且已读
    msgState_rcvdReadConfirm,  // 已读且对方确认我已读
    
};

@interface imMsgBaseInfo : SZBMStructBase

@property(nonatomic,strong)imUserInfo *sender;
@property(nonatomic,strong)imUserInfo *receiver;
@property(nonatomic,assign)NSTimeInterval msgTime;
@property(nonatomic,assign)enMsgState msgState;

@end
