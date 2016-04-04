//
//  MoreActionView.h
//  EaseMobDemo
//
//  Created by linjohn on 4/2/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoreActionView,MoreActionButton;

@protocol MoreActionViewDelegate<NSObject>

- (void)moreActionView:(MoreActionView *)view didSelectButton:(MoreActionButton *)button;

@end

@interface MoreActionView : UIView

/** 代理 */
@property(nonatomic,weak)id<MoreActionViewDelegate> delegate;


@end
