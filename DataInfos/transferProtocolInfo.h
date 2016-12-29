//
//  transferProtocolInfo.h
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "SZBMStructBase.h"
#import "imUserInfo.h"
#import "imTextMsgInfo.h"

typedef NS_ENUM(NSInteger, enTransferType)
{
    enTransferType_user,
    enTransferType_userList,
    enTransferType_textmsg,
};



@interface transferProtocolInfo : SZBMStructBase

@property(nonatomic,assign)enTransferType tag;
@property(nonatomic,strong)id data;





@end
