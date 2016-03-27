//
//  LoginViewController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/27/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "LoginViewController.h"
#import "EMSDK.h"
#import "MainTabBarController.h"

@interface LoginViewController ()<EMClientDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    //添加代理监听
    [[EMClient sharedClient] addDelegate:self delegateQueue:dispatch_get_main_queue()];
 
}


/**
 *  跳转主界面
 */
- (void)switchToMainTabBarVC {

    //跳转主界面
    MainTabBarController *mainTabBar = [[MainTabBarController alloc] init];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = mainTabBar;
}

/**
 *  登录
 */
- (IBAction)login:(id)sender {
    
    if (self.usernameTextField.text.length == 0 || self.passwordTextField.text.length == 0) {//用户名和密码不能为空
        return;
    }
    
    //调用SDK的接口登录
    
    BOOL isAutoLogin = [[EMClient sharedClient] isAutoLogin];
    
    if (!isAutoLogin) {
        
        EMError *error = [[EMClient sharedClient] loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
        
        if (!error) {//登录成功
            
            NSLog(@"登录成功");
            
            //设置自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
           //跳转主界面
            [self switchToMainTabBarVC];
            
        } else {//登录失败
            
            NSLog(@"%@",error);
        }

    }
}

#pragma mark - <EMClientDelegate>
- (void)didAutoLoginWithError:(EMError *)aError {


    if (!aError) {//自动登录没有错误
        
        [self switchToMainTabBarVC];
        
    } else {
    
        NSLog(@"%@",aError);
    }
}

@end
