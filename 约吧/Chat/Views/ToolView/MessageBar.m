//
//  ChatBottomView.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/8.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "MessageBar.h"
#import "QYMessageBarButton.h"
#import "FacesView.h"

#import "FaceModel.h"

#import "QYChatManager.h"
#import "QYAudioRecorder.h"

#import "UIView+Extension.h"

@interface MessageBar () <UITextViewDelegate>
@property (strong, nonatomic) __block MessageBar *blockSelf;

@property (weak, nonatomic) IBOutlet QYMessageBarButton *addBtn;
@property (weak, nonatomic) IBOutlet QYMessageBarButton *faceBtn;
@property (weak, nonatomic) IBOutlet QYMessageBarButton *voiceBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *talkBtn;
@property (strong, nonatomic) QYMessageBarButton *selectedBtn;

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
}

#pragma mark - events
- (void)keyboardWillShowAction:(NSNotification *)notification{
    NSValue *keyboardBoundsValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.floatValue animations:^{
        [self updateOriginY: kScreenH - kMessageBarHeight - keyboardBoundsValue.CGRectValue.size.height];
        [self.delegate updateTableViewHeight];
    }];
}

- (void)keyboardWillHideAction:(NSNotification *)notification{
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.floatValue animations:^{
        [self updateOriginY: kScreenH - kMessageBarHeight - 0];
        [self.delegate updateTableViewHeight];
    }];
}

- (IBAction)btnClickAction:(QYMessageBarButton *)sender {
    //如果本次点击的button和上次点击的button不是同一个，则将上一个恢复原状
    if (_selectedBtn.tag != sender.tag) {
        _selectedBtn.showType = _selectedBtn.tag;//
        _selectedBtn = sender;
    }
    
    switch (sender.showType) {
        case kMessageBarButtonTypeAdd://添加
            //如果按钮当前外观是“添加”，则1）点击后变成“键盘”外观；2）弹出自定义功能键盘
        {
            sender.showType = kMessageBarButtonTypeKeyboard;
            [self showFunctionView];
            [self switchKeyboardView];
        }
            break;
            
        case kMessageBarButtonTypeFace://表情
            //如果按钮当前外观是“表情”，则1）点击后变成“键盘”外观；2）弹出自定义标签键盘
        {
            sender.showType = kMessageBarButtonTypeKeyboard;
            [self showFacesView];
            [self switchKeyboardView];
        }
            
            break;
            
        case kMessageBarButtonTypeVoice://语音
            //如果按钮当前外观是“语音”，则1）点击后变成“键盘”外观；2）隐藏文本输入框，显示“按住说话”按钮；3）取消文本输入框的第一响应
        {
            _messageTextView.hidden = YES;
            _talkBtn.hidden = NO;
            [_messageTextView resignFirstResponder];
            sender.showType =  kMessageBarButtonTypeKeyboard;
        }
            
            break;
            
        case kMessageBarButtonTypeSend://发送
            //如果按钮当前外观是“发送”，则1）点击后变成“语音”外观；2）发送文本消息
        {
            sender.showType = kMessageBarButtonTypeVoice;
            [self sendMessage:_messageTextView.text];
        }
            
            break;
            
        case kMessageBarButtonTypeKeyboard://键盘
            //如果按钮当前外观是“键盘”，则1）点击后恢复原状；2）弹出系统键盘
        {
            sender.showType = sender.tag;
            [self showSystemStandardView];
            [self switchKeyboardView];
        }
            
        default:
            break;
    }
    
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
//    self.isCancelled = self.isRecording = NO;
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
-(void)showSystemStandardView{
    //inputView为空时，默认为系统键盘
    _messageTextView.inputView = nil;
}

-(void)showFunctionView{
    //自定义功能键盘
    _messageTextView.inputView = self.functionView;
}

-(void)showFacesView{
    //自定义表情键盘
    _messageTextView.inputView = self.facesView;
}

-(void)switchKeyboardView{
    //弹出键盘时，需要显示文本输入框，隐藏_talkBtn
    _messageTextView.hidden = NO;
    _talkBtn.hidden = YES;
    
    if (_messageTextView.isFirstResponder) {
        //如果文本输入框已经是第一响应者，则reload键盘视图
        [_messageTextView reloadInputViews];
    }else{
        //如果文本输入框不是第一响应者，则将其设为第一响应者
        [_messageTextView becomeFirstResponder];
    }
}

-(void)removeLastFace{
    //更新视图
    if (_blockSelf.messageTextView.selectedTextRange.empty) {//如果用户没有选择文本
        __block NSString *text = _blockSelf.messageTextView.text;
        FaceModel *face = self.blockSelf.selectedFaces.lastObject;
        if (face != nil && [text hasSuffix:face.text]) {//如果文本框最后一个是表情文本，则删除表情
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
    
    if ([_blockSelf.messageTextView.text isEqualToString:@""]) {
        _voiceBtn.showType = kMessageBarButtonTypeVoice;
    }
}

-(void)addFace:(FaceModel *)face{
    //更新数据源
    [self.blockSelf.selectedFaces addObject:face];
    //更新视图
    _blockSelf.messageTextView.text = [_blockSelf.messageTextView.text stringByAppendingFormat:@"%@", face.text];
    
    //选择表情后，将按钮属性设置为“发送”
    _blockSelf.voiceBtn.showType = kMessageBarButtonTypeSend;
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
    
    if ([self.delegate respondsToSelector:@selector(sendMessage:)]) {
        [self.delegate sendMessage:message];
    }
}

#pragma mark - text view delegate
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (_selectedBtn.tag != 3) {
        _selectedBtn.showType = _selectedBtn.tag;
    }
    
    [self showSystemStandardView];
}

-(void)textViewDidChange:(UITextView *)textView{
    if ([textView hasText]) {
        //如果存在文本，将按钮属性设置为“发送”
        _voiceBtn.showType = kMessageBarButtonTypeSend;
    }else{
        _voiceBtn.showType = kMessageBarButtonTypeVoice;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {//如果点击的回车键，实现发送功能
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
