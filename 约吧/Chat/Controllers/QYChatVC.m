//
//  ViewController.m
//  即时通讯练习
//
//  Created by 云菲 on 16/3/1.
//  Copyright © 2016年 云菲. All rights reserved.
//

#import "QYChatVC.h"
#import "AppDelegate.h"

//controllers
#import "QYLocationShareVC.h"
#import "QYLocationMapVC.h"
#import "QYPhotoBrowser.h"

//Models
#import "QYAccount.h"
#import "QYUserInfo.h"

//Views
#import "QYMessageCell.h"
#import "MessageBar.h"
#import "QYVoiceRecordingView.h"


//Managers
#import "QYChatManager.h"
#import "QYAudioRecorder.h"
#import "QYAudioPlayer.h"
#import "QYUserStorage.h"
#import "QYImagesPicker.h"
#import "QYPhotoBrowserTransition.h"

//Others
#import "UIView+Extension.h"
#import "NSDate+Extension.h"
#import <AVOSCloudIM.h>
#import <AVFile.h>
#import <AVPush.h>
#import <AVInstallation.h>
#import <Masonry.h>
#import <AVFileQuery.h>
#import <UIImageView+WebCache.h>

@interface QYChatVC () <UITableViewDelegate, UITableViewDataSource, QYChatManagerDelegate, MessageBarDelegate, QYAudioPlayerDelegate, QYFunctionViewDelegate, QYImagesPickerDelegate, UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) MessageBar *messageBar;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *messagesByGroups;//按日期分组后的消息数组
@property (strong, nonatomic) NSIndexPath *indexPathToScroll;//需要滚动到的位置

@property (strong, nonatomic) NSMutableArray *imageUrls;//图片列表，用于图片轮播
@property (strong, nonatomic) QYPhotoBrowser *photoBrowser;

@property (strong, nonatomic) QYAudioRecorder *voiceRecorder;
@property (strong, nonatomic) QYVoiceRecordingView *voiceRecordingView;//录音动画

@property (strong, nonatomic) AVIMConversation *conversation;//当前会话
@property (strong, nonatomic) QYMessageCell *currentSelectedVoiceCell;//当前选中的语音消息
@property (strong, nonatomic) QYMessageCell *lastSelectedVoiceCell;//上一个选中的语音消息

@end

@implementation QYChatVC
#pragma mark - Getters
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, kScreenH - 64 - kMessageBarHeight) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerNib:[UINib nibWithNibName:kRightMessageCellNib bundle:nil] forCellReuseIdentifier:kRightCellIdentifier];
        [_tableView registerNib:[UINib nibWithNibName:kLeftMessageCellNib bundle:nil] forCellReuseIdentifier:kLeftCellIdentifier];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.tableView addGestureRecognizer:tap];
    }
    return _tableView;
}

-(QYAudioRecorder *)voiceRecorder{
    if (_voiceRecorder == nil) {
        WEAKSELF
        _voiceRecorder = [[QYAudioRecorder alloc] init];
        _voiceRecorder.peakPowerForChannel = ^(float peakPowerForChannel){
            weakSelf.voiceRecordingView.peakPower = peakPowerForChannel;
        };
    }
    return _voiceRecorder;
}

-(QYVoiceRecordingView *)voiceRecordingView{
    if (_voiceRecordingView == nil) {
        _voiceRecordingView = [[NSBundle mainBundle] loadNibNamed:@"QYVoiceRecordingView" owner:nil options:nil][0];
        _voiceRecordingView.center = self.view.center;
        _voiceRecordingView.bounds = CGRectMake(0, 0, kScreenW / 2.f, kScreenH / 4.f);
        _voiceRecordingView.layer.cornerRadius = 10;
    }
    return _voiceRecordingView;
}

-(QYPhotoBrowser *)photoBrowser{
    if (_photoBrowser == nil) {
        QYPhotoBrowser *photoBrowser = [[QYPhotoBrowser alloc] initWithNibName:@"QYPhotoBrowser" bundle:nil];
        photoBrowser.transitioningDelegate = self;
        _photoBrowser = photoBrowser;
    }
    return _photoBrowser;
}

