//
//  UIMessageVC.m
//  DomainTest
//
//  Created by xiaoquan jiang on 28/12/2016.
//  Copyright © 2016 Jonathan Diehl. All rights reserved.
//

#import "UIMessageVC.h"
#import "publicFunc.h"

#define tb_view_to_top 44

@interface UIMessageVC ()<UITableViewDataSource,UITableViewDelegate>
{
     CGFloat _f_headBgView_contrains_buttom;
}

@property (weak, nonatomic) IBOutlet UITableView *msgTbView;
@property (weak, nonatomic) IBOutlet UIView *inputBgView;
@property (weak, nonatomic) IBOutlet UITextField *inputTextfield;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputBgView_toBottom_constraint;

@property (nonatomic,copy) UIMessageVCSBack msgCallBackBlock;

@end

@implementation UIMessageVC

- (void)dealloc
{
    NSLog(@"____:%s____",__func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _f_headBgView_contrains_buttom = self.inputBgView_toBottom_constraint.constant;
    self.msgTbView.delegate = self;
    self.msgTbView.dataSource = self;

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                               selector:@selector(keyboardWillShow:)
                                   name:UIKeyboardWillShowNotification
                                 object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                               selector:@selector(keyboardWillHide:)
                                   name:UIKeyboardWillHideNotification
                                 object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTbView:)
                                                 name:msg_newmsg_notice_key
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.msgTbView.contentInset = UIEdgeInsetsMake(tb_view_to_top,0,0, 0);
    self.msgTbView.scrollIndicatorInsets = UIEdgeInsetsMake(tb_view_to_top,0, 0,0);
    self.msgColloctionInfo.unReadNum = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) reloadTbView:(NSNotification *)note
{
    self.msgColloctionInfo.unReadNum = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.msgTbView reloadData];
        [self _scrollToBottomAnimated:YES];
    });
}

- (void)setUIMessageVCSBack:(UIMessageVCSBack)callBacBlock
{
    _msgCallBackBlock = NULL;
    _msgCallBackBlock = [callBacBlock copy];
}

- (IBAction)onSendBtnClick:(id)sender {
    
    if (_msgCallBackBlock) {
         imTextMsgInfo *textMsg =  _msgCallBackBlock(self.msgColloctionInfo.userInfo,self.inputTextfield.text);
        [self.msgColloctionInfo addMsgObj:textMsg];
    }
     self.inputTextfield.text = @"";
    [self.msgTbView reloadData];
    [self _scrollToBottomAnimated:YES];
    
}

- (void)_scrollToBottomAnimated:(BOOL)animated
{
    NSInteger nnumberofrows = [self.msgTbView numberOfRowsInSection:0];
    if ( nnumberofrows > 0 )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: nnumberofrows - 1 inSection:0];
        [self.msgTbView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
    
}


#pragma mark  systemdelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.msgColloctionInfo.msgArr.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"UITableViewCell____";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell =  [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    imTextMsgInfo *textOb =  [self.msgColloctionInfo.msgArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = textOb.body;
    
    if ( [textOb.sender.userID isEqualToString:[publicFunc getSystemUUID]])
    {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.textLabel.textColor = [UIColor redColor];
    }
    else
    {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    
    return cell;
    
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 28;
}



#pragma mark 键盘回调
//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note
{
    
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [[[UIApplication sharedApplication] keyWindow] convertRect:keyboardBounds toView:self.view];
  
    self.msgTbView.contentInset = UIEdgeInsetsMake(tb_view_to_top,0,  CGRectGetHeight(keyboardBounds) + CGRectGetHeight(self.inputBgView.bounds), 0);
    self.msgTbView.scrollIndicatorInsets = UIEdgeInsetsMake( tb_view_to_top,0, CGRectGetHeight(keyboardBounds) + CGRectGetHeight(self.inputBgView.bounds), 0);
    
    [self commitAnnimation:note sumitBlock:^{
        
        self.inputBgView_toBottom_constraint.constant = CGRectGetHeight(keyboardBounds);
        [self.view layoutIfNeeded];
        
    }];
    
}

- (void)commitAnnimation:(NSNotification *)note sumitBlock:(void (^)(void))animations
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:(UIViewAnimationCurve)[curve intValue]];
    // set views with new info
    
    animations();
    
    // commit animations
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification *)note
{
    
    self.msgTbView.contentInset = UIEdgeInsetsMake(tb_view_to_top,0,0, 0);
    self.msgTbView.scrollIndicatorInsets = UIEdgeInsetsMake(tb_view_to_top,0, 0,0);
    
    [self commitAnnimation:note sumitBlock:^{
        
        self.inputBgView_toBottom_constraint.constant = _f_headBgView_contrains_buttom;
        [self.view layoutIfNeeded];
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onSendBtnClick:nil];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
