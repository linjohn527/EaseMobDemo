//
//  ChatViewController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/29/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "ChatViewController.h"
#import "EMSDK.h"
#import "ChatViewCell.h"
#import "EMCDDeviceManager.h"
#import "MoreActionView.h"
#import "MoreActionButton.h"

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,MoreActionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageToolbarY;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *messageToolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *speakButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageToolbarConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *speakBtnBottomConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;

/** 会话列表 */
@property(nonatomic,strong)NSArray *messages;

/** 当前会话 */
@property(nonatomic,strong)EMConversation *conversation;


/** 当前的用户 */
@property(copy,nonatomic)NSString *currentUsername;

/** 更多输入的view */
@property(nonatomic,strong)MoreActionView *moreActionView;


@end

@implementation ChatViewController


- (MoreActionView *)moreActionView {

    if (!_moreActionView) {
        
        _moreActionView  = [[MoreActionView alloc] init];
        _moreActionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
        _moreActionView.delegate = self;
    }
    
    return _moreActionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    //
    self.title = self.username;
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    
    
    
    //设置表格的相关属性
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //获取当前用户
    self.currentUsername = [EMClient sharedClient].currentUsername;
    
    
    //从数据库或者网络加载对话
    [self loadAllConversation];
    
   
    //注册监听接收信息代理
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    //设置讲话按钮开始的时候为隐藏
    self.speakButton.hidden = YES;
    
}

- (void)dealloc {
    
    //移除广播和代理
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

/**
 *  键盘frame即将改变的通知
 */
- (void)keyboardFrameChange:(NSNotification *)notif {

    CGRect keyboardFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.messageToolbarY.constant = SCREEN_HEIGHT - keyboardFrame.origin.y;
    
    [UIView animateWithDuration:duration animations:^{
        
        [self.view layoutIfNeeded];
    }];
}

/**
 *  从数据库或者网络加载所有历史会话记录
 */
- (void)loadAllConversation {

    //新建、获取对话
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    //EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.username type:EMConversationTypeChat createIfNotExist:YES];
    
    
    self.conversation = [conversations lastObject];
    
    //从数据库获取指定数量的消息
    self.messages = [self.conversation loadMoreMessagesFromId:nil limit:100];
    
    //让表格滚动到最后一条消息的cell位置
    [self scrollToBottom];
}

#pragma mark - <UITextFieldDelegate>

- (void)textDidChange:(NSNotification *)notify {

    if (self.textView.text.length == 0) {//没有输入任何信息，返回
        
        return;
    }
    
    //textView的最小和最大的高度
    CGFloat minH = 32;
    CGFloat maxH = 68;
    
    //textView的高度
    CGFloat textViewH = 0;
    
    //内容的高度
    CGFloat contentH = self.textView.contentSize.height;
    
    if (contentH <= minH) {
        
        textViewH = minH;
    
    } else if(contentH >= maxH) {
    
        textViewH = maxH;
    
    } else {
    
        textViewH = contentH;
    }
    
    
    if ([self.textView.text hasSuffix:@"\n"]) {//输入换行符，发送信息
        
        //去掉换行符
        NSUInteger length = self.textView.text.length;
        NSString *text = [self.textView.text substringToIndex:length - 1];
        
        //构造文字消息
        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
        
        
        //发送文本消息
        [self sendTextMessage:body];
        
        //清空textView的文字
        self.textView.text = nil;
        
        //更新textView的高度
        textViewH = minH;

    }
    
    //更新textView的高度
    self.textViewHeight.constant = textViewH;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.view layoutIfNeeded];
    }];
    
    //
    [self.textView setContentOffset:CGPointZero];
    [self.textView setScrollsToTop:YES];
}

/**
 *  发送文本消息
 *
 *  @param message 文本消息
 */
- (void)sendTextMessage:(EMMessageBody *)body {

    [self sendMessage:body];
}

/**
 *  滚动到表格的最底部
 */
