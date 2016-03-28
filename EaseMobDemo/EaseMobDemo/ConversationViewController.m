//
//  ConversationViewController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/27/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "ConversationViewController.h"
#import "EMSDK.h"

@interface ConversationViewController ()<EMClientDelegate,EMChatManagerDelegate>

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //
    [[EMClient sharedClient] addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
  
}


#pragma mark - <EMClientDelegate>
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState {

    if (aConnectionState == EMConnectionDisconnected) {
        
        NSLog(@"未连接");
    }
}


#pragma mark - <EMChatManagerDelegate> 

@end
