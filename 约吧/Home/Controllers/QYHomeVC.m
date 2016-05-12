//
//  ViewController.m
//  01-配配
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "QYHomeVC.h"
#import "AppDelegate.h"

//Models
#import "QYUserInfo.h"

//Views
#import "QYHomeSearchView.h"
#import "QYHomeAnimationView.h"

//protocols
#import "QYLocationManager.h"
#import "QYUserStorage.h"

//category
#import "UIViewController+Extension.h"

//vendors
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Radar/BMKRadarResult.h>
#import <AVPush.h>
#import <AVInstallation.h>

typedef void(^markCompletionBlock)(void);

@interface QYHomeVC () <QYNetworkDelegate, BMKMapViewDelegate, DanimationPro, QYRadarDelegate>
@property (strong, nonatomic) AppDelegate *appDelegate;

//Views
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *dislikeBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *detailBtn;
@property (weak, nonatomic) IBOutlet QYHomeAnimationView *animationView;
@property (strong, nonatomic) QYHomeSearchView *searchView;

//data
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *userId;//当前用户Id
@property (strong, atomic) NSMutableArray *nearbyUsers;//每次雷达检索到的用户

@property (strong, nonatomic) markCompletionBlock markCompletion;



@end

@implementation QYHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configSubView];
    
    [QYNetworkManager sharedInstance].delegate = self;
    [QYLocationManager sharedInstance].radarDelegate = self;

    _nearbyUsers = self.appDelegate.nearbyUsers;
    if (_nearbyUsers.count > 0) {
        self.animationView.users = _nearbyUsers;
        [self.searchView removeFromSuperview];
    }else{
        if (self.appDelegate.location) {
            _location = self.appDelegate.location;
            self.searchView.mapView.centerCoordinate = _location.coordinate;
            [self searchNearbyUsersWithStatus:YES];
        }
    }
}

#pragma mark - Custom Methods
-(void)configSubView{
    _searchView = [[QYHomeSearchView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, kScreenH)];
    [self.view addSubview:_searchView];
    
    _dislikeBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _dislikeBtn.layer.borderWidth = 1;
    _dislikeBtn.layer.cornerRadius = _dislikeBtn.frame.size.width / 2.f;;
    
    _likeBtn.layer.borderColor = [UIColor redColor].CGColor;
    _likeBtn.layer.borderWidth = 1;
    _likeBtn.layer.cornerRadius = _likeBtn.frame.size.width / 2.f;;
    
    _detailBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _detailBtn.layer.borderWidth = 1;
    _detailBtn.layer.cornerRadius = _detailBtn.frame.size.width / 2.f;
    
    _animationView.delegate = self;
    
    //侧滑结构
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    [self.leftBarButtonItem setTarget: self.revealViewController];
    [self.leftBarButtonItem setAction: @selector(revealToggle:)];
    [self.rightBarButtonItem setTarget: self.revealViewController];
    [self.rightBarButtonItem setAction: @selector(rightRevealToggle:)];
}

-(void)searchNearbyUsersWithStatus:(BOOL)searchStatus{
    self.searchView.hasMore = searchStatus;
    [[QYLocationManager sharedInstance] searchNearByUsersWithLocation:_location.coordinate];
}

#pragma mark - Events
//不喜欢当前显示的用户
- (IBAction)unlikeAction:(UIButton *)sender {
    [_animationView selectLikeOnce:NO];
}

//喜欢当前显示的用户
- (IBAction)likeAction:(UIButton *)sender {
    [_animationView selectLikeOnce:YES];
}

//显示用户详情
- (IBAction)showDetail:(UIButton *)sender {
    UIStoryboard *sbProfile = [UIStoryboard storyboardWithName:@"QYProfile" bundle:nil];
    UIViewController *vcInitial = [sbProfile instantiateInitialViewController];
    [self.navigationController pushViewController:vcInitial animated:YES];
}


#pragma mark - DanimationPro
-(void)ChangeValueType:(BOOL)type{
    //放大
    if (type) {
        [UIView animateWithDuration:1 animations:^{
            _likeBtn.transform=CGAffineTransformMakeScale(2, 2);
            _likeBtn.transform=CGAffineTransformIdentity;
        }];
    }else{
        [ UIView animateWithDuration:1 animations:^{
            _dislikeBtn.transform=CGAffineTransformMakeScale(2, 2);
            _dislikeBtn.transform=CGAffineTransformIdentity;
        }];
    }
}
-(void)FinishendValueType{
    //恢复正常
    [UIView animateWithDuration:.2 animations:^{
        _likeBtn.transform=CGAffineTransformIdentity;
        _dislikeBtn.transform=CGAffineTransformIdentity;
    }];
}

