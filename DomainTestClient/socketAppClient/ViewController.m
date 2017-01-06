//
//  ViewController.m
//  socketAppClient
//
//  Created by xiaoquan jiang on 28/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "ViewController.h"
#import "UIProfileView.h"

#import "imTextMsgInfo.h"
#import "imUserInfo.h"
#import "transferProtocolInfo.h"
#import "publicFunc.h"

#import "GCDAsyncSocket.h"
#import "UIMessageVC.h"
#import "imSingleUserMsgCollectionInfo.h"


@interface ViewController ()<GCDAsyncSocketDelegate>
{
    float _profile_to_right_const;
    float _profile_to_left_const;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *ipTextfield;
@property (weak, nonatomic) IBOutlet UIProfileView *profileView;
@property (weak, nonatomic) IBOutlet UITableView *userTbView;

@property (strong, nonatomic)NSMutableArray *totalconnectedSockets;
@property (strong, nonatomic)NSMutableDictionary *messageDic; //@{"userid":@[imTextMsgInfo,imTextMsgInfo]}

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (weak, nonatomic) IBOutlet UIButton *disconnectBtn;

@property (strong, nonatomic) imUserInfo *selfUserInfo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profile_to_right_constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profile_to_left_constraint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _totalconnectedSockets = [[NSMutableArray alloc] init];
    _messageDic = [[NSMutableDictionary alloc] init];
    self.ipTextfield.text = @"localhost";
    self.disconnectBtn.enabled = NO;
    
    _selfUserInfo = [[imUserInfo alloc] init];
    
    _profile_to_right_const = self.profile_to_right_constraint.constant;
    _profile_to_left_const = self.profile_to_left_constraint.constant;
    
    
    UIBarButtonItem*leftBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"switch" style: UIBarButtonItemStyleDone target:self action:@selector(onLeftNaviItemClick:)];
    
    self.navigationItem.leftBarButtonItem = leftBtnItem;
    
    // -------------
    [self _testSize];
    
}

- (void)_testSize
{
    int _intv = 0;
    NSInteger _integerv = 0;
    long _longv = 0;
    float _floatv = 0.0f;
    
    NSLog(@"\n\nint:%lu\nNSInteger:%lu\nlong:%lu\nfloat:%lu\nchar:%lu\nbyte:%lu\n\n",sizeof(_intv),sizeof(_integerv),sizeof(_longv),sizeof(_floatv),sizeof(char),sizeof(Byte));
    
    
    
}


- (void)onLeftNaviItemClick:(id)sender
{
    [self _profileShow:self.profileView.hidden];
}

- (void)_connectToHost:(NSString*)host;
{
    NSError *error = nil;
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSLog(@"____host:%@",host);
    if ( ![self.socket connectToHost:host onPort:59558 error:&error] )
    {
        
    }
    
}

- (IBAction)onConnectBtbClick:(id)sender
{
    self.connectBtn.enabled = NO;
    [self.nameTextfield resignFirstResponder];
    [self.ipTextfield resignFirstResponder];
    
    [self _connectToHost:self.ipTextfield.text];
}
- (IBAction)onDisconnectBtnClick:(id)sender
{
    _socket = nil;
    self.connectBtn.enabled = YES;
    self.disconnectBtn.enabled = NO;
}



- (void)socket:(GCDAsyncSocket *)sock didConnectToUrl:(NSURL *)url;
{
    NSLog(@"[Client] Connected to %@", url);
    [sock readDataWithTimeout:-1 tag:0];
    
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error;
{
    NSLog(@"[Client] Closed connection: %@", error);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectBtn.enabled = YES;
        self.disconnectBtn.enabled = NO;
        _socket = nil;
        [self _profileShow:YES];
        
        [_totalconnectedSockets removeAllObjects];
        [self.userTbView reloadData];
    });
    

}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"[Client] didConnectToHost: %@:%hu", host,port);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectBtn.enabled = NO;
        self.disconnectBtn.enabled = YES;
        [self _profileShow:NO];
    });
    
   // [sock readDataWithTimeout:-1 tag:0];

    
    _selfUserInfo.userID = [publicFunc getSystemUUID];
    _selfUserInfo.userName = self.nameTextfield.text;
    _selfUserInfo.state = imState_online;
    
    transferProtocolInfo *pro = [transferProtocolInfo new];
    pro.tag = enTransferType_user;
    pro.data = _selfUserInfo;
    
    [self.socket writeData:[publicFunc objetToJson:[pro getStructerData]] withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSLog(@"[Client] Received: %lu", (unsigned long)[data length]);
    
    // parser data
    NSError *error = nil;
    id tranferDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
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
            [self _updateUserList:transfer.data ];
        }
            break;
        case enTransferType_userList:
        {
            [self _updateUserList:(imUserInfo *)transfer.data];
        }
            break;
        case enTransferType_textmsg:
        {
            [self _dueWithMsgReveicing:(imTextMsgInfo *)transfer.data data:data socket:sock];
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
- (void)_dueWithMsgReveicing:(imTextMsgInfo*)msgOb data:(NSData *)data socket:(GCDAsyncSocket *)sock
{
    NSString *searchingKey = msgOb.sender.userID;
    
    // default to all
    imSingleUserMsgCollectionInfo *userMsgOb = [_messageDic objectForKey:searchingKey];
    if ( !userMsgOb )
    {
        userMsgOb = [[imSingleUserMsgCollectionInfo alloc] init];
        
        userMsgOb.userInfo = msgOb.sender;
        [_messageDic setObject:userMsgOb forKey:searchingKey];
    }
    [userMsgOb addMsgObj:msgOb];
    userMsgOb.unReadNum++;
    
    
    [self _updateUserList:msgOb.sender];
    
    
    // notice To UI
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [[NSNotificationCenter defaultCenter] postNotificationName:msg_newmsg_notice_key object:nil];
        [self.userTbView reloadData];
    });
}



