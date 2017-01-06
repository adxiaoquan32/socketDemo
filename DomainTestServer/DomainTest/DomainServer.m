//
//  DomainServer.m
//  DomainTest
//
//  Created by Jonathan Diehl on 06.10.12.
//  Copyright (c) 2012 Jonathan Diehl. All rights reserved.
//

#import "DomainServer.h"
#import "imUserInfo.h"
#import "transferProtocolInfo.h"
#import "publicFunc.h"

#include "IPAddress.h"

#import <CoreWLAN/CoreWLAN.h>

@interface DomainServer()

@property (strong,nonatomic) imUserInfo *serverUser;

@end


@implementation DomainServer

@synthesize socket = _socket;
@synthesize url = _url;
@synthesize outputView = _outputView;
@synthesize inputView = _inputView;





- (void)_getIp
{
    
    CWInterface *wif = [CWInterface interface];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Using Wifi is: %@\n",wif.ssid] attributes:@{ NSForegroundColorAttributeName :[NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1] }];
    [self _addString:string];
    
    //NSLog(@"BSD if name: %@", wif.hardwareAddress);
   // NSLog(@"SSID: %@", wif.ssid);
    
    
    InitAddresses();
    GetIPAddresses();
   // GetHWAddresses();
    
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;        // 127.0.0.1
        unsigned long theAddr;
        
        theAddr = ip_addrs[i];
        
        if (theAddr == 0) break;
        if (theAddr == localHost) continue;
        
        //NSLog(@"Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
        
        //decided what adapter you want details for
        if (strncmp(if_names[i], "en", 2) == 0)
        {
            //NSLog(@"Adapter en has a IP of %s", ip_names[i]);
            
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Server IP is: %s:59558\n\n",ip_names[i]] attributes:@{ NSForegroundColorAttributeName :[NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1] }];
            [self _addString:string];
        }
    }
    
}


- (BOOL)start:(NSError **)error;
{
    
    // get ip address
    [self _getIp];
    
    
    self.userTextView.editable = NO;
    self.outputView.editable = NO;
    
	_connectedSockets = [NSMutableSet new];
    _totalconnectedSockets = [NSMutableSet new];
    
    _serverUser = [[imUserInfo alloc] init];
    _serverUser.userID = @"xxxxxxx-server-xxxxxx";
    _serverUser.userName = @"Server";
    _serverUser.state = imState_online;
    
    
	_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
	BOOL result = [self.socket acceptOnUrl:self.url error:error];
	if (result) {
		NSLog(@"[Server] Started at: %@", self.url.path);
	}
    else
    {
        NSError *err = nil;
        if ( [self.socket acceptOnPort:59558 error:&err] )
        {
            UInt16 port = [self.socket localPort];
            NSString *stringHost = [self.socket localHost];
            
            NSLog(@"___:http://%@:%hu   %@",stringHost,port,[[NSString alloc] initWithData:[self.socket localAddress] encoding:NSUTF8StringEncoding]);
        }
    }
	return result;
}

