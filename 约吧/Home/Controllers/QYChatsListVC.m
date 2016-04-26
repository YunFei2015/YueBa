//
//  QYMessagesListVC.m
//  约吧
//
//  Created by 云菲 on 4/6/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYChatsListVC.h"

//models
#import "QYAccount.h"
#import "QYUserInfo.h"

//views
#import "QYChatCell.h"

//controllers
#import "QYChatVC.h"

//protocols
#import "QYNetworkManager.h"
#import "QYUserStorage.h"
#import "QYChatManager.h"

#import <AVIMConversation.h>


@interface QYChatsListVC () <UITableViewDelegate, UITableViewDataSource, QYNetworkDelegate, QYChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (strong, nonatomic) NSMutableArray *datas;//需要显示的数据列表
@property (strong, nonatomic) QYChatCell *selectedCell;

@end

@implementation QYChatsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _datas = [NSMutableArray array];
    
    [_tableView registerNib:[UINib nibWithNibName:@"QYChatCell" bundle:nil] forCellReuseIdentifier:kFriendCellIdentifier];
    
    [QYNetworkManager sharedInstance].delegate = self;
    
    //先获取会话列表，如果会话列表不为空，则显示会话界面；反之，获取好友列表，并显示好友界面
    _datas = [self getChatsList];
    if (_datas.count > 0) {
        _segmentControl.selectedSegmentIndex = 1;
        [self displayChatsList];
    }else{
        _datas = [self getFriendsListFromDB];
        [self displayFriendsList];
    }
    
    [self getFriendsListFromNetwork];
}

-(void)viewWillAppear:(BOOL)animated{
    [QYChatManager sharedManager].delegate = self;
    
    [super viewWillAppear:animated];
}

#pragma mark - Custom Methods
//从本地获取用户列表
-(NSMutableArray *)getFriendsListFromDB{
    NSArray *friends = [[QYUserStorage sharedInstance] getAllUsersWithSortType:@"matchTime"];
    return [NSMutableArray arrayWithArray:friends];
}

//从网络获取用户列表
-(void)getFriendsListFromNetwork{
    NSDictionary *params = [[QYAccount currentAccount] accountParameters];
    [[QYNetworkManager sharedInstance] getFriendsListWithParameters:params];
}

//获取会话列表
-(NSMutableArray *)getChatsList{
    NSArray *friends = [[QYUserStorage sharedInstance] getAllUsersWithSortType:@"lastMessageAt"];
    return [NSMutableArray arrayWithArray:friends];
}


-(void)displayFriendsList{
    _datas = [self getFriendsListFromDB];
    self.titleLabel.text = [NSString stringWithFormat:@"%ld个配对", _datas.count];
    [_tableView reloadData];
}

-(void)displayChatsList{
    _datas = [self getChatsList];
    self.titleLabel.text = [NSString stringWithFormat:@"%ld个聊天", _datas.count];
    [_tableView reloadData];
}

//更新我和好友的最后一条消息
-(void)reloadLastMessage:(AVIMTypedMessage *)message forUser:(QYUserInfo *)user{
    //把最新会话置顶
    //从当前列表中查找用户
    NSArray *results = [_datas filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.userId MATCHES %@", user.userId]];
    if (results.count <= 0) {//如果当前列表没有该用户，则从数据库中获取到，并插入到当前列表的顶部
        [_datas insertObject:user atIndex:0];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    }else{//如果在当前列表查找到该用户，则将该用户移到顶部
        NSInteger index = [_datas indexOfObject:results.firstObject];
        [_datas replaceObjectAtIndex:index withObject:user];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_datas exchangeObjectAtIndex:0 withObjectAtIndex:indexPath.row];
        [_tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    QYChatCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.message = [self contentOfMessage:message];
    cell.status = user.messageStatus;
}

//按照消息类型返回对应内容
-(NSString *)contentOfMessage:(AVIMTypedMessage *)message{
    NSString *content = [NSString string];
    switch (message.mediaType) {
        case kAVIMMessageMediaTypeText:
            content = message.text;
            break;
            
        case kAVIMMessageMediaTypeAudio:
            content = @"[语音]";
            break;
            
        case kAVIMMessageMediaTypeImage:
            content = @"[图片]";
            break;
            
        case kAVIMMessageMediaTypeLocation:
            content = @"[位置]";
            break;
            
        default:
            break;
    }
    return content;
}


#pragma mark - Events
- (IBAction)segmentControlAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self displayFriendsList];
    }else{
        [self displayChatsList];
    }
}