-(void)markUser:(QYUserInfo *)user asLike:(BOOL)isLike{
    [QYNetworkManager sharedInstance].delegate = self;
    //标记成功后的block回调
    WEAKSELF
    _markCompletion = ^(){
        //存入数据库
        NSDictionary *userDict = @{kUserId : @(user.userId),
                                   kUserName : user.name,
                                   kUserPhotos : @[user.iconUrl]};
        [[QYUserStorage sharedInstance] addUser:userDict];
        
        //向对方发送推送消息
        AVQuery *query = [AVInstallation query];
        [query whereKey:@"userId" equalTo:@(user.userId)];
        
        NSDictionary *data = @{
                               @"alert":             @"你有新朋友了！", //显示内容
                               @"badge":             @"Increment", //应用图标显示未读消息个数是递增当前值
                               @"sound":             @"sms-received1.caf", //提示音
                               @"content-available": @"1",
                               kUserPhotos:         @[user.iconUrl], //用户头像url
                               kUserName:            user.name //用户姓名
                               };
        AVPush *push = [[AVPush alloc] init];
        [push expireAfterTimeInterval:60 * 60 * 24 * 7];//过期时间1 week，如果用户网络不可用，保证在网络恢复时还能收到通知
        [push setQuery:query];
        [push setData:data];
        [push sendPushInBackground];
        
        //弹出新好友界面
        [weakSelf presentToNewFriendControllerForUser:user];
    };
    
    //向服务器发送数据
    NSMutableDictionary *params = [[QYAccount currentAccount] accountParameters];
    [params setValue:@(user.userId) forKey:@"friendId"];
    [params setValue:@(isLike) forKey:@"like"];
    [[QYNetworkManager sharedInstance] markUserRelationshipWithParameters:params];
    
    //UI
    [_nearbyUsers removeObject:user];
    if (_nearbyUsers.count == 0) {
        [self.view addSubview:self.searchView];
        //继续查找附近用户
        [self searchNearbyUsersWithStatus:NO];
    }
}

#pragma mark - QYLocationManager Delegate
//雷达扫描附近使用该app的用户
-(void)didFinishSearchNearbyUsers:(BMKRadarNearbyResult *)result success:(BOOL)success{
    if (success) {
        if (result) {
            NSMutableArray *ids = [NSMutableArray array];
            NSLog(@"扫描到%ld个用户", result.infoList.count);
            [result.infoList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BMKRadarNearbyInfo *nearbyInfo = (BMKRadarNearbyInfo *)obj;
                [ids addObject:nearbyInfo.userId];
            }];
            //TODO: 请求用户信息
            NSMutableDictionary *parameters = [[QYAccount currentAccount] accountParameters];
            NSString *idstr = [ids componentsJoinedByString:@","];
            [parameters setObject:idstr forKey:@"userIds"];
            
            NSString *sex = [[NSUserDefaults standardUserDefaults] objectForKey:kFilterKeySex];
            if (![sex isEqualToString:@"FM"]) {
                [parameters setObject:sex forKey:@"gender"];
            }
            
            [[QYNetworkManager sharedInstance] getUsersWithParameters:parameters];
            
        }else{
            [self searchNearbyUsersWithStatus:NO];
            NSLog(@"附近没有更多的人了...");
        }
    }else{
        [SVProgressHUD showErrorWithStatus:kNetworkFail];
    }
}

#pragma mark - QYNetworkManager Delegate
//获取周围用户列表
-(void)didGetUsers:(id)responseObject success:(BOOL)success{
    if (success) {
        [responseObject[kResponseKeyData] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            QYUserInfo *userInfo = [QYUserInfo userWithDictionary:obj];
            [_nearbyUsers addObject:userInfo];
        }];
        
        NSLog(@"有%ld个符合条件的用户", _nearbyUsers.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            _animationView.users = _nearbyUsers;
            [_searchView removeFromSuperview];
        });
    }
}

//标记用户关系(喜欢 or 不喜欢)
-(void)didMarkUserRelationship:(id)responseObject success:(BOOL)success{
    if (success) {
        NSDictionary *dataDict = responseObject[kResponseKeyData];
        
        BOOL isFriend = [dataDict[@"friend"] boolValue];
        if (isFriend) {//如果双方互相喜欢
            _markCompletion();
        }
        
        NSLog(@"标记成功");
    }else{
        NSLog(@"标记失败");
    }
}


#pragma mark - Getters
-(AppDelegate *)appDelegate{
    if (_appDelegate == nil) {
        _appDelegate = [UIApplication sharedApplication].delegate;
        WEAKSELF
        _appDelegate.locationSuccess = ^(CLLocation *location){
                //如果homeVC不知道当前位置，才进行雷达扫描
                if (weakSelf.location == nil) {
                    weakSelf.location = location;
                    weakSelf.searchView.mapView.centerCoordinate = weakSelf.location.coordinate;
                    [weakSelf searchNearbyUsersWithStatus:YES];
                }
            
        };
    }
    return _appDelegate;
}

@end