#pragma mark - Life Cycles
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self configNavigationBar];
    [self addMessageBar];
    [self.view addSubview:self.tableView];
    
    _messagesByGroups = [NSMutableArray array];
    _imageUrls = [NSMutableArray array];
    
    
    [QYAudioPlayer sharedInstance].delegate = self;
    [QYImagesPicker sharedInstance].delegate = self;
    
    if (_user.keyedConversation) {
        _conversation = [[QYChatManager sharedManager] conversationFromKeyedConversation:_user.keyedConversation];
        [self queryMessages];
    }else{
        [[QYChatManager sharedManager] findConversationWithUser:_user.userId];
    }
}

-(void)dealloc{
    [[QYUserStorage sharedInstance] updateUserLastMessageAt:_user.lastMessageAt forUserId:_user.userId];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [QYChatManager sharedManager].delegate = self;
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[QYUserStorage sharedInstance] updateUserLastMessageAt:_user.lastMessageAt forUserId:_user.userId];
    
    [QYChatManager sharedManager].delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Custom Methods
-(void)configNavigationBar{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    if (_presented) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }else{
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"messages_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    CGFloat iconW = 40;
    CGFloat iconH = 40;
    CGFloat iconX = 0;
    CGFloat iconY = (44 - iconH) / 2.f;
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconX, iconY, iconW, iconH)];
    
    if (self.user.userPhotos && self.user.userPhotos.count > 0) {
        NSString *url = self.user.userPhotos.firstObject;
        [iconView sd_setImageWithURL:[NSURL URLWithString:url]];
    }else{
        iconView.image = [UIImage imageNamed:@"小丸子"];
    }
    [UIView drawRoundCornerOnImageView:iconView];
    [titleView addSubview:iconView];
    
    CGFloat nameW = 100;
    CGFloat nameH = 20;
    CGFloat nameX = iconX + iconW + 5;
    CGFloat nameY = (44 - nameH) / 2.f;
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, nameW, nameH)];
    name.textColor = [UIColor redColor];
    name.text = _user.name;
    [titleView addSubview:name];
    
    self.navigationItem.titleView = titleView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapAction)];
    [titleView addGestureRecognizer:tap];
}

- (void)addMessageBar{
    _messageBar = [[NSBundle mainBundle] loadNibNamed:@"MessageBar" owner:nil options:nil][0];
    [self.view addSubview:_messageBar];
    _messageBar.delegate = self;
    CGFloat y = kScreenH - kMessageBarHeight;
    _messageBar.frame = CGRectMake(0, y, kScreenW, kMessageBarHeight);
}

