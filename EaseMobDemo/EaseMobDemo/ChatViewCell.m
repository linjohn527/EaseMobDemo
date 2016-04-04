//
//  ChatViewCell.m
//  EaseMobDemo
//
//  Created by linjohn on 3/29/16.
//  Copyright © 2016 linjohn. All rights reserved.
//

#import "ChatViewCell.h"
#import "EMSDK.h"
#import "EMCDDeviceManager.h"
#import "UIImageView+WebCache.h"

static NSString *receivecellIdentifier = @"receivecell";
static NSString *sendcellIdentifier = @"sendcell";

@interface ChatViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

/** 语音动画的图片 */
@property(nonatomic,strong)UIImageView *animationImgV;

/** 图片cell的缩略图片 */
@property(nonatomic,strong)UIImageView *thumbnailImgV;


@end

@implementation ChatViewCell

- (UIImageView *)animationImgV {

    if (!_animationImgV) {
        
        _animationImgV = [[UIImageView alloc] init];
    
    }
    return _animationImgV;
}

- (UIImageView *)thumbnailImgV {

    if (!_thumbnailImgV) {
        
        _thumbnailImgV = [[UIImageView alloc] init];
    }

    return _thumbnailImgV;
}

+ (instancetype)initWithTableView:(UITableView *)tableView message:(EMMessage *)message indexPath:(NSIndexPath *)indexPath {

    ChatViewCell *cell = nil;
    
    NSString *currentUsername = [EMClient sharedClient].currentUsername;

    if (message.from != currentUsername) {//接收的信息
        
        cell = [tableView dequeueReusableCellWithIdentifier:receivecellIdentifier forIndexPath:indexPath];
        
    } else {//发送的信息
        
        cell =  [tableView dequeueReusableCellWithIdentifier:sendcellIdentifier forIndexPath:indexPath];
    }
    
    cell.message = message;

    return cell;
}


- (void)awakeFromNib {
    // Initialization code
    
    //添加手势识别
    self.messageLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVoice)];

    [self.messageLabel addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 *  播放voice图片
 */
- (void)playVoice {

    if ([self.message.body isKindOfClass:[EMVoiceMessageBody class]]) {//语音

        //停止当前正在播放的语音
        [[EMCDDeviceManager sharedInstance] stopPlaying];
        
        //语音消息体
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)self.message.body;
        //判断音频文件是否在本地存在
        NSString *path = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:voiceBody.localPath]) {//本地音频文件存在
            
            path = voiceBody.localPath;
        
        } else {//远程音频文件
        
            path = voiceBody.remotePath;
        }
        
        //开始播放语音,添加动画
        [self addAnimationImageV];
        [self.animationImgV startAnimating];
        [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
            
            if (!error) {//播放完毕，没有错误
                
                //停止动画
                [self.animationImgV stopAnimating];
            }
        }];
        
        

    }
    
}

/**
 *  给语音添加动画图片
 */
- (void)addAnimationImageV {

    [self.messageLabel addSubview:self.animationImgV];
    
    if ([self.reuseIdentifier isEqualToString:@"sendcell"]) {//发送的cell
        
        self.animationImgV.frame = CGRectMake(CGRectGetWidth(self.messageLabel.frame) - 30, 0, 30, 30);
        self.animationImgV.animationImages = @[[UIImage imageNamed:@"chat_sender_audio_playing_000"],[UIImage imageNamed:@"chat_sender_audio_playing_001"],[UIImage imageNamed:@"chat_sender_audio_playing_002"],[UIImage imageNamed:@"chat_sender_audio_playing_003"]];
        
    } else {//接收方的cell
        self.animationImgV.frame = CGRectMake(0, 0, 30, 30);
        self.animationImgV.animationImages = @[[UIImage imageNamed:@"chat_receiver_audio_playing000"],[UIImage imageNamed:@"chat_receiver_audio_playing001"],[UIImage imageNamed:@"chat_receiver_audio_playing002"],[UIImage imageNamed:@"chat_receiver_audio_playing003"]];
    }
    
    //设置动画播放时长
    self.animationImgV.animationDuration = 1;
}

- (void)setMessage:(EMMessage *)message {

    //移除播放语音的动画
    [self.animationImgV stopAnimating];
    [self.animationImgV removeFromSuperview];
    
    _message = message;
    
    EMMessageBody *messageBody = message.body;
    
    if (messageBody.type == EMMessageBodyTypeText) {//文字信息
        
        EMTextMessageBody *textBody = (EMTextMessageBody *)messageBody;
        
        self.messageLabel.text = textBody.text;
    
    } else if(messageBody.type == EMMessageBodyTypeVoice) {//语音消息
    
        self.messageLabel.text = @"[语音消息]";
        
        //在cell中添加语音的图片等富文本消息
        [self setupVoiceMessage];
        
    } else if(messageBody.type == EMMessageBodyTypeImage){//图片信息
    
        [self setupImageMessage];
    }
    
    
    NSString *currentUsername = [EMClient sharedClient].currentUsername;
    if (message.from != currentUsername) {//接收的信息
        
        self.usernameLabel.text = message.from;
        
    } else {//发送的消息
        
        self.usernameLabel.text = currentUsername;
    }
    
}

/**
 *  设置图片cell的富文本信息
 */
- (void)setupImageMessage {

    
    //图片消息体
    EMImageMessageBody *imageBody = (EMImageMessageBody *)self.message.body;
    
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    //attach.image = [UIImage imageNamed:@"114"];
    attach.bounds = CGRectMake(0, 0, 50, 50);
    NSAttributedString *imgAttr = [NSAttributedString attributedStringWithAttachment:attach];
    
    self.messageLabel.attributedText = imgAttr;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:imageBody.thumbnailLocalPath]) {//图片存在于本地
        
        UIImage *image = [UIImage imageNamed:@"chat_video_play"];
        self.thumbnailImgV.image = image;
        self.thumbnailImgV.frame = CGRectMake(0, 0, 50, 50);
        [self.messageLabel addSubview:self.thumbnailImgV];
    
    } else {
    
    }
}

/**
 *  设置语音消息的cell
 */
- (void)setupVoiceMessage {

    NSMutableAttributedString *mAttruteString = [[NSMutableAttributedString alloc] init];
    
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    NSString *imageName = nil;

    //语音消息体
    EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)self.message.body;
    //消息时长
     NSAttributedString *durationAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d''",voiceBody.duration]];
    if ([self.reuseIdentifier isEqualToString: @"sendcell"]) {//发送的Cell
        
        imageName = @"chat_sender_audio_playing_full";
        
        //先添加时长，再添加图片
        [mAttruteString appendAttributedString:durationAttr];
        
        UIImage *image = [UIImage imageNamed:imageName];
        attach.bounds = CGRectMake(0, -8, 30, 30);
        attach.image = image;
        
        NSAttributedString *imgAttr = [NSAttributedString attributedStringWithAttachment:attach];
        
        [mAttruteString appendAttributedString:imgAttr];
        
       
    
    } else {//接收方的cell
        
        imageName = @"chat_receiver_audio_playing_full";
        
        //先添加图片，再添加时长信息
        UIImage *image = [UIImage imageNamed:imageName];
        attach.bounds = CGRectMake(0, -8, 30, 30);
        attach.image = image;
        
        NSAttributedString *imgAttr = [NSAttributedString attributedStringWithAttachment:attach];
        
        [mAttruteString appendAttributedString:imgAttr];
        
        [mAttruteString appendAttributedString:durationAttr];
        
    }
    

    [self.messageLabel setAttributedText:mAttruteString];
}




@end
