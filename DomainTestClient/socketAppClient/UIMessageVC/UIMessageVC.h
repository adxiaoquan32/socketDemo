//
//  UIMessageVC.h
//  DomainTest
//
//  Created by xiaoquan jiang on 28/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "imSingleUserMsgCollectionInfo.h"

typedef imTextMsgInfo *(^UIMessageVCSBack)(imUserInfo *toUserInfo,NSString* msgText);


@interface UIMessageVC : UIViewController

@property(strong,nonatomic)imSingleUserMsgCollectionInfo* msgColloctionInfo;

- (void)setUIMessageVCSBack:(UIMessageVCSBack)callBacBlock;


@end