-(void)queryMessages{
    //查询聊天记录
    NSArray *messages = [_conversation queryMessagesFromCacheWithLimit:kMessageLimit];
    //将消息分组
    [self divideMessagesIntoGroupsByDate:messages];
    if (_messagesByGroups.count > 0) {
        [self.tableView scrollToRowAtIndexPath:_indexPathToScroll atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)divideMessagesIntoGroupsByDate:(NSArray *)messages{
    //是否为加载更多
    BOOL isMore;
    if (_messagesByGroups.count == 0) {
        isMore = NO;
    }else{
        isMore = YES;
    }
    
    
    //存储新创建的组
    NSMutableArray *groups = [NSMutableArray array];
    
    //新组的索引集合
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    //临时数组，用来存放同一组的消息数据
    NSMutableArray *groupTemp = [NSMutableArray array];
    
    [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //将消息按日期分组
        AVIMTypedMessage *message = (AVIMTypedMessage *)obj;
        
        if (idx == 0) {
            [groupTemp addObject:message];
        }else{
            AVIMTypedMessage *lastMessage = messages[idx - 1];
            
            //判断两条消息是否为同一组
            BOOL isSameGroup = [self isMessage:message inSameGroupAsMessage:lastMessage];
            if (isSameGroup) {//如果两条消息属于同一组，则将该消息添加到组中
                [groupTemp addObject:message];
            }else{//如果两条消息不是同一组的，则将group存储到消息列表中，然后清空group，重新添加消息
                NSMutableArray *group = [NSMutableArray arrayWithArray:groupTemp];
                [groups addObject:group];
                [indexSet addIndex:groups.count - 1];
                
                [groupTemp removeAllObjects];
                [groupTemp addObject:message];
            }
        }
        
        if (idx == messages.count - 1) {
            [groups addObject:[NSMutableArray arrayWithArray:groupTemp]];
            [indexSet addIndex:groups.count - 1];
        }
    }];
    
    //将groups从_messagesByGroups[0]开始插入
    [_messagesByGroups insertObjects:groups atIndexes:indexSet];
    
    //视图需要滚动到的位置，即新数据的最后一条消息
    _indexPathToScroll = [NSIndexPath indexPathForRow:[groups.lastObject count] - 1 inSection:groups.count - 1];

     //刷新UI
    if (isMore) {
        [self.tableView reloadData];
    }else{
        [self.tableView beginUpdates];
        [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];
    }
}

//判断两个消息是否属于同一组（按照时间分组）
-(BOOL)isMessage:(AVIMTypedMessage *)message inSameGroupAsMessage:(AVIMTypedMessage *)lastMessage{
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:lastMessage.sendTimestamp / 1000];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.sendTimestamp / 1000];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar isDate:date inSameDayAsDate:lastDate]) {//如果两条消息是同一天的
        if (message.sendTimestamp / 1000 - lastMessage.sendTimestamp / 1000 < 60 * 2) {//如果与上次时间间隔在2分钟之内，返回YES
            return YES;
        }else{//如果与上次消息间隔超过2分钟，返回NO
            return NO;
        }
    }else{//如果两条消息不是同一天的，返回NO
        return NO;
    }
}

-(void)insertRowWithMessage:(AVIMTypedMessage *)message{
    _user.lastMessageAt = [NSDate dateWithTimeIntervalSince1970:message.sendTimestamp];
    NSIndexPath *indexPath;
    
    AVIMTypedMessage *lastMessage = [_messagesByGroups.lastObject lastObject];
    if ([self isMessage:message inSameGroupAsMessage:lastMessage]) {//将message加入最后一个组
        NSMutableArray *group = _messagesByGroups.lastObject;
        [group addObject:message];
        
        NSInteger section = _messagesByGroups.count - 1;
        NSInteger row = [_messagesByGroups.lastObject count] - 1;
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else{//创建新组
        NSMutableArray *group = [NSMutableArray arrayWithObject:message];
        [_messagesByGroups addObject:group];
    
        NSInteger section = _messagesByGroups.count - 1;
        NSInteger row = [_messagesByGroups.lastObject count] - 1;
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        
        [self.tableView insertSections:[[NSIndexSet alloc] initWithIndex:_messagesByGroups.count - 1] withRowAnimation:UITableViewRowAnimationBottom];
    }
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    
//    WEAKSELF
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        STRONGSELF
//        _user.lastMessageAt = [NSDate date];
//        [weakSelf.messages addObject:message];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messages.count - 1 inSection:0];
//        NSArray *indexPaths = @[indexPath];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [strongSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//            [strongSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            
////            [self updateContentOffsetOfTableView];
////            CGSize size = strongSelf.tableView.contentSize;
////            [strongSelf.tableView setContentOffset:CGPointMake(1, size.height) animated:YES];
//        });
//    });
}

-(void)updateContentOffsetOfTableView{
    if (_tableView.contentSize.height > _tableView.bounds.size.height) {
        [_tableView setContentOffset:CGPointMake(0, _tableView.contentSize.height - _tableView.bounds.size.height) animated:YES];
    }
}

//-(NSString *)getRecorderPath{
//    NSDate *now = [NSDate date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd-hh-mm-ss";
//    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *recorderPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:now]]];
//    return recorderPath;
//}


-(void)getMoreMessages{
    //消息总数
    __block NSInteger count = 0;
    [_messagesByGroups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *group = (NSMutableArray *)obj;
        count += group.count;
    }];
    
    NSArray *messages = [_conversation queryMessagesFromCacheWithLimit:count + kMessageLimit];
    if (messages.count > count) {//如果有新数据，对新数据进行分组
        //将消息分组
        NSArray *newMessages = [messages subarrayWithRange:NSMakeRange(0, kMessageLimit)];
        [self divideMessagesIntoGroupsByDate: newMessages];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView scrollToRowAtIndexPath:_indexPathToScroll atScrollPosition:UITableViewScrollPositionTop animated:NO];
        });
    }
}

