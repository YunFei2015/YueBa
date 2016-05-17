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
#import <AVIMFileMessage.h>
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

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;//用户头像

/**
 *  文本消息控件
 */
@property (weak, nonatomic) IBOutlet UIView *messageView;//文本、语音消息共用一个父视图
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *messageLab;//文本、语音消息共用一个label

/**
 *  语音消息控件
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceAnimatingViewWidthConstraint;

/**
 *  图片消息控件
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoViewWidthConstraint;

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
    
    _messageViewWidthConstraint.constant = 0;
    _messageViewHeightConstraint.constant = 0;
    
    _photoViewHeightConstraint.constant = 0;
    _photoViewWidthConstraint.constant = 0;
    
    _locationViewHeightConstraint.constant = 0;
    self.messageLab.textAlignment = NSTextAlignmentRight;
    
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
}

#pragma mark - Custom methods
////计算cell的高度
//-(CGFloat)heightWithMessage:(AVIMMessage *)message{
//    return _messageViewHeightConstraint.constant + _photoViewHeightConstraint.constant + _locationViewHeightConstraint.constant + 10 + 10 + 1;
//}


//填充文本内容
-(void)configTextMessage{
    self.messageType = kMessageTypeText;
    _messageLab.attributedText = [NSString faceAttributeTextWithMessage:_message.text withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} faceSize:20];
    [self calculateLayoutWith:_messageLab.attributedText];
}

//填充语音内容
-(void)configAudioMessage{
    self.messageType = kMessageTypeVoice;
    [self calculateLayoutWith:_messageLab.attributedText];
    
    AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)_message;
    _voiceAnimatingImageView.animationDuration = 1;
    _voiceAnimatingImageView.animationRepeatCount = audioMessage.duration;
    _voiceAnimatingViewWidthConstraint.constant = _voiceAnimatingImageView.image.size.width;
}

//填充照片内容
-(void)configPhotoMessage{
    self.messageType = kMessageTypePhoto;
    CGFloat width = [self.message.file.metaData[@"width"] floatValue];
    CGFloat height = [self.message.file.metaData[@"height"] floatValue];
    
    if (width == 0 || height == 0) {
        self.photoViewWidthConstraint.constant = kPhotoWidth;
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
        self.photoViewWidthConstraint.constant = width;
    }
    
    [self.message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            self.photoImageView.image = image;
        }
    }];
}

//填充位置内容
-(void)configLocationMessage{
    self.messageType = kMessageTypeLocation;
    _locationViewHeightConstraint.constant = kLocationViewHeight;
    
    _locationNameLabel.text = _message.text;
}

-(void)calculateLayoutWith:(NSAttributedString *)text{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(kMessageMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _messageViewHeightConstraint.constant = ceilf(rect.size.height) + 10 + 10;
    
    //根据文本内容调整文本消息布局
    if (_message.mediaType == kAVIMMessageMediaTypeText) {
        _messageViewWidthConstraint.constant = ceilf(rect.size.width) + _voiceAnimatingViewWidthConstraint.constant + 10 + 20;
    }
    
    //根据时长调整语音消息布局
    if (_message.mediaType == kAVIMMessageMediaTypeAudio) {
        NSInteger duration = [text.string integerValue];
        if (duration >= 30) {
            _messageViewWidthConstraint.constant = kScreenW / 2.f + _voiceAnimatingViewWidthConstraint.constant + 10 + 20;
        }else{
            _messageViewWidthConstraint.constant = audioMinWidth + widthPerSec * duration + _voiceAnimatingViewWidthConstraint.constant + 10 + 20;
        }
    }
}


//判断手指是否触摸在有效区域
-(BOOL)isTapedInContent:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.contentView];
    NSLog(@"%f,%f", point.x, point.y);
    
    UIView *view;
    switch (_message.mediaType) {
        case kAVIMMessageMediaTypeText:
            view = _messageView;
            break;
            
        case kAVIMMessageMediaTypeAudio:
            view = _messageView;
            break;
            
        case kAVIMMessageMediaTypeImage:
            view = _photoImageView;
            break;
            
        case kAVIMMessageMediaTypeLocation:
            view = _locationView;
            break;
            
        default:
            break;
    }
    if (CGRectContainsPoint(view.frame, point)) {
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
    CGFloat width = self.photoViewWidthConstraint.constant;
    NSLog(@"width = %f, height = %f", width,height);
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
//    //将图片裁剪成气泡样式
    CGFloat height = self.photoViewHeightConstraint.constant;
    CGFloat width = self.photoViewWidthConstraint.constant;
    NSLog(@"width = %f, height = %f", width,height);
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
