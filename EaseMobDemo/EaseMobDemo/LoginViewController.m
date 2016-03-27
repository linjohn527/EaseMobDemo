//
//  LoginViewController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/27/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "LoginViewController.h"
#import "EMSDK.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)login:(id)sender {
    
    if (self.usernameTextField.text.length == 0 || self.passwordTextField.text.length == 0) {//用户名和密码不能为空
        return;
    }
    
    //调用SDK的接口登录
    EMError *error = [[EMClient sharedClient] loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    
    if (!error) {//登录成功
        
        NSLog(@"登录成功");
    }
    
}


@end
