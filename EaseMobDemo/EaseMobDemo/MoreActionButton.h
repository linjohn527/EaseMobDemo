//
//  MoreActionButton.h
//  EaseMobDemo
//
//  Created by linjohn on 4/2/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {

    MoreActionButtonTypePhoto,
    MoreActionButtonTypeLocation,
    MoreActionButtonTypeCamera,
    MoreActionButtonTypeCall,
    MoreActionButtonTypeVideo,

}MoreActionButtonType;

@interface MoreActionButton : UIButton

/** 按钮类型 */
@property(assign,nonatomic)MoreActionButtonType type;


@end
