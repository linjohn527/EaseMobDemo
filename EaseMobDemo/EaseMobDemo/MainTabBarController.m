//
//  MainTabBarController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/27/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "MainTabBarController.h"
#import "ConversationViewController.h"
#import "AddressBookViewController.h"
#import "SettingViewController.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //
    ConversationViewController *conVC = [[ConversationViewController alloc] init];
    
    [self addChildViewController:conVC title:@"会话" image:@"tabbar_chats" highligtImg:@"tabbar_chatsHL"];
    
    
    //
    AddressBookViewController *addVC = [[AddressBookViewController alloc] init];
    
    [self addChildViewController:addVC title:@"通讯录" image:@"tabbar_contacts" highligtImg:@"tabbar_contactsHL"];
    
    //
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    
    [self addChildViewController:settingVC title:@"设置" image:@"tabbar_setting" highligtImg:@"tabbar_settingHL"];
}

-(void)addChildViewController:(UIViewController *)vc title:(NSString *)title image:(NSString *)image highligtImg:(NSString *)highlightImg {

    //
    vc.title = title;
    
    //
    [vc.tabBarItem setImage:[UIImage imageNamed:image]];
    [vc.tabBarItem setSelectedImage:[UIImage imageNamed:highlightImg]];
    
    //
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [vc.tabBarItem setTitleTextAttributes:attrs forState:UIControlStateNormal];
    
    //
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    attrs[NSForegroundColorAttributeName] = [UIColor blueColor];
    [vc.tabBarItem setTitleTextAttributes:selectedAttrs forState:UIControlStateNormal];
    
    
    //
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self addChildViewController:nav];
}


@end
