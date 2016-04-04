//
//  AddressBookViewController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/27/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "AddressBookViewController.h"
#import "AddFriendViewController.h"
#import "EMSDK.h"
#import "ChatViewController.h"

@interface AddressBookViewController ()<EMContactManagerDelegate>

/** 好友列表 */
@property(nonatomic,strong)NSArray *buddyList;


@end

@implementation AddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = YES;
    self.tableView.rowHeight = 70;
    
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriend)];
    
    //添加添加好友请求的监听
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    
    //初始化好友列表,先从本地数据库获取好友列表
    self.buddyList = [[EMClient sharedClient].contactManager getContactsFromDB];
    
    //如果本地数据库没有数据，则从服务器获取
    [self asyncFetchBuddyListFromServer];
    
}


#pragma mark - 导航栏按钮处理事件
- (void)addFriend {

    AddFriendViewController *vc = [[AddFriendViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.buddyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.textLabel.text = self.buddyList[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSLog(@"删除好友");
        
        NSString *userToBeRemoved = self.buddyList[indexPath.row];
        [self asyncFetchBuddyListFromServer];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        EMError *error = [[EMClient sharedClient].contactManager deleteContact:userToBeRemoved];
        
        if (!error) {
            
            NSLog(@"删除用户成功");
        }
    }
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    ChatViewController *chatVC = [[UIStoryboard storyboardWithName:@"ChatView" bundle:nil] instantiateInitialViewController];
    chatVC.username = self.buddyList[indexPath.row];
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - <EMContactManagerDelegate>
-(void)didReceiveAgreedFromUsername:(NSString *)aUsername {
    
    __weak typeof(self) weakSelf = self;
    [self showConfirmInfoWithTitle:@"好友申请通知" message:[NSString stringWithFormat:@"好友%@同意了你的申请",aUsername] block:^{
         //更新通讯录的列表
        [weakSelf asyncFetchBuddyListFromServer];
    }];
    
}

-(void)didReceiveDeclinedFromUsername:(NSString *)aUsername {

    [self showConfirmInfoWithTitle:@"好友申请通知" message:[NSString stringWithFormat:@"好友%@拒绝了你的申请",aUsername] block:nil];
    
}

- (void)didReceiveDeletedFromUsername:(NSString *)aUsername {

    __weak typeof(self) weakSelf = self;
    [self showConfirmInfoWithTitle:@"好友删除通知" message:[NSString stringWithFormat:@"你已经被%@从好友列表中移除",aUsername] block:^{
        
         [weakSelf asyncFetchBuddyListFromServer];
    }];
    
   
}

/**
 *  从服务器异步获取最新的好友列表信息
 */
- (void)asyncFetchBuddyListFromServer {
  
    
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            EMError *error = nil;
            NSArray *latestBuddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];//该请求方法会堵塞当前线程
    
            if (!error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{//在主线程更新UI
                    
                    if (self.buddyList.count != latestBuddyList.count) {//更新最新的数据
                        self.buddyList = latestBuddyList;
                        [self.tableView reloadData];
                    }
                   
                    
                });
            }
        });
    
}


- (void)showConfirmInfoWithTitle:(NSString *)title message:(NSString *)message block:(void (^)())block {

    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !block?:block();
    }];
    
    [alertVC addAction:action1];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
