//
//  MoreActionView.m
//  EaseMobDemo
//
//  Created by linjohn on 4/2/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "MoreActionView.h"
#import "MoreActionButton.h"

#define MAX_COLUMNS 4
#define EDGE_MARGIN 10
#define INTERNAL_MARGIN 10

@implementation MoreActionView

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setup];
    }
    
    return self;
}


- (void)awakeFromNib {

    [self setup];
}

- (void)setup {

    //照片按钮
    [self addMoreActionButtonWithType:MoreActionButtonTypePhoto image:@"chatBar_colorMore_photo" selectedImg:@"chatBar_colorMore_photoSelected"];
    
    //位置按钮
    [self addMoreActionButtonWithType:MoreActionButtonTypePhoto image:@"chatBar_colorMore_location" selectedImg:@"chatBar_colorMore_locationSelected"];
    
    //拍照按钮
    [self addMoreActionButtonWithType:MoreActionButtonTypePhoto image:@"chatBar_colorMore_camera" selectedImg:@"chatBar_colorMore_cameraSelected"];
    
    //电话按钮
    [self addMoreActionButtonWithType:MoreActionButtonTypePhoto image:@"chatBar_colorMore_audioCall" selectedImg:@"chatBar_colorMore_audioCallSelected"];

    //视频按钮
    [self addMoreActionButtonWithType:MoreActionButtonTypePhoto image:@"chatBar_colorMore_videoCall" selectedImg:@"chatBar_colorMore_videoCallSelected"];
}


- (void)addMoreActionButtonWithType:(MoreActionButtonType)type image:(NSString *)image selectedImg:(NSString *)selectedImg {

    MoreActionButton *actionBtn = [[MoreActionButton alloc] init];
    actionBtn.type = type;
    [actionBtn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [actionBtn setImage:[UIImage imageNamed:selectedImg] forState:UIControlStateHighlighted];
    [actionBtn addTarget:self action:@selector(moreActionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:actionBtn];
    
}

/**
 *  通过代理通知点击了那个按钮
 *
 *  @param button 被点击的按钮
 */
- (void)moreActionBtnClick:(MoreActionButton *)button {

    if ([self.delegate respondsToSelector:@selector(moreActionView:didSelectButton:)]) {
        
        [self.delegate moreActionView:self didSelectButton:button];
    }
    
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    NSUInteger subviewsCount = self.subviews.count;
    CGFloat btnW = (CGRectGetWidth(self.frame) - 2 * EDGE_MARGIN - (subviewsCount - 1) * INTERNAL_MARGIN) / MAX_COLUMNS;
    CGFloat btnH = 50;

    for (NSUInteger i = 0 ; i < subviewsCount; i++) {
        
        MoreActionButton *actionBtn = self.subviews[i];
        
        NSUInteger col = i % MAX_COLUMNS;
        NSUInteger row = i / MAX_COLUMNS;
        
        CGFloat btnX = EDGE_MARGIN + col * (btnW + INTERNAL_MARGIN);
        CGFloat btnY = EDGE_MARGIN + row * (btnH + INTERNAL_MARGIN);
        
        actionBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}

@end