#pragma mark - Custom Methods - send messages
-(void)pushMessage:(NSString *)title{
    AVQuery *query = [AVInstallation query];
    [query whereKey:@"userId" equalTo:[@(_user.userId) stringValue]];
    
    //如果没有开启消息预览，则不显示消息内容
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSettingPreview]) {
        title = [NSString stringWithFormat:@"%@发来一条消息", [QYAccount currentAccount].myInfo.name];
    }
    
    NSDictionary *data = @{
                           @"alert":             title, //显示内容
                           @"badge":             @"Increment", //应用图标显示未读消息个数是递增当前值
                           @"sound":             @"sms-received1.caf", //提示音
                           @"content-available": @"1"
                           };
    AVPush *push = [[AVPush alloc] init];
    [push expireAfterTimeInterval:60*60*24*7];//过期时间1 week
    [push setQuery:query];
    [push setData:data];
    [push sendPushInBackground];
}

-(void)sendTextMessageWithContent:(NSString *)message{
    [[QYChatManager sharedManager] sendTextMessage:message withConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@:%@", [QYAccount currentAccount].myInfo.name, message]];
}

-(void)sendImageMessageWithData:(NSData *)data{
    [[QYChatManager sharedManager] sendImageMessageWithData:data withConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@发来一张图片", [QYAccount currentAccount].myInfo.name]];
}

-(void)sendVoiceMessageWithDuration:(NSTimeInterval)duration{
    [[QYChatManager sharedManager] sendVoiceMessageWithDuration:(NSInteger)duration withConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@发来一段语音", [QYAccount currentAccount].myInfo.name]];
}

-(void)sendLocationMessageWithAnnotation:(QYPinAnnotation *)annotation{
    [[QYChatManager sharedManager] sendLocationMessageWithAnnotation:annotation withConversation:_conversation];
    [self pushMessage:[NSString stringWithFormat:@"%@发来位置信息", [QYAccount currentAccount].myInfo.name]];
}

#pragma mark - Custom Methods - audio recorder
-(void)prepareRecordWithCompletion:(QYPrepareRecorderCompletion)completion{
    //    [self.voiceRecorder prepareToRecordWithPath:[self getRecorderPath] completion:completion];
    NSLog(@"准备录音");
    [self.voiceRecorder prepareToRecordWithPath:kAudioPath completion:completion];
}

-(void)startRecord{
    NSLog(@"开始录音");
    WEAKSELF
    //开始录音
    [self.voiceRecorder startToRecordWithStartRecorderCompletion:^{
        [weakSelf.view addSubview:weakSelf.voiceRecordingView];
        weakSelf.voiceRecordingView.recording = YES;
    }];
}

-(void)pauseRecord{
    NSLog(@"暂停录音");
    WEAKSELF
    [self.voiceRecorder pauseToRecordWithPauseRecorderCompletion:^{
        weakSelf.voiceRecordingView.recording = NO;
    }];
}

-(void)continueRecord{
    NSLog(@"继续录音");
    WEAKSELF
    [self.voiceRecorder continueToRecordWithContinueRecordCompletion:^{
        weakSelf.voiceRecordingView.recording = YES;
    }];
}

-(void)cancelRecord{
    NSLog(@"取消录音");
    WEAKSELF
    //取消录音
    [self.voiceRecorder cancelRecordingWithCancelRecorderCompletion:^{
        [weakSelf.voiceRecordingView removeFromSuperview];
    }];
}

-(void)finishRecord{
    NSLog(@"结束录音");
    WEAKSELF
    //发送录音
    [self.voiceRecorder stopRecordingWithStopRecorderCompletion:^(NSTimeInterval duration) {
        [weakSelf.voiceRecordingView removeFromSuperview];
        [weakSelf sendVoiceMessageWithDuration:duration];
    }];
}


#pragma mark - Events
-(void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeftSide animated:YES];
}

-(void)closeAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)titleTapAction{
    [self showUserInfo:_user];
}

//tableView的点击事件
- (void)tapAction:(UITapGestureRecognizer *)sender {
    //重置第一响应
    [_messageBar.messageTextView resignFirstResponder];
    
    //如果点击的位置在某个cell上，处理该cell的数据
    CGPoint point = [sender locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (!indexPath) {
        return;
    }
    _selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //如果点击消息内容，则根据消息类型做相应处理
    if ([_selectedCell isTapedInContent:sender]) {
        switch (_selectedCell.message.mediaType) {
            case kAVIMMessageMediaTypeAudio://播放声音
                [self tapVoiceCellAction];
                break;
                
            case kAVIMMessageMediaTypeImage://放大图片
                [self tapPhotoCellAction];
                break;
                
            case kAVIMMessageMediaTypeLocation://查看地图
                [self tapLocationCellAction];
                break;
                
            default:
                break;
        }
        return;
    }
    
    //如果点击用户头像，显示用户信息
    if ([_selectedCell isTapedInIcon:sender]) {
        [self showUserInfo:_selectedCell.user];
        return;
    }
    
    //如果点击重新发送按钮，则重新发送该消息
    if ([_selectedCell isTapedInStatusView:sender]) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"重新发送" message:@"是否确定重新发送该消息？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //重新发送消息
            [[QYChatManager sharedManager] sendTypedMessage:_selectedCell.message withConversation:_conversation];
        }];
        [controller addAction:action];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:cancel];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void)tapVoiceCellAction{
#if 1
    _currentSelectedVoiceCell = _selectedCell;

    AVIMAudioMessage *message = (AVIMAudioMessage *)_currentSelectedVoiceCell.message;
    [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        NSLog(@"音频数据下载或从本地读取成功");
        [[QYAudioPlayer sharedInstance] playAudioWithData:data];
    }];
    
