//
//  MessageTableViewCell.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYMessageCell.h"
#import "FaceModel.h"
#import "QYUserInfo.h"

#import <AVFile.h>
#import <AVIMAudioMessage.h>
#import <AVIMTextMessage.h>
#import <AVIMLocationMessage.h>
#import <AVIMImageMessage.h>
#import <UIImageView+WebCache.h>

#import "UIView+Extension.h"
#import "NSString+Extension.h"

//语音View的宽度
#define audioMaxWidth kScreenW / 2.f //最长宽度
#define audioMinWidth 50.f //最短宽度
#define widthPerSec (audioMaxWidth - audioMinWidth) / 30.f //每秒的宽度

#define kLocationViewWidth kScreenW * 0.75 //位置视图宽度
#define kLocationViewHeight 100 //位置视图高度

#pragma mark - MessageTableViewCell
@interface QYMessageCell ()
/**
 *  用户头像
 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;//用户头像

/**
 *  消息视图，所有类型的消息都放在该视图中
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;

/**
 *  消息状态提示控件
 */
@property (weak, nonatomic) IBOutlet UIImageView *messageStatusView;


/**
 *  文本消息控件
 */
@property (weak, nonatomic) IBOutlet UIView *messageView;//文本、语音消息共用一个视图
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLab;//文本、语音消息共用一个label

/**
 *  语音消息控件
 */
@property (weak, nonatomic) IBOutlet UIImageView *voiceAnimatingImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceAnimatingViewWidthConstraint;

/**
 *  图片消息控件
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeightConstraint;

/**
 *  位置消息控件
 */
@property (weak, nonatomic) IBOutlet UIView *locationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *microMapImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;

@end

@implementation QYMessageCell

- (void)awakeFromNib {
    // Initialization code
    _messageLab.preferredMaxLayoutWidth = kMessageMaxWidth;
}

//当cell即将被复用时，要把之前的约束恢复初始值
-(void)prepareForReuse{
    _voiceAnimatingViewWidthConstraint.constant = 0;
    _viewWidthConstraint.constant = 0;
    _viewHeightConstraint.constant = 0;
    
    _messageViewHeightConstraint.constant = 0;
    _photoViewHeightConstraint.constant = 0;
    _locationViewHeightConstraint.constant = 0;
    
    _messageLab.textAlignment = NSTextAlignmentRight;
    _messageStatusView.hidden = YES;
    [super prepareForReuse];
}

#pragma mark - setters
-(void)setUser:(QYUserInfo *)user{
    _user = user;
}

-(void)setMessage:(AVIMTypedMessage *)message{
    if (!message) {
        return;
    }
    _message = message;
    switch (message.mediaType) {
        case kAVIMMessageMediaTypeText:
            [self configTextMessage];
            break;
            
        case kAVIMMessageMediaTypeAudio:
            [self configAudioMessage];
            break;
            
        case kAVIMMessageMediaTypeImage:
            [self configPhotoMessage];
            break;
            
        case kAVIMMessageMediaTypeLocation:
            [self configLocationMessage];
            break;
            
        default:
            break;
    }
    
    _viewHeightConstraint.constant = _messageViewHeightConstraint.constant + _photoViewHeightConstraint.constant + _locationViewHeightConstraint.constant;
    
    //如果消息发送失败
    if (message.status == AVIMMessageStatusFailed) {
        _messageStatusView.image = [UIImage imageNamed:@"chat_error_icon"];
        _messageStatusView.hidden = NO;
    }
}

#pragma mark - Custom methods
//计算cell的高度
-(CGFloat)heightWithMessage:(AVIMTypedMessage *)message{
    return _viewHeightConstraint.constant + 10 + 10;
}


//填充文本内容
-(void)configTextMessage{
    _messageLab.attributedText = [NSString faceAttributeTextWithMessage:_message.text withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} faceSize:20];
    [self calculateLayoutWith:_messageLab.attributedText];
}

//填充语音内容
-(void)configAudioMessage{
    [self calculateLayoutWith:_messageLab.attributedText];
    
    AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)_message;
    _voiceAnimatingImageView.animationDuration = 1;
    _voiceAnimatingImageView.animationRepeatCount = audioMessage.duration;
    _voiceAnimatingViewWidthConstraint.constant = _voiceAnimatingImageView.image.size.width;
}

//填充照片内容
-(void)configPhotoMessage{
    CGFloat width = [self.message.file.metaData[@"width"] floatValue];
    CGFloat height = [self.message.file.metaData[@"height"] floatValue];
    
    if (width == 0 || height == 0) {
        self.viewWidthConstraint.constant = kPhotoWidth;
        self.photoViewHeightConstraint.constant = kPhotoHeight;
    }else{
        CGFloat ratio = width / height;
        if (width > height) {
            width = kPhotoWidth;
            height = width / ratio;
        }else{
            height = kPhotoHeight;
            width = height * ratio;
        }
        self.photoViewHeightConstraint.constant = height;
        self.viewWidthConstraint.constant = width;
    }
    
    [self.message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            self.photoImageView.image = image;
        }
    }];
    
