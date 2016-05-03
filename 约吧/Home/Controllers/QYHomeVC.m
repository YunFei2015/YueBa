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

//vendors
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Radar/BMKRadarResult.h>

@interface QYHomeVC () <QYNetworkDelegate, BMKMapViewDelegate, DanimationPro, QYRadarDelegate>
@property (strong, nonatomic) AppDelegate *appDelegate;

//Views
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *dislikeBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet QYHomeAnimationView *animationView;
@property (strong, nonatomic) QYHomeSearchView *searchView;

//data
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *userId;//当前用户Id
@property (strong, atomic) NSMutableArray *nearbyUsers;//每次雷达检索到的用户


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
    [[QYLocationManager sharedInstance] searchNearByUsersWithLocation:_location.coordinate];
}

#pragma mark - Events
//不喜欢当前显示的用户
- (IBAction)unlikeAction:(UIButton *)sender {
    [_animationView selectLikeOnce:dislike];
}

//喜欢当前显示的用户
- (IBAction)likeAction:(UIButton *)sender {
    [_animationView selectLikeOnce:like];
}

#pragma mark - DanimationPro
-(void)ChangeValueType:(ENLIKETYPE)type{
    //放大
    switch (type) {
        case like:{
            [UIView animateWithDuration:1 animations:^{
                _likeBtn.transform=CGAffineTransformMakeScale(2, 2);
                _likeBtn.transform=CGAffineTransformIdentity;
            }];
            
        }
            break;
        case dislike:{
            [ UIView animateWithDuration:1 animations:^{
                _dislikeBtn.transform=CGAffineTransformMakeScale(2, 2);
                _dislikeBtn.transform=CGAffineTransformIdentity;
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

-(void)markUser:(QYUserInfo *)user asLike:(BOOL)isLike{
    //TODO: 向服务器发送数据
    
    //
    [_nearbyUsers removeObject:user];
    if (_nearbyUsers.count == 0) {
        [self.view addSubview:self.searchView];
        //继续查找附近用户
        [self searchNearbyUsersWithStatus:NO];
    }
}

#pragma mark - QYLocationManager Delegate
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
            NSDictionary *params = @{@"ids" : ids};
            [[QYNetworkManager sharedInstance] getUserInfoWithParameters:params];
            
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
        [responseObject[kResponseKeyData][@"users"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            QYUserInfo *userInfo = [QYUserInfo userWithDictionary:obj];
            [_nearbyUsers addObject:userInfo];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _animationView.users = _nearbyUsers;
            [_searchView removeFromSuperview];
        });
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


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIStoryboard *sbProfile = [UIStoryboard storyboardWithName:@"QYProfile" bundle:nil];
    UIViewController *vcInitial = [sbProfile instantiateInitialViewController];
    [self.navigationController pushViewController:vcInitial animated:YES];
}

@end