- (void)stop;
{
	_socket = nil;
	NSLog(@"[Server] Stopped.");
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;
{
	NSLog(@"[Server] New connection.");
	[newSocket readDataWithTimeout:-1 tag:0];
    
    // add in total list
    [self.connectedSockets addObject:newSocket];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error;
{
	[self.connectedSockets removeObject:socket];
	NSLog(@"[Server] Closed connection: %@", error);
    
    // add in total list
    [self _connectedSocket:socket addOrLost:NO];
}

- (IBAction)send:(id)sender;
{

    imTextMsgInfo *textMsg = [imTextMsgInfo new];
    textMsg.sender = self.serverUser;
    textMsg.receiver = nil;
    textMsg.body = self.inputView.stringValue;
    textMsg.msgTime = [[NSDate date] timeIntervalSince1970];
    
    
    transferProtocolInfo *pro = [transferProtocolInfo new];
    pro.tag = enTransferType_textmsg;
    pro.data = textMsg;
    
    [self.connectedSockets enumerateObjectsUsingBlock:^(GCDAsyncSocket * sock, BOOL * _Nonnull stop) {
        [sock writeData:[publicFunc objetToJson:[pro getStructerData]] withTimeout:-1 tag:0];
    }];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  Me: %@\n",self.inputView.stringValue] attributes:@{ NSForegroundColorAttributeName :[NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1] }];
    [self _addString:string];
    
   
    self.inputView.stringValue = @"";
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSLog(@"[Server] Received: %lu :%@", (unsigned long)[data length],[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
  
    // parser data
    NSError *error = nil;
    id tranferDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSLog(@"__incoming:\n\n%@\n\n",tranferDic);
    
    if ( tranferDic ) {
        transferProtocolInfo *transfer = [transferProtocolInfo modelWithDict:tranferDic];
        [self _parserData:transfer socket:sock data:data];
    }
    
    [sock readDataWithTimeout:-1 tag:0];
}


/**
 解析数据

 @param transfer transfer description
 */
- (void)_parserData:(transferProtocolInfo *)transfer socket:(GCDAsyncSocket *)sock data:(NSData *)data
{
    
    if ( !transfer) {
        return;
    }
    
    switch ( transfer.tag )
    {
        case enTransferType_user:
        {
            [self _updateUserList:(imUserInfo *)transfer.data socket:sock data:data];
        }
            break;
        case enTransferType_textmsg:
        {
            [self _dueWithMsgReveicing:(imTextMsgInfo *)transfer.data data:data];
        }
            break;
            
        default:
            break;
    }
}


/**
 处理消息转发

 @param msgOb msgOb description
 */
- (void)_dueWithMsgReveicing:(imTextMsgInfo*)msgOb data:(NSData *)data
{
    __block imUserInfo *receiver = msgOb.receiver;
    
    NSString *displayStr = @"";
    
    // default to all
    if ( [receiver.userID isEqualToString:self.serverUser.userID] )
    {
        [_totalconnectedSockets enumerateObjectsUsingBlock:^(imUserInfo *userInfo, BOOL * _Nonnull stop) {
            if ( ![userInfo.userID isEqualToString:msgOb.sender.userID] ) {
                [userInfo.socket writeData:data withTimeout:-1 tag:0];
            }
        }];
        
        displayStr = [NSString stringWithFormat:@"%@ To All:%@\n",msgOb.sender.userName,msgOb.body];
    }
    else
    {
        __block imUserInfo *transferUserInfo = nil;
        [_totalconnectedSockets enumerateObjectsUsingBlock:^(imUserInfo *userInfo, BOOL * _Nonnull stop) {
                if ( [receiver.userID isEqualToString:userInfo.userID])
                {
                    transferUserInfo = userInfo;
                    *stop = YES;
                }
        }];
        
        if ( transferUserInfo )
        {
            [transferUserInfo.socket writeData:data withTimeout:-1 tag:0];
            displayStr = [NSString stringWithFormat:@"%@ To %@:%@\n",msgOb.sender.userName,msgOb.receiver.userName,msgOb.body];
        }
    }
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:displayStr];
    [self _addString:string];
    
}


/**
 显示东西到左边显示板

 @param addStr addStr description
 */
- (void)_addString:(NSAttributedString*)addStr
{
    NSTextStorage *storage = self.outputView.textStorage;
    [storage beginEditing];
    [storage appendAttributedString:addStr];
    //[storage invalidateAttributesInRange: NSMakeRange(storage.length - addStr.length, addStr.length)];
    [storage endEditing];
    
}


/**
 更新用户表

 @param user user description
 @param sock sock description
 */
-(void)_updateUserList:(imUserInfo *)user socket:(GCDAsyncSocket *)sock data:(NSData *)data
{
    __block BOOL bIsExist = NO;

    __block NSMutableArray *alluserExitself = [NSMutableArray new];
    [_totalconnectedSockets enumerateObjectsUsingBlock:^(imUserInfo *userInfo, BOOL * _Nonnull stop) {
        
        if ( userInfo.socket == sock ||
            [user.userID isEqualToString:userInfo.userID])
        {
            userInfo.userID = user.userID;
            userInfo.userName = user.userName;
            userInfo.state = imState_online;
            userInfo.socket = sock;
            bIsExist = YES;
        }
        else
        {
            [alluserExitself addObject:userInfo];
           [userInfo.socket writeData:data withTimeout:-1 tag:0];
        }
        
    }];
    
    // not exist
    if ( !bIsExist )
    {
        user.socket = sock;
        [_totalconnectedSockets addObject:user];
        
    }
     
    // notice the new connted user for all userlist
    
    {
        transferProtocolInfo *pro = [transferProtocolInfo new];
        pro.tag = enTransferType_userList;
        pro.data = alluserExitself;
        NSData *wdata = [publicFunc objetToJson:[pro getStructerData]];
        NSLog(@"___write:\n%@\n",[[NSString alloc] initWithData:wdata encoding:NSUTF8StringEncoding]);
        [sock writeData:wdata withTimeout:-1 tag:0];
    }
    
    [self _layoutUserListUI];
    
}

/**
 有新的连接

 @param newSocket newSocket description
 @param added     added description
 */
- (void)_connectedSocket:(GCDAsyncSocket *)newSocket addOrLost:(BOOL)added
{
    
    __block BOOL bIsExist = NO;
    __block imUserInfo* lostconntectUser = nil;
    [_totalconnectedSockets enumerateObjectsUsingBlock:^(imUserInfo *userInfo, BOOL * _Nonnull stop) {
        
        if ( userInfo.socket == newSocket ) {
            bIsExist = YES;
            userInfo.state = added?imState_online:imState_offline;
            lostconntectUser = userInfo;
            *stop = YES;
        }
    }];
    
    // notice to other user to update state
    for ( imUserInfo *userInfo in _totalconnectedSockets) {
        
        if ( userInfo != lostconntectUser && lostconntectUser ) {
            
            // notice the rest the state
            transferProtocolInfo *pro = [transferProtocolInfo new];
            pro.tag = enTransferType_user;
            pro.data = lostconntectUser;
            [userInfo.socket writeData:[publicFunc objetToJson:[pro getStructerData]] withTimeout:-1 tag:0];
        }
    }
  
    if ( added )
    {
        // not exist
        imUserInfo *connectedUserInfo = nil;
        if ( !bIsExist) {
            connectedUserInfo = [imUserInfo new];
        }
        connectedUserInfo.socket = newSocket;
        connectedUserInfo.state = added?imState_online:imState_offline;
        
        [_totalconnectedSockets addObject:connectedUserInfo];
    }
    

    
    [self _layoutUserListUI];
}


/**
 刷新用户列表UI
 */
- (void)_layoutUserListUI
{
    
    NSTextStorage *storage = self.userTextView.textStorage;
    [storage beginEditing];
    
    [storage setAttributedString:[NSAttributedString new]];
    
    [_totalconnectedSockets enumerateObjectsUsingBlock:^(imUserInfo *userInfo, BOOL * _Nonnull stop) {
        
        NSString *strName = IS_CAN_USE_STRING(userInfo.userName)?[NSString stringWithFormat:@"%@\n",userInfo.userName]:[NSString stringWithFormat:@"%@:%hu\n",[userInfo.socket connectedHost],[userInfo.socket connectedPort]];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:strName attributes:@{ NSForegroundColorAttributeName :userInfo.state ==imState_online? [NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1]:[NSColor colorWithSRGBRed:0 green:0 blue:0 alpha:1] }];
        [storage appendAttributedString:string];
        
    }];
    
    [storage endEditing];
    
    
}


@end
