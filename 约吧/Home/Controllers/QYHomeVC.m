//
//  ViewController.m
//  01-配配
//
//  Created by qing on 16/3/8.
//  Copyright © 2016年 qing. All rights reserved.
//

#import "QYHomeVC.h"

//Models
#import "QYUserInfo.h"

//Views
#import "QYHomeSearchView.h"
#import "QYHomeAnimationView.h"

#import "QYLocationManager.h"
#import "QYUserStorage.h"

#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Radar/BMKRadarResult.h>

@interface QYHomeVC () <QYLocationManagerDelegate, QYNetworkDelegate, BMKMapViewDelegate, DanimationPro>
//Views
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *dislikeBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet QYHomeAnimationView *animationView;
@property (strong, nonatomic) QYHomeSearchView *searchView;


//data
@property (strong, nonatomic) NSString *userId;//当前用户Id
@property (strong, atomic) NSMutableArray *users;//每次雷达检索到的用户
@property (strong, nonatomic) NSMutableArray *nearbyUserIds;//附近所有用户Id

@property (nonatomic) NSInteger countOfUsers;


@end

@implementation QYHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _users = [NSMutableArray array];
    _nearbyUserIds = [NSMutableArray array];
    
    [self configSubView];
    
    [QYLocationManager sharedInstance].delegate = self;
    [[QYLocationManager sharedInstance] startToUpdateLocation];
    
    [QYNetworkManager sharedInstance].delegate = self;
}

#pragma mark - Custom Methods
-(void)configSubView{
    [self.view addSubview:self.searchView];
    
    _dislikeBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _dislikeBtn.layer.borderWidth = 1;
    _dislikeBtn.layer.cornerRadius = 50;
    
    _likeBtn.layer.borderColor = [UIColor redColor].CGColor;
    _likeBtn.layer.borderWidth = 1;
    _likeBtn.layer.cornerRadius = 50;
    
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
    [[QYLocationManager sharedInstance] searchNearByUsersWithLocation:_searchView.mapView.centerCoordinate];
}

#pragma mark - Events
//不喜欢当前用户
- (IBAction)unlikeAction:(UIButton *)sender {
    //TODO: 用户头像向左滑出屏幕
    [_animationView selectLikeOnce:dislike];
}

//喜欢当前用户
- (IBAction)likeAction:(UIButton *)sender {
    //TODO: 用户头像向右滑出屏幕
    [_animationView selectLikeOnce:like];
}

#pragma mark - DanimationPro
-(void)ChangeValueType:(ENLIKETYPE)type{
    //放大
    switch (type) {
        case like:{
            [UIView animateWithDuration:.2 animations:^{
                _dislikeBtn.transform=CGAffineTransformMakeScale(1.2, 1.2);
                _dislikeBtn.transform=CGAffineTransformIdentity;
            }];
            
        }
            break;
        case dislike:{
            [ UIView animateWithDuration:.2 animations:^{
                _dislikeBtn.transform=CGAffineTransformMakeScale(1.2, 1.2);
                _likeBtn.transform=CGAffineTransformIdentity;
            }];
            
        }
            break;
        default:
            break;
    }
}
-(void)FinishendValueType{
    //恢复正常
    [UIView animateWithDuration:.2 animations:^{
        _likeBtn.transform=CGAffineTransformIdentity;
        _dislikeBtn.transform=CGAffineTransformIdentity;
    }];
}

-(void)noMoreUser{
    [self.view addSubview:self.searchView];
    [_users removeAllObjects];
    //继续查找附近用户
    [self searchNearbyUsersWithStatus:YES];
}



#pragma mark - QYLocationManager Delegate
-(void)didFinishUpdateLocation:(CLLocation *)location success:(BOOL)success{
    [[QYLocationManager sharedInstance] uploadUserInfoWithLocation:location.coordinate];
    _searchView.mapView.centerCoordinate = location.coordinate;
    
    [QYLocationManager sharedInstance] ;
}

-(void)didFinishSearchNearbyUsers:(BMKRadarNearbyResult *)result success:(BOOL)success{
    if (success) {
        if (result) {
            _countOfUsers = result.infoList.count;
            NSLog(@"扫描到%ld个用户", _countOfUsers);
            [result.infoList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BMKRadarNearbyInfo *nearbyInfo = (BMKRadarNearbyInfo *)obj;
                if ([_nearbyUserIds containsObject:nearbyInfo.userId]) {//如果该用户之前检索到了，则不再显示
                    return;
                }else{
                    [_nearbyUserIds addObject:nearbyInfo.userId];
                    //根据用户Id获取用户信息
                    NSDictionary *params = @{kNetworkKeyUserId : nearbyInfo.userId};
                    [[QYNetworkManager sharedInstance] getUserInfoWithParameters:params];
                }
            }];
        }else{
            [self searchNearbyUsersWithStatus:NO];
            NSLog(@"附近没有更多的人了...");
        }
    }else{
        [SVProgressHUD showErrorWithStatus:kNetworkFail];
    }
}

#pragma mark - QYNetworkManager Delegate
-(void)didGetUserInfo:(id)responseObject success:(BOOL)success{
    if (success) {
        QYUserInfo *userInfo = [QYUserInfo userWithDictionary:responseObject];
        [_users addObject:userInfo];
        //TODO: 本地存储
        
        //判断检索到的用户是否加载完毕
        if (_users.count == _countOfUsers) {
            //在UI显示
            dispatch_async(dispatch_get_main_queue(), ^{
                _animationView.users = _users;
                [_searchView removeFromSuperview];
            });
        }
    }
}

#pragma mark - BMKMapView Delegate
-(void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //查找附近用户
    [self searchNearbyUsersWithStatus:YES];
}


#pragma mark - Getters
-(QYHomeSearchView *)searchView{
    if (_searchView == nil) {
        _searchView = [[QYHomeSearchView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, kScreenH)];
        _searchView.mapView.delegate = self;
    }
    return _searchView;
}


@end
