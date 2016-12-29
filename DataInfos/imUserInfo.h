//
//  imUserInfo.h
//  DomainTest
//
//  Created by xiaoquan jiang on 27/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SZBMStructBase.h"
#import "GCDAsyncSocket.h"


typedef NS_ENUM(NSInteger, enImState) {
    imState_offline,
    imState_online
};


@interface imUserInfo : SZBMStructBase

@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,assign)enImState state;

@property(nonatomic,strong)GCDAsyncSocket *socket;

@end
