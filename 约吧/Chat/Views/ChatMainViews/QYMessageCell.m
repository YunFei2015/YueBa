//
//  MessageTableViewCell.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/4.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYMessageCell.h"
#import "FaceModel.h"

#import <AVFile.h>
#import <AVIMAudioMessage.h>
#import <AVIMFileMessage.h>
#import <AVIMLocationMessage.h>
#import <AVIMImageMessage.h>
#import <UIImageView+WebCache.h>

#import "UIView+Extension.h"
#import "NSString+Extension.h"


#define kLocationViewWidth kScreenW * 0.75 //位置视图宽度
#define kLocationViewHeight 100

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
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
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
@synthesize message = _message;
- (void)awakeFromNib {
    // Initialization code
    _messageLab.preferredMaxLayoutWidth = kMessageMaxWidth;
}

#pragma mark - setters
-(void)setMessage:(AVIMTypedMessage *)message{
    if (!message) {
        return;
    }
    [self resumeOriginalLayout];
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

#pragma mark - custom methods
////计算cell的高度
//-(CGFloat)heightWithMessage:(AVIMMessage *)message{
//    return _messageViewHeightConstraint.constant + _photoViewHeightConstraint.constant + _locationViewHeightConstraint.constant + 10 + 10 + 1;
//}

//当cell被复用时，要把之前的约束恢复初始值
-(void)resumeOriginalLayout{
    _voiceAnimatingViewWidthConstraint.constant = 0;
    _messageViewHeightConstraint.constant = 0;
    _photoViewHeightConstraint.constant = 0;
    _locationViewHeightConstraint.constant = 0;
}

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
    _voiceAnimatingImageView.animationRepeatCount = ceilf(audioMessage.duration);
    _voiceAnimatingViewWidthConstraint.constant = _voiceAnimatingImageView.image.size.width;
}

//填充照片内容
-(void)configPhotoMessage{
    self.messageType = kMessageTypePhoto;
    _photoViewHeightConstraint.constant = kPhotoHeight;
    
//    [_message.file getThumbnail:YES width:kScreenW / 2.f height:kPhotoHeight withBlock:^(UIImage *image, NSError *error) {
//         _photoImageView.image = image;
//    }];
    [_message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _photoImageView.image = [UIImage imageWithData:data];
    }];
}

//填充位置内容
-(void)configLocationMessage{
    self.messageType = kMessageTypeLocation;
    _locationViewHeightConstraint.constant = kLocationViewHeight;
    
    _locationNameLabel.text = _message.text;
}

-(void)calculateLayoutWith:(NSAttributedString *)text{
    //根据文本内容调整布局
    CGRect rect = [text boundingRectWithSize:CGSizeMake(kMessageMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    _messageViewWidthConstraint.constant = ceilf(rect.size.width) + _voiceAnimatingViewWidthConstraint.constant + 10 + 20;
    _messageViewHeightConstraint.constant = ceilf(rect.size.height) + 10 + 10;
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

-(void)startVoiceAnimating{
    [_voiceAnimatingImageView startAnimating];
}

-(void)stopVoiceAnimating{
    [_voiceAnimatingImageView stopAnimating];
}
@end


#pragma mark - LeftMessageTableViewCell
@implementation QYLeftMessageCell
-(void)configAudioMessage{
    AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)self.message;
    NSString *text = [NSString stringWithFormat:@"          %.f\''", audioMessage.duration];
    self.messageLab.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    self.voiceAnimatingImageView.animationImages = @[
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
                                                 [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"]];
    
    [super configAudioMessage];
}

-(void)configPhotoMessage{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_gray"]];
    //将图片裁剪成气泡样式
    [self.photoImageView maskLayerToView:imageView withFrame:CGRectMake(0, 0, kPhotoWidth, kPhotoHeight)];
    [super configPhotoMessage];
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
-(void)configAudioMessage{
    AVIMAudioMessage *audioMessage = (AVIMAudioMessage *)self.message;
    NSString *text = [NSString stringWithFormat:@"%.f\''          ", ceilf(audioMessage.duration)];
    self.messageLab.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    self.voiceAnimatingImageView.animationImages = @[
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying000"],
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
                                                 [UIImage imageNamed:@"SenderVoiceNodePlaying003"]];
    
    [super configAudioMessage];
}

-(void)configPhotoMessage{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_red"]];
    //将图片裁剪成气泡样式
    [self.photoImageView maskLayerToView:imageView withFrame:CGRectMake(0, 0, kPhotoWidth, kPhotoHeight)];
    [super configPhotoMessage];
}

-(void)configLocationMessage{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bubble_red"]];
    //将图片裁剪成气泡样式
    [self.locationView maskLayerToView:imageView withFrame:CGRectMake(0, 0, kLocationViewWidth, kLocationViewHeight)];
    [super configLocationMessage];
}
@end