//    [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:self.message.file.url]];
}

//填充位置内容
-(void)configLocationMessage{
    _locationViewHeightConstraint.constant = kLocationViewHeight;
    _viewWidthConstraint.constant = kLocationViewWidth;
    
    _locationNameLabel.text = _message.text;
}

-(void)calculateLayoutWith:(NSAttributedString *)text{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(kMessageMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _messageViewHeightConstraint.constant = ceilf(rect.size.height) + 10 + 10;
    
    //根据文本内容调整文本消息布局
    if (_message.mediaType == kAVIMMessageMediaTypeText) {
        _viewWidthConstraint.constant = ceilf(rect.size.width) + _voiceAnimatingViewWidthConstraint.constant + 10 + 20;
    }
    
    //根据时长调整语音消息布局
    if (_message.mediaType == kAVIMMessageMediaTypeAudio) {
        NSInteger duration = [text.string integerValue];
        if (duration >= 30) {
            _viewWidthConstraint.constant = kScreenW / 2.f + _voiceAnimatingViewWidthConstraint.constant + 10 + 20;
        }else{
            _viewWidthConstraint.constant = audioMinWidth + widthPerSec * duration + _voiceAnimatingViewWidthConstraint.constant + 10 + 20;
        }
    }
    
}

//判断手指是否触摸在有效区域
-(BOOL)isTapedInContent:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.contentView];
    if (CGRectContainsPoint(_messageView.superview.frame, point)) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isTapedInIcon:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.contentView];
    if (CGRectContainsPoint(_iconImgView.frame, point)) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isTapedInStatusView:(UITapGestureRecognizer *)tap{
    //如果消息状态按钮是隐藏的，返回NO
    if (_messageStatusView.hidden) {
        return NO;
    }
    
    CGPoint point = [tap locationInView:self.contentView];
    if (CGRectContainsPoint(_messageStatusView.frame, point)) {
        return YES;
    }
    
    return NO;
}


-(void)startVoiceAnimating{
    [_voiceAnimatingImageView startAnimating];
}

-(void)stopVoiceAnimating{
    [_voiceAnimatingImageView stopAnimating];
}
@end


#pragma mark - LeftMessageTableViewCell
@implementation QYLeftMessageCell
-(void)setUser:(QYUserInfo *)user{
    if (user.userPhotos && user.userPhotos.count > 0) {
        NSString *url = user.userPhotos.firstObject;
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:url]];
    }else{
        self.iconImgView.image = [UIImage imageNamed:@"小丸子"];
    }
    
    [super setUser:user];
}

-(void)configAudioMessage{
    AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)self.message;
    NSString *text = [NSString stringWithFormat:@"%@\''", audioMessage.text];
    self.messageLab.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    self.messageLab.textAlignment = NSTextAlignmentRight;
    self.voiceAnimatingImageView.animationImages = @[
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"]];
    
    [super configAudioMessage];
}

-(void)configPhotoMessage{
    [super configPhotoMessage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_gray"]];
    //将图片裁剪成气泡样式
    CGFloat height = self.photoViewHeightConstraint.constant;
    CGFloat width = self.viewWidthConstraint.constant;
    CGRect frame = CGRectMake(0, 0, width, height);
    
    [self.photoImageView maskLayerToView:imageView withFrame:frame];
    
}

-(void)configLocationMessage{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_gray"]];
    //将图片裁剪成气泡样式
    [self.locationView maskLayerToView:imageView withFrame:CGRectMake(0, 0, kLocationViewWidth, kLocationViewHeight)];
    [super configLocationMessage];
}

@end

#pragma mark - RightMessageTableViewCell
@implementation QYRightMessageCell
-(void)setUser:(QYUserInfo *)user{
    if (user.userPhotos && user.userPhotos.count > 0) {
        NSString *url = user.userPhotos.firstObject;
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:url]];
    }else{
        self.iconImgView.image = [UIImage imageNamed:@"小心"];
    }
    
    [super setUser:user];
}

-(void)configAudioMessage{
    AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)self.message;
    NSString *text = [NSString stringWithFormat:@"%@\''", audioMessage.text];
    self.messageLab.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    self.messageLab.textAlignment = NSTextAlignmentLeft;
    self.voiceAnimatingImageView.animationImages = @[
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying000"],
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying003"]];
    
    [super configAudioMessage];
}

-(void)configPhotoMessage{
    
    [super configPhotoMessage];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_red"]];
    //将图片裁剪成气泡样式
    CGFloat height = self.photoViewHeightConstraint.constant;
    CGFloat width = self.viewWidthConstraint.constant;
    CGRect frame = CGRectMake(0, 0, width, height);
    
    [self.photoImageView maskLayerToView:imageView withFrame:frame];
}

-(void)configLocationMessage{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_red"]];
    //将图片裁剪成气泡样式
    [self.locationView maskLayerToView:imageView withFrame:CGRectMake(0, 0, kLocationViewWidth, kLocationViewHeight)];
    [super configLocationMessage];
}
@end
