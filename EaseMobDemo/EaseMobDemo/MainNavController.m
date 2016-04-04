//
//  MainNavController.m
//  EaseMobDemo
//
//  Created by linjohn on 3/29/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "MainNavController.h"

@interface MainNavController ()

@end

@implementation MainNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {

    if (self.viewControllers.count > 0) {
        
        viewController.hidesBottomBarWhenPushed = YES;
        
    }
    
     [super pushViewController:viewController animated:animated];
    
   
    
   
}

@end
