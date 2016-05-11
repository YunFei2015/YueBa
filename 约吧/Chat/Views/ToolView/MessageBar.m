//
//  ChatBottomView.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/8.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "MessageBar.h"
//#import "FunctionView.h"
#import "FacesView.h"
#import "FaceModel.h"
#import "QYChatManager.h"
#import "QYAudioRecorder.h"
#import "UIView+Extension.h"



@interface MessageBar () <UITextViewDelegate>
@property (strong, nonatomic) __block MessageBar *blockSelf;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;
@property (weak, nonatomic) IBOutlet UIButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *talkBtn;
@property (strong, nonatomic) UIButton *selectedBtn;

@property (strong, nonatomic) FunctionView *functionView;
@property (strong, nonatomic) FacesView *facesView;

@property (nonatomic) NSTimeInterval lastRecordStartTime;
@property (nonatomic) BOOL isCancelled;
@property (nonatomic) BOOL isRecording;

@property (nonatomic) CGFloat textHeight;
@property (strong, nonatomic) UIImage *nilImage;

@end

@implementation MessageBar

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)awakeFromNib{
    _textHeight = 33;
    _selectedFaces = [NSMutableArray array];
    _talkBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _nilImage = [[UIImage alloc] init];
//    [QYAudioRecorder sharedInstance].delegate = self;
}

#pragma mark - events
- (void)keyboardWillShowAction:(NSNotification *)notification{
    NSValue *keyboardBoundsValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.floatValue animations:^{
        [self updateOriginY: kScreenH - kMessageBarHeight - keyboardBoundsValue.CGRectValue.size.height];
        [self.delegate updateTableViewHeight];
//        [NSString stringWithFormat:@""];
    }];
}

- (void)keyboardWillHideAction:(NSNotification *)notification{
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.floatValue animations:^{
        [self updateOriginY: kScreenH - kMessageBarHeight - 0];
        [self.delegate updateTableViewHeight];
    }];
}

- (IBAction)buttonClickAction:(UIButton *)sender {
    
    switch (sender.tag) {
        case MessageBarButtonTypeAdd://按钮为“添加”
        {
            if (!sender.selected) {
                [self showFunctionView];
            }else{
                [self showSystemStandardView];
            }
            
            [self switchKeyboardView];
        }
            break;
            
        case MessageBarButtonTypeFace://按钮为“表情”
        {
            if (!sender.selected) {
                [self showFacesView];
            }else{
                [self showSystemStandardView];
            }
            
            [self switchKeyboardView];
        }
            break;
            
            //正常状态下为“语音”，selected状态下为“键盘”或“发送”
        case MessageBarButtonTypeVoice://按钮为“语音”
        {
            if (!sender.selected) {//按钮为“语音”
                _messageTextView.hidden = YES;
                _talkBtn.hidden = NO;
                [_messageTextView resignFirstResponder];
                [_voiceBtn setTitle:nil forState:UIControlStateSelected];
                [_voiceBtn setImage:[UIImage imageNamed:@"messageBar_Keyboard"] forState:UIControlStateSelected];
            }else{//按钮为“键盘”
                _messageTextView.text = @"";
                [self showSystemStandardView];
                [self switchKeyboardView];
            }
        }
            break;
            
        case MessageBarButtonTypeSend:{//按钮为“发送”
            //设置按钮属性
            [_voiceBtn setTitle:nil forState:UIControlStateSelected];
            [_voiceBtn setImage:[UIImage imageNamed:@"messageBar_Keyboard"] forState:UIControlStateSelected];
            sender.selected = NO;
            sender.tag = MessageBarButtonTypeVoice;
            //发送表情
            [self sendMessage:_messageTextView.text];
            return;
        }
            break;
        default:
            break;
    }
    //之前选中的按钮取消选中
    if (sender.tag != _selectedBtn.tag) {
        _selectedBtn.selected = NO;
    }
    
    //将被选中按钮的选中状态取反
    sender.selected = !sender.selected;
    
    //存储被选中按钮
    _selectedBtn = sender;
}