- (void)scrollToBottom {

    NSInteger lastIndex = self.messages.count == 0?0:self.messages.count - 1;
    if (lastIndex) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

/**
 *  刷新表格数据并且滚动到表格的最后位置
 */
- (void)refreshTableView {

    [self.tableView reloadData];
    [self scrollToBottom];
}

#pragma mark - <EMChatManagerDelegate>
- (void)didReceiveMessages:(NSArray *)aMessages {

    NSLog(@"接收到一条及以上消息");
    
    self.messages = [self.messages arrayByAddingObjectsFromArray:aMessages];
    
    [self refreshTableView];
}



#pragma mark - Speak Button Action

/**
 *  点击左边的按钮时，切换键盘输入和语音输入模式
 */
- (IBAction)changeEditingMode:(UIButton *)sender {
    
    
    //显示或者隐藏说话按钮
    self.speakButton.hidden = !self.speakButton.hidden;
    //显示或者隐藏textView
    self.textView.hidden = !self.speakButton.hidden;
    
    //改变左边按钮的背景图片
    NSString * imageName = (self.speakButton.hidden?@"chatBar_record":@"chatBar_keyboard");
     NSString *selectedImgName = (self.speakButton.hidden?@"chatBar_recordSelected":@"chatBar_keyboardSelected");
    
    [sender setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [sender setBackgroundImage:[UIImage imageNamed:selectedImgName] forState:UIControlStateHighlighted];
    
    if (self.speakButton.hidden) {//隐藏
        
        self.textViewBottomConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        
        [self textDidChange:nil];

    } else {//显示
    
        self.textViewBottomConstraint.priority = UILayoutPriorityDefaultHigh - 1;
        
        //self.textViewHeight.constant = 33;
        [UIView animateWithDuration:0.2 animations:^{
            
             [self.view layoutIfNeeded];
        }];
    }
    
}


- (IBAction)startRecord:(id)sender {
    
    NSLog(@"开始录音!");
    //开始录音
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    int randomNumber = arc4random()%100000;
    NSString *fileName = [NSString stringWithFormat:@"%ld%d",timestamp,randomNumber];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:nil] ;
}


- (IBAction)cancleRecord:(id)sender {
    
    NSLog(@"取消说话!");
    
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

/**
 *  开始发送语音消息
 */
- (IBAction)endRecord:(id)sender {
    
    NSLog(@"结束语音!");
    //停止录音
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        
        [self sendVoiceMessageWithRecPath:recordPath duration:(int)aDuration];
    }];
}

/**
 *  发送语音
 *
 *  @param recordPath 语音文件的路径
 *  @param duration   语音文件的时长
 */
- (void)sendVoiceMessageWithRecPath:(NSString *)recordPath duration:(int) duration {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:recordPath]) {//录音文件不存在
        
        return;
    }
    
    //构造语音消息体
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithLocalPath:recordPath displayName:@"[语音]"];
    voiceBody.duration = duration;
    
   //发送语音
    [self sendMessage:voiceBody];
    
    
}


#pragma mark - 发送图片信息
- (IBAction)addMoreAction:(id)sender {
    
    if (self.textView.inputView == nil) {
    
        self.textView.inputView = self.moreActionView;
        
    } else {
    
        self.textView.inputView = nil;
    }

    [self.textView reloadInputViews];
    
}

#pragma mark - <MoreActionViewDelegate>
- (void)moreActionView:(MoreActionView *)view didSelectButton:(MoreActionButton *)button {
    
    switch (button.type) {
        case MoreActionButtonTypePhoto:
            NSLog(@"点击照片按钮");
            //打开选中相片的控制器
            [self openImagePicController];
            break;
        case MoreActionButtonTypeLocation:
            NSLog(@"点击位置按钮");
            break;
        default:
            break;
    }
}

#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    
    //关闭控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //获得选中的相片
    UIImage *selectedImg = info[UIImagePickerControllerOriginalImage];
    
    
    //构造图片消息体
    NSData *data = UIImageJPEGRepresentation(selectedImg, 0.8);
    
    EMImageMessageBody *imgBody = [[EMImageMessageBody alloc] initWithData:data displayName:@"[图片信息]"];
    
    //发送图片
    [self sendMessage:imgBody];
    
}

/**
 *  打开相片控制器，选择相片
 */
- (void)openImagePicController {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - 发送消息的统一方法
- (void)sendMessage:(EMMessageBody *)body {

    NSString *from = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.conversation.conversationId from:from to:self.username body:body ext:nil];
    //设置单聊
    message.chatType = EMChatTypeChat;
    
    //发送消息
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:^(int progress) {
        
    } completion:^(EMMessage *message, EMError *error) {
        
        NSLog(@"%@",error.errorDescription);
        
        //加载最新数据
        weakSelf.messages = [weakSelf.conversation loadMoreMessagesFromId:nil limit:100];
        
        //刷新表格数据并且滚动到最新的消息cell
        [weakSelf refreshTableView];
    }];
}


#pragma mark - <UITableViewDataSource>

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EMMessage *message = self.messages[indexPath.row];
    
    ChatViewCell *cell = [ChatViewCell initWithTableView:tableView message:message indexPath:indexPath];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    return 200;
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    //停止播放当前的音频
    [[EMCDDeviceManager sharedInstance] stopPlaying];
}
@end