#else
    
    NSString *voicePath = [[QYDataManager sharedInstance] voiceFilePathForMessageID:message.messageId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:voicePath]) {
        //如果本地存在，播放
        [[QYAudioPlayer sharedInstance] playAudio:voicePath];
        return;
    }
    
    //如果本地不存在，则通过网络下载
    NSLog(@"语音文件本地不存在，开始网络下载……");
    //网络下载
    [[QYNetworkManager sharedInstance] downloadWithUrl:message.file.url withMessageID:message.messageId completion:^(NSString *filePath) {
        NSLog(@"下载成功");
        [[QYAudioPlayer sharedInstance] ,,playAudio:filePath];
    }];
#endif
}

-(void)tapPhotoCellAction{
    [_imageUrls removeAllObjects];

    NSArray *messages = [_conversation queryMessagesFromCacheWithLimit:NSUIntegerMax];
    AVFile *selectedFile = _selectedCell.message.file;
    __block NSInteger currentIndex;

    //将所有image消息过滤出来，并把图片url存储到内存中
    [messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AVIMTypedMessage *message = (AVIMTypedMessage *)obj;
        if (message.mediaType == kAVIMMessageMediaTypeImage) {
            AVFile *file = message.file;
            [_imageUrls addObject:file.localPath];
            
            if ([file.objectId isEqualToString:selectedFile.objectId]) {
                currentIndex = [_imageUrls indexOfObject:file.localPath];
            }
        }
    }];
    
    //打开图片浏览器
    self.photoBrowser.urls = _imageUrls;
    [self.revealViewController presentViewController:self.photoBrowser animated:YES completion:nil];
    self.photoBrowser.currentIndex = currentIndex;
}

