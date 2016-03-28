//
//  AppDelegate.m
//  EaseMobDemo
//
//  Created by linjohn on 3/26/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "AppDelegate.h"
#import "EMSDK.h"
#import "LoginViewController.h"
#import "MainTabBarController.h"

@interface AppDelegate ()<EMClientDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
   
    
    EMOptions *options = [EMOptions optionsWithAppkey:@"hehemmm#hxcs"];
    
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    
    //
    //添加代理监听
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    
    
    //先跳转到登录界面
    [self switchToLoginVC];
    
     [self.window makeKeyAndVisible];

    return YES;
}

/**
 *  跳转到登录控制器
 */
- (void)switchToLoginVC {

    //
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.title = @"登录";
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBarTintColor:[UIColor blueColor]];
    
    self.window.rootViewController = nav;
    
}

/**
 *  跳转主界面
 */
- (void)switchToMainTabBarVC {
    
    //跳转主界面
    MainTabBarController *mainTabBar = [[MainTabBarController alloc] init];
    
    self.window.rootViewController = mainTabBar;

    [self.window makeKeyAndVisible];
}


#pragma mark - <EMClientDelegate>
- (void)didAutoLoginWithError:(EMError *)aError {
  
    if (!aError) {//自动登录没有错误
        
        [self switchToMainTabBarVC];
        
        
    } else {
        
        NSLog(@"%@",aError);
        
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
