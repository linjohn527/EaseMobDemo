//
//  AddFriendViewController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/28/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "AddFriendViewController.h"
#import "EMSDK.h"

@interface AddFriendViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)addFriend {
    
    if (self.usernameTextField.text.length == 0) {
        return;
    }
    
    //发送添加好友的请求
    NSString *message = [NSString stringWithFormat:@"%@想加你为好友",[EMClient sharedClient].currentUsername];
    EMError *error = [[EMClient sharedClient].contactManager addContact:self.usernameTextField.text message:message];
    
    if (!error) {
        
        NSLog(@"添加好友成功");
    }
}


@end