-(void)tapLocationCellAction{
    AVIMLocationMessage *message = (AVIMLocationMessage *)_selectedCell.message;
    QYLocationMapVC *mapVC = [[QYLocationMapVC alloc] initWithLocation:[[CLLocation alloc] initWithLatitude:message.latitude longitude:message.longitude] title:message.text];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mapVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

-(void)showUserInfo:(QYUserInfo *)user{
    //TODO: 查看用户信息
}

#pragma mark - UIViewControllerTransitioning Delegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    QYPhotoBrowserTransition *transition = [[QYPhotoBrowserTransition alloc] init];
    return transition;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    QYPhotoBrowserTransition *transition = [[QYPhotoBrowserTransition alloc] init];
    return transition;
}


#pragma mark - QYAudioPlayer Delegate
-(void)didAudioPlayerBeginPlay:(AVAudioPlayer *)player{
    NSLog(@"开始播放");
    //UI
    if (_lastSelectedVoiceCell != _currentSelectedVoiceCell) {
        [_lastSelectedVoiceCell stopVoiceAnimating];
        _lastSelectedVoiceCell = _currentSelectedVoiceCell;
    }
    [_currentSelectedVoiceCell startVoiceAnimating];
}

-(void)didAudioPlayerPausePlay:(AVAudioPlayer *)player{
    NSLog(@"====播放暂停");
    [_currentSelectedVoiceCell stopVoiceAnimating];
}

-(void)didAudioPlayerStopPlay:(AVAudioPlayer *)player{
    NSLog(@"====播放完成");
    player.currentTime = 0;
    [_currentSelectedVoiceCell stopVoiceAnimating];
}

-(void)didAudioPlayerFailedPlay:(AVAudioPlayer *)player{
    player = nil;
    //TODO: 语音文件下载失败，UI提示
}

#pragma mark - Message Bar Delegate - voice methods
-(void)updateTableViewHeight{
    [_tableView updateSizeHeight:_messageBar.frame.origin.y - 64];
    [self updateContentOffsetOfTableView];
}

-(void)sendMessage:(NSString *)message{
    [self sendTextMessageWithContent:message];
}


-(void)prepareToRecordVoiceWithCompletion:(BOOL (^)(void))completion{
    [self prepareRecordWithCompletion:completion];
}

-(void)didStartRecording{
    [self startRecord];
}

-(void)didPauseRecording{
    [self pauseRecord];
}

-(void)didContinueRecording{
    [self continueRecord];
}

-(void)didCancelRecording{
    [self cancelRecord];
}

-(void)didFinishRecording{
    [self finishRecord];
}

#pragma mark - Function View Delegate
-(void)toSelectImages{
    //选择图片
    [[QYImagesPicker sharedInstance] selectImageWithViewController:self];
}

-(void)toTakeAPhoto{
    //拍照
    [[QYImagesPicker sharedInstance] takeAPhotoWithViewController:self];
}

-(void)toShareLocation{
    //共享位置
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    if (app.location) {
        QYLocationShareVC *mapVC = [[QYLocationShareVC alloc] init];
        WEAKSELF
        mapVC.sendLocationToShare = ^(QYPinAnnotation *annotation){
            [weakSelf sendLocationMessageWithAnnotation:annotation];
        };
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:mapVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"请打开定位服务" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"现在打开" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            //跳转到设置界面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
        }];
        [controller addAction:action];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleCancel handler:nil];
        [controller addAction:action1];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}


#pragma mark - QYImagesPicker Delegate
-(void)didFinishSelectImages:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 0);
    [self sendImageMessageWithData:data];
}


