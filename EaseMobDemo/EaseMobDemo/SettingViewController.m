//
//  SettingViewController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/27/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "SettingViewController.h"
#import "EMSDK.h"
#import "LoginViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *footerView = [UIButton buttonWithType:UIButtonTypeCustom];
    footerView.frame = CGRectMake(0,0 , 200, 80);

    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    footerView.backgroundColor = [UIColor redColor];
    [footerView setTitle:[NSString stringWithFormat:@"退出(%@)",currentUsername] forState:UIControlStateNormal];
    
    [footerView addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = footerView;
}


- (void)logout {

   EMError *error = [[EMClient sharedClient] logout:YES];
    
    if (!error) {
        
        NSLog(@"退出成功");
        
        //
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.title = @"登录";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        
        UINavigationBar *bar = [UINavigationBar appearance];
        [bar setBarTintColor:[UIColor blueColor]];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.rootViewController = nav;
    }
}

#pragma mark - <UITableViewDataSource>


@end