#pragma mark - microphone related events
//如果两次点击间隔小于1s，则第二次不响应
-(BOOL)audioRecordingShouldBegin{
    CFTimeInterval now = CACurrentMediaTime();
    if (_lastRecordStartTime > 0 && now - _lastRecordStartTime < 1) {
        _lastRecordStartTime = now;
        return NO;
    }
    
    _lastRecordStartTime = now;
    return YES;
}

//开始录音
- (IBAction)touchDownAction:(UIButton *)sender {
    if (![self audioRecordingShouldBegin]) {
        return;
    }
    //录音
//    [[QYAudioRecorder sharedInstance] record];
    self.isCancelled = self.isRecording = NO;
    if ([self.delegate respondsToSelector:@selector(prepareToRecordVoiceWithCompletion:)]) {
        WEAKSELF
        [self.delegate prepareToRecordVoiceWithCompletion:^BOOL{
            STRONGSELF
            if (strongSelf && !strongSelf.isCancelled) {
                strongSelf.isRecording = YES;
                [strongSelf.delegate didStartRecording];
                return YES;
            }else{
                return NO;
            }
        }];
        
    }
}

//结束录音并发送
- (IBAction)touchUpInsideAction:(UIButton *)sender {
    //结束录音
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecording)]) {
            [self.delegate didFinishRecording];
        }
    }else{
        self.isCancelled = YES;
    }
}

//暂停录音
- (IBAction)touchDragExitAction:(UIButton *)sender {
    //当手指从按钮内部拖动到外部，暂停录音
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didPauseRecording)]) {
            [self.delegate didPauseRecording];
        }
    }
    
}

//继续录音
- (IBAction)touchDrageEnterAction:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didContinueRecording)]) {
        [self.delegate didContinueRecording];
    }
}


//取消录音
- (IBAction)touchUpOutsideAction:(UIButton *)sender {
    //结束录音
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecording)]) {
            [self.delegate didCancelRecording];
        }
    }else{
        self.isCancelled = YES;
    }
}


#pragma mark - custom methods
-(void)tipWillShow{
//    _tipLabel.hidden = NO;
//    _messageTextView.backgroundColor = [UIColor clearColor];
}

-(void)tipWillHide{
    _tipLabel.hidden = YES;
    _messageTextView.backgroundColor = [UIColor whiteColor];
}

-(void)showSystemStandardView{
    _messageTextView.inputView = nil;
}

-(void)showFunctionView{
    _messageTextView.inputView = self.functionView;
}

-(void)showFacesView{
    _messageTextView.inputView = self.facesView;
}

-(void)switchKeyboardView{
    _messageTextView.hidden = NO;
    _talkBtn.hidden = YES;
    if (_messageTextView.isFirstResponder) {
        [UIView animateWithDuration:0 animations:^{
        [_messageTextView reloadInputViews];
        }];
    }else{
        [_messageTextView becomeFirstResponder];
    }
}

-(void)removeLastFace{
    //更新视图
    if (_blockSelf.messageTextView.selectedTextRange.empty) {//如果用户没有选择文本
        __block NSString *text = _blockSelf.messageTextView.text;
        FaceModel *face = self.blockSelf.selectedFaces.lastObject;
        if ([text hasSuffix:face.text]) {//如果文本框最后一个是表情文本，则删除表情
            NSRange range = [face.text rangeOfString:face.text];
            NSInteger length = range.length;
            UITextPosition *startPosition = [_blockSelf.messageTextView positionFromPosition:_blockSelf.messageTextView.selectedTextRange.start offset:-length];
            UITextPosition *endPosition = _blockSelf.messageTextView.selectedTextRange.start;
            UITextRange *rangeToDelete = [_blockSelf.messageTextView textRangeFromPosition:startPosition toPosition:endPosition];
            [_blockSelf.messageTextView replaceRange:rangeToDelete withText:@""];
            //更新数据源
            [self.blockSelf.selectedFaces removeLastObject];
        }else{//如果是普通字符，则删除最后一个字符
            [_blockSelf.messageTextView deleteBackward];
        }
    }else{//如果用户选择了文本，则删除被选择文本
        [_blockSelf.messageTextView replaceRange:(UITextRange *)_blockSelf.messageTextView.selectedTextRange withText:@""];
    }
}