#pragma mark - Chat Manager Delegate
-(void)didFindConversation:(AVIMConversation *)conversation succeeded:(BOOL)succeeded{
    if (succeeded) {
        _conversation = conversation;
        //开启静音，不再接收此对话的离线推送
        [_conversation muteWithCallback:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
        
        //查询历史消息
        [self queryMessages];
        
        _user.keyedConversation = _conversation.keyedConversation;
        //本地缓存
        [[QYUserStorage sharedInstance] updateUserConversation:conversation.keyedConversation forUserId:_user.userId];

    }
}

-(void)willSendMessage:(AVIMTypedMessage *)message{
    //将文件上传至云端
    if (message.file) {
        [message.file saveInBackground];
    }

    message.sendTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    //如果不是重发的消息，则直接插入
    if (_selectedCell.message != message) {
        [self insertRowWithMessage:message];
    }
}

-(void)didSendMessage:(AVIMTypedMessage *)message succeeded:(BOOL)succeeded{
    if (_selectedCell.message == message) {//如果是重发的消息，发送成功需要把失败图片隐藏，reload一下即可
        if (succeeded) {
            NSIndexPath *indexPath = [_tableView indexPathForCell:_selectedCell];
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else{//不是重发的消息，发送失败需要刷新界面，显示失败
        if (!succeeded) {
            NSInteger section = self.messagesByGroups.count - 1;//刚刚发送的消息，一定是在最后一组
            NSInteger row = [self.messagesByGroups.lastObject indexOfObject:message];//刚刚发送的消息，不一定是最后一条，有可能同时有接收到的新消息
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_messagesByGroups.lastObject count] - 1 inSection:_messagesByGroups.count - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

-(void)didReceiveMessage:(AVIMTypedMessage *)message inConversation:(AVIMConversation *)conversation{
    if ([conversation.conversationId isEqualToString:_conversation.conversationId]) {
        //下载富文本附件
        [message.file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
                return;
            }
        }];
        _user.messageStatus = QYMessageStatusDefault;
        [[QYUserStorage sharedInstance] updateUserMessageStatus:_user.messageStatus forUserId:_user.userId];
        [self insertRowWithMessage:message];
    }
}

#pragma mark - Table View Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _messagesByGroups.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
//    titleView.backgroundColor = [UIColor clearColor];
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:12];
    titleLab.backgroundColor = [UIColor whiteColor];
    titleLab.alpha = 0.5;
    titleLab.layer.cornerRadius = 5;
    titleLab.layer.masksToBounds = YES;
    titleLab.preferredMaxLayoutWidth = 100;
    
    AVIMTypedMessage *firstMessage = _messagesByGroups[section][0];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:firstMessage.sendTimestamp / 1000];
    NSString *time = [date stringFromDateWithFormatter:@"HH:mm"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar isDateInToday:date]) {
        titleLab.text = time;
    }else if ([calendar isDateInYesterday:date]){
        titleLab.text = [NSString stringWithFormat:@"昨天 %@", time];
    }else{//TODO: 昨天之前的消息时间显示
        titleLab.text = [NSString stringWithFormat:@"前天 %@", time];
    }
    
//    [titleView addSubview:titleLab];
//    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(titleView);
//        make.height.equalTo(titleView);
//    }];
    return titleLab;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *messages = _messagesByGroups[section];
    return messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AVIMTypedMessage *message = _messagesByGroups[indexPath.section][indexPath.row];
    QYMessageCell *cell;
    
    switch (message.status) {
        case AVIMMessageStatusNone://无
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
        
        case AVIMMessageStatusSending://发送中
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
            
        case AVIMMessageStatusSent://已发送
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
            
        case AVIMMessageStatusDelivered://已接收
            cell = [tableView dequeueReusableCellWithIdentifier:kLeftCellIdentifier forIndexPath:indexPath];
            break;
            
        case AVIMMessageStatusFailed://发送失败
            cell = [tableView dequeueReusableCellWithIdentifier:kRightCellIdentifier forIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    if ([cell.reuseIdentifier isEqualToString:kRightCellIdentifier]) {
        cell.user = self.user;
    }
    
    if ([cell.reuseIdentifier isEqualToString:kLeftCellIdentifier]) {
        cell.user = [QYAccount currentAccount].myInfo;
    }
    
    cell.message = message;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AVIMTypedMessage *message = _messagesByGroups[indexPath.section][indexPath.row];
    QYRightMessageCell *cell;
    cell = [[NSBundle mainBundle] loadNibNamed:@"QYRightMessageCell" owner:nil options:nil][0];
    cell.message = message;
    
    return [cell heightWithMessage:message];
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentOffset.y < 0) {
        [self getMoreMessages];//获取20条历史消息
    }
}
@end