/**
 更新用户表
 
 @param data user description
 */
-(void)_updateUserList:(id )data
{
    __block BOOL bIsExist = NO;
    
    __block void (^searchBlock)(imUserInfo *user)  = ^(imUserInfo *user) {
        
        
        // (imUserInfo *)user
        [_totalconnectedSockets enumerateObjectsUsingBlock:^(imUserInfo *userInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // for all
            if ( [user.userID isEqualToString:userInfo.userID])
            {
                userInfo.userID = user.userID;
                userInfo.userName = user.userName;
                userInfo.state = user.state;
                bIsExist = YES;
                *stop = YES;
            }
            
        }];
        
        // not exist
        if ( !bIsExist )
        {
            [_totalconnectedSockets addObject:user];
        }
        
    };
    
    
    if ( [data isKindOfClass:[imUserInfo class]] )
    {
        searchBlock((imUserInfo*)data);
    }
    else
    {
        NSArray *userArr = (NSArray*)data;
        [userArr enumerateObjectsUsingBlock:^(imUserInfo *userInfo, NSUInteger idx, BOOL * _Nonnull stop) {
             searchBlock(userInfo);
        }];
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.userTbView reloadData];
    });
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark  systemdelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _totalconnectedSockets.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    static NSString *CellIdentifier = @"UITableViewCell____";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
    }
    
    
    // default to all
    imSingleUserMsgCollectionInfo *userMsgOb = nil;
    
    imUserInfo *userInfo = [_totalconnectedSockets objectAtIndex:indexPath.row];
    
    userMsgOb =  [_messageDic objectForKey:userInfo.userID];
    cell.textLabel.text = [NSString stringWithFormat:@"%@     (%ld)",userInfo.userName,userMsgOb.unReadNum];
    cell.textLabel.textColor = userInfo.state ==imState_online?[UIColor redColor]:[UIColor grayColor];
    
    
    imTextMsgInfo *texInco = userMsgOb.msgArr.lastObject;
    cell.detailTextLabel.text = texInco?texInco.body:@"";
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    return cell;
    
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIMessageVC *mesgVC = [[UIMessageVC alloc] initWithNibName:@"UIMessageVC" bundle:nil];
    
    imUserInfo *userInfo = [_totalconnectedSockets objectAtIndex:indexPath.row];
    NSString *searchKey = userInfo.userID;
  
    imSingleUserMsgCollectionInfo *userMsgOb = [_messageDic objectForKey:searchKey];
    if ( !userMsgOb )
    {
        userMsgOb = [[imSingleUserMsgCollectionInfo alloc] init];
        userMsgOb.userInfo = userInfo;
        [_messageDic setObject:userMsgOb forKey:searchKey];
    }
    mesgVC.msgColloctionInfo = userMsgOb;
    userMsgOb.unReadNum = 0;
    [self.userTbView reloadData];
    
     __weak __typeof__(self) weakSelf = self;
    [mesgVC setUIMessageVCSBack:^(imUserInfo *toUserInfo, NSString *msgText) {
        
        __strong __typeof__(weakSelf) strongSelf = weakSelf;
        
        imTextMsgInfo *textMsg = [imTextMsgInfo new];
        textMsg.sender = strongSelf.selfUserInfo;
        textMsg.receiver = toUserInfo;
        textMsg.body = msgText;
        textMsg.msgTime = [[NSDate date] timeIntervalSince1970];
        
        
        transferProtocolInfo *pro = [transferProtocolInfo new];
        pro.tag = enTransferType_textmsg;
        pro.data = textMsg;
        
        NSData *sendData = [publicFunc objetToJson:[pro getStructerData]];
        //NSLog(@"___send:%@",[[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding]);
        
        [strongSelf.socket writeData:sendData withTimeout:-1 tag:0];
        [strongSelf.socket readDataWithTimeout:-1 tag:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.userTbView reloadData];
        });
        
        
        return textMsg;
        
    }];
    
    
    [self.navigationController pushViewController:mesgVC animated:YES];
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ( textField == self.ipTextfield ) {
        [textField resignFirstResponder];
    }
    
    return YES;
}


- (void)_profileShow:(BOOL)show
{
    [self _commitAnnimationBlock:^{
        
        self.profile_to_right_constraint.constant = show?_profile_to_right_const:self.profileView.bounds.size.width + _profile_to_right_const;
        self.profile_to_left_constraint.constant = show?_profile_to_left_const: - self.profileView.bounds.size.width;
        
        [self.view layoutIfNeeded];
        
        self.profileView.hidden = !show;
    }];
}


- (void)_commitAnnimationBlock:(void (^)(void))animations
{
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    // set views with new info
    
    animations();
    
    // commit animations
    [UIView commitAnimations];
    
}


@end