#pragma mark - QYNetworkManager Delegate
-(void)didGetFriendsList:(id)responseObject success:(BOOL)success{
    if (success) {
        if (responseObject[kResponseKeySuccess]) {
            NSArray *list = responseObject[kResponseKeyData][@"users"];
            NSMutableArray *friends = [self getFriendsListFromDB];
            if (friends.count == 0) {
                [[QYUserStorage sharedInstance] addUsers:list];
            }else{
                NSMutableArray *datasFromNet = [NSMutableArray array];
                //对网络数据进行遍历
                [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //数组转模型
                    QYUserInfo *user = [QYUserInfo userWithDictionary:obj];
                    [datasFromNet addObject:obj];
                    
                    //如果网络有，本地没有，则插入到本地
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId MATCHES %@" argumentArray:@[user.userId]];
                    NSArray *results = [_datas filteredArrayUsingPredicate:predicate];
                    if (results.count <= 0) {
//                        [_datas insertObject:user atIndex:idx];
                        [[QYUserStorage sharedInstance] addUser:obj];
                    }
                    
                }];
                
                //对本地用户列表进行遍历
                [_datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //如果本地有，网络没有，则删除本地
                    QYUserInfo *user = (QYUserInfo *)obj;
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId MATCHES %@" argumentArray:@[user.userId]];
                    NSArray *results = [datasFromNet filteredArrayUsingPredicate:predicate];
                    if (results.count <= 0) {
                        [[QYUserStorage sharedInstance] deleteUser:user.userId];
//                        [_datas removeObject:user];
                    }
                }];
            }
        
            if (_segmentControl.selectedSegmentIndex == 0) {
                [self displayFriendsList];
            }
            
        }else{
           
        }
    }else{
        [SVProgressHUD showErrorWithStatus:kNetworkFail];
    }
}

#pragma mark - QYChatManager Delegate
-(void)didReceiveMessage:(AVIMTypedMessage *)message inConversation:(AVIMConversation *)conversation{
    //TODO: 新添加的好友，第一次发消息给我的情况
    [conversation.members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![[QYAccount currentAccount].userId isEqualToString:obj]) {
            NSString *userId = (NSString *)obj;
            QYUserInfo *user = [[QYUserStorage sharedInstance] getUserForId:userId];
            
            //如果当前在会话界面，则更新UI
            if (_segmentControl.selectedSegmentIndex == 1) {
                [self reloadLastMessage:(AVIMTypedMessage *)message forUser:user];
            }
            *stop = TRUE;
        }
    }];
    
    
}

#pragma mark - UITableView Delegate & Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QYChatCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier forIndexPath:indexPath];
    QYUserInfo *user = _datas[indexPath.row];
    cell.user = user;
    if (_segmentControl.selectedSegmentIndex == 0) {
//        cell.conversation = nil;
        cell.message = nil;
    }else{
        AVIMConversation *conversation = [[QYChatManager sharedManager] conversationFromKeyedConversation:user.keyedConversation];
        AVIMTypedMessage *message = [conversation queryMessagesFromCacheWithLimit:1][0];
        cell.message = [self contentOfMessage:message];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QYChatCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.user.messageStatus = QYMessageStatusDefault;
    cell.status = QYMessageStatusDefault;
    [[QYUserStorage sharedInstance] updateUserMessageStatus:cell.user.messageStatus forUserId:cell.user.userId];
    
    QYChatVC *chatVC = [[QYChatVC alloc] init];
    chatVC.user = cell.user;
    //当最后一条消息改变时，调用block块，刷新视图
    chatVC.lastMessageDidChanged = ^(AVIMConversation *conversation){
        if (_segmentControl.selectedSegmentIndex == 1) {
            //找到需要更新UI的用户下标
            _datas = [self getChatsList];
            [tableView reloadData];
        }
    };

    [self.navigationController pushViewController:chatVC animated:YES];
    [self.revealViewController setFrontViewPosition:FrontViewPositionLeftSideMost animated:YES];
    
    _selectedCell = cell;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"解除匹配" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        QYUserInfo *user = _datas[indexPath.row];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"解除匹配" message:[NSString stringWithFormat:@"确定要与%@解除匹配吗？", user.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [_datas removeObject: user];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //数据库删除数据
            [[QYUserStorage sharedInstance] deleteUser:user.userId];
            
            //TODO: 服务器删除数据
        }];
        [controller addAction:action1];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QYChatCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setEditing:NO animated:YES];
        }];
        [controller addAction:action2];
        [self presentViewController:controller animated:YES completion:nil];
    }];
    
    
    UITableViewRowAction *clearAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"清空聊天记录" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        QYUserInfo *user = _datas[indexPath.row];
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"清空聊天记录" message:[NSString stringWithFormat:@"确定要清空与%@的聊天记录吗？", user.name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"还没实现" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //TODO: 清空聊天记录
            
            
            //数据源删除数据
            
            //界面删除
            
            //数据库删除
            
            //服务器删除
        }];
        [controller addAction:action1];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            QYChatCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setEditing:NO animated:YES];
        }];
        [controller addAction:action2];
        [self presentViewController:controller animated:YES completion:nil];
    }];
     
    
    return @[deleteAction, clearAction];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
