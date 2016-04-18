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


@interface QYChatsListVC () <UITableViewDelegate, UITableViewDataSource, QYNetworkDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (strong, nonatomic) NSMutableArray *datas;//需要显示的数据列表
@property (strong, nonatomic) NSMutableArray *friends;//好友列表
@property (strong, nonatomic) NSMutableArray *chats;//会话列表
@property (strong, nonatomic) QYChatCell *selectedCell;

@end

@implementation QYChatsListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lastMessageDidChanged:) name:kLastMessageDidChangedNotification object:nil];
    

    _datas = [NSMutableArray array];
    _friends = [NSMutableArray array];
    _chats = [NSMutableArray array];

    
    [_tableView registerNib:[UINib nibWithNibName:@"QYChatCell" bundle:nil] forCellReuseIdentifier:kFriendCellIdentifier];
    
    [QYNetworkManager sharedInstance].delegate = self;
    
    _datas = [self getFriendsListFromDB];
    [_tableView reloadData];
    [self getFriendsListFromNetwork];
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
    //过滤出最后一条消息不为空的用户，加入会话列表
    NSArray *users = [[QYUserStorage sharedInstance] getAllUsersWithSortType:@"lastMessageTime"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.message != NIL"];
    NSArray *results = [users filteredArrayUsingPredicate:predicate];

    return [NSMutableArray arrayWithArray:results];
}

#pragma mark - Events
- (IBAction)segmentControlAction:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        _datas = [self getFriendsListFromDB];
        [_tableView reloadData];
    }else{
        _datas = [self getChatsList];
        [_tableView reloadData];
    }
}

-(void)lastMessageDidChanged:(NSNotification *)notification{
    NSIndexPath *selectedIndexPath = [_tableView indexPathForCell:_selectedCell];
    if (_segmentControl.selectedSegmentIndex == 0) {
        [_tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        if ([_datas containsObject:_selectedCell.user]) {
            [_datas removeObject:_selectedCell.user];
        }
        
        [_datas insertObject:_selectedCell.user atIndex:0];
        [_tableView moveRowAtIndexPath:selectedIndexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
}


#pragma mark - QYNetworkManager Delegate
-(void)didGetFriendsList:(id)responseObject success:(BOOL)success{
    if (success) {
        if (responseObject[kResponseKeySuccess]) {
            NSArray *list = responseObject[kResponseKeyData][@"users"];
//            if (_datas.count == 0) {
//                [[QYUserStorage sharedInstance] addUsers:list];
//            }
        
            NSMutableArray *datasFromNet = [NSMutableArray array];
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //数组转模型
                QYUserInfo *user = [QYUserInfo userWithDictionary:obj];
                [datasFromNet addObject:obj];
                
                //如果本地没有，网络有，则插入到本地
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId MATCHES %@" argumentArray:@[user.userId]];
                NSArray *results = [_datas filteredArrayUsingPredicate:predicate];
                if (results.count <= 0) {
                    [_datas insertObject:user atIndex:idx];
                    [[QYUserStorage sharedInstance] addUser:obj];
                }
                
            }];
            
            //本地用户列表和网络获取的用户列表进行对比，多删少补
            [_datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //如果本地有，网络没有，则删除本地
                QYUserInfo *user = (QYUserInfo *)obj;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userId MATCHES %@" argumentArray:@[user.userId]];
                NSArray *results = [datasFromNet filteredArrayUsingPredicate:predicate];
                if (results.count <= 0) {
                    [[QYUserStorage sharedInstance] deleteUser:user.userId];
                    [_datas removeObject:user];
                }else{
                    __block QYUserInfo *blockUser = user;
                    WEAKSELF
                    [[QYChatManager sharedManager] findConversationWithUser:user.userId withQYFindConversationCompletion:^(AVIMConversation *conversation) {
                        if (conversation) {
                            blockUser.keyedConversation = conversation.keyedConversation;
                        }
                        if (idx == weakSelf.datas.count - 1) {
                            STRONGSELF
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [strongSelf.tableView reloadData];
                            });
                           
                        }
                    }];
                }
            }];
            
            self.titleLabel.text = [NSString stringWithFormat:@"%ld个配对", _datas.count];
            
        }else{
           
        }
    }else{
        [SVProgressHUD showErrorWithStatus:kNetworkFail];
    }
}


#pragma mark - UITableView Delegate & Datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QYChatCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendCellIdentifier forIndexPath:indexPath];
    QYUserInfo *user = _datas[indexPath.row];
    cell.user = user;
    cell.conversation = [[QYChatManager sharedManager] conversationFromKeyedConversation:user.keyedConversation];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QYChatCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    QYChatVC *chatVC = [[QYChatVC alloc] init];
    chatVC.user = cell.user;

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
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