-(void)addFace:(FaceModel *)face{
    //更新数据源
    [self.blockSelf.selectedFaces addObject:face];
    //更新视图
    _blockSelf.messageTextView.text = [_blockSelf.messageTextView.text stringByAppendingFormat:@"%@", face.text];
    
    //选择表情后，将按钮属性设置为“发送”
    [_blockSelf.voiceBtn setTitle:@"发送" forState:UIControlStateSelected];
    [_blockSelf.voiceBtn setImage:_nilImage forState:UIControlStateSelected];
    _blockSelf.voiceBtn.selected = YES;
    _blockSelf.voiceBtn.tag = MessageBarButtonTypeSend;
}

-(void)sendMessage:(NSString *)message{
    _messageTextView.text = @"";
    
    NSString *regex = @" *";//任意个空格
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:message]) {//如果文本是由任意个空格组成的，则不允许发送
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"不能发送空白消息" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [controller addAction:action];
        if (self.delegate) {
            UIViewController *vc = (UIViewController *)self.delegate;
            [vc presentViewController:controller animated:YES completion:nil];
            return;
        }
        return;
    }
    
    _voiceBtn.selected = NO;
    _voiceBtn.tag = MessageBarButtonTypeVoice;
    if ([self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:message];
    }
}

#pragma mark - text view delegate
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
//    [self tipWillHide];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
//    [self tipWillShow];
    if (_selectedBtn.tag != MessageBarButtonTypeSend) {
        _selectedBtn.selected = NO;
    }
    
    [self showSystemStandardView];
}

-(void)textViewDidChange:(UITextView *)textView{
    if ([textView hasText]) {
        //如果存在文本，将按钮属性设置为“发送”
        [_voiceBtn setTitle:@"发送" forState:UIControlStateSelected];
        [_voiceBtn setImage:_nilImage forState:UIControlStateSelected];
        _voiceBtn.selected = YES;
        _voiceBtn.tag = MessageBarButtonTypeSend;
    }else{
        [_voiceBtn setTitle:nil forState:UIControlStateSelected];
        [_voiceBtn setImage:[UIImage imageNamed:@"messageBar_Keyboard"] forState:UIControlStateSelected];
        _voiceBtn.selected = NO;
        _voiceBtn.tag = MessageBarButtonTypeVoice;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {//如果点击的回车键，实现发送功能
        //TODO: 检查文本是否为空白消息，空白消息不允许发送
        [self sendMessage:textView.text];
        [self updateMessageBarHeightWithTextView:textView];
        return NO;
    }
    
    [self updateMessageBarHeightWithTextView:textView];
    return YES;
}

-(void)updateMessageBarHeightWithTextView:(UITextView *)textView{
    //根据文本内容调整messageBar的y和height
    CGFloat lastH = textView.contentSize.height;
    if (lastH != _textHeight && lastH <= 200) {
        CGFloat differenceOfHeight = lastH - _textHeight;
        [self updateOriginY: self.frame.origin.y - differenceOfHeight];
        [self updateSizeHeight:self.frame.size.height + differenceOfHeight];
        [self.delegate updateTableViewHeight];
        
        _textHeight = lastH;
    }
    
    //检查文本是否为空
    if ([textView.text isEqualToString: @""]) {
        [self tipWillShow];
    }else{
        [self tipWillHide];
    }
}


#pragma mark - getters
-(MessageBar *)blockSelf{
    if (_blockSelf == nil) {
        _blockSelf = self;
    }
    return _blockSelf;
}

-(FunctionView *)functionView{
    if (_functionView == nil) {
        _functionView = [[NSBundle mainBundle] loadNibNamed:@"FunctionView" owner:nil options:nil][0];
        _functionView.delegate = self.delegate;
    }
    return _functionView;
}

-(FacesView *)facesView{
    if (_facesView == nil) {
        _facesView = [[NSBundle mainBundle] loadNibNamed:@"FacesView" owner:nil options:nil][0];
        __block MessageBar *blockSelf = self;
        _facesView.selectFace = ^(FaceModel *face){
            if (face.category == kFaceCategoryRemove) {
                [blockSelf removeLastFace];
            }else{
                [blockSelf addFace:face];
            }
        };
    }
    return _facesView;
}





@end
