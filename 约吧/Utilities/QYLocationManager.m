//
//  QYMapManager.m
//  约吧
//
//  Created by 云菲 on 3/29/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import "QYLocationManager.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>

@interface QYLocationManager () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKRadarManagerDelegate>
@property (strong, nonatomic) BMKLocationService *locationService;
@property (strong, nonatomic) BMKGeoCodeSearch *geocodeSearch;
@property (strong, nonatomic) BMKRadarManager *radarManager;

@property (nonatomic) CLLocationCoordinate2D location;

@end

@implementation QYLocationManager
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)setDelegate:(id<QYLocationManagerDelegate>)delegate{
    if (delegate == nil) {
        self.locationService.delegate = nil;
        self.geocodeSearch.delegate = nil;
        [self.radarManager removeRadarManagerDelegate:self];
    }
    
    _delegate = delegate;
}

-(void)startToUpdateLocation{
    [self.locationService startUserLocationService];
}

-(void)stopToUpdateLocation{
    [self.locationService stopUserLocationService];
}

-(void)getLocationWithAddress:(NSString *)address{
    BMKGeoCodeSearchOption *option = [[BMKGeoCodeSearchOption alloc] init];
    option.address = address;
    if ([self.geocodeSearch geoCode:option]) {
        NSLog(@"发起地理编码成功");
    }else{
        NSLog(@"发起地理编码失败");
    }
}

-(void)getAddressWithLocation:(CLLocationCoordinate2D)location{
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    option.reverseGeoPoint = location;
    if ([self.geocodeSearch reverseGeoCode:option]) {
        NSLog(@"发起地理反编码成功");
    }else{
        NSLog(@"发起地理反编码失败");
    }
}

-(void)searchNearByUsersWithLocation:(CLLocationCoordinate2D)location{
    BMKRadarNearbySearchOption *option = [[BMKRadarNearbySearchOption alloc] init];
    option.radius = 1000;
    option.sortType = BMK_RADAR_SORT_TYPE_DISTANCE_FROM_NEAR_TO_FAR;
    option.centerPt = location;
    BOOL result = [self.radarManager getRadarNearbySearchRequest:option];
    if (result) {
        NSLog(@"发起雷达检索成功");
    }else{
        NSLog(@"发起雷达检索失败,%f,%f", location.latitude, location.longitude);
    }
}

-(void)uploadUserInfoWithLocation:(CLLocationCoordinate2D)location{
    
//    [self.radarManager clearMyInfoRequest];
    _location = location;
    [self.radarManager startAutoUpload:5];
}

#pragma mark - BMKLocation Service Delegate
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    CLLocation *location = userLocation.location;
    NSLog(@"%f,%f", location.coordinate.latitude, location.coordinate.longitude);
    if ([self.delegate respondsToSelector:@selector(didFinishUpdateLocation:success:)]) {
        [self.delegate didFinishUpdateLocation:location success:YES];
    }
}

-(void)didStopLocatingUser{
    _radarManager = nil;
}

-(void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"%@", error);
    if ([self.delegate respondsToSelector:@selector(didFinishUpdateLocation:success:)]) {
        [self.delegate didFinishUpdateLocation:nil success:NO];
    }
}

#pragma mark - BMKRadarManagement delegate
-(void)onGetRadarClearMyInfoResult:(BMKRadarErrorCode)error{
    if (error == BMK_RADAR_PERMISSION_UNFINISHED) {
        [self.radarManager clearMyInfoRequest];
    }
    NSLog(@"清除位置信息 ：%d", error);
}

-(BMKRadarUploadInfo *)getRadarAutoUploadInfo{
    BMKRadarUploadInfo *myinfo = [[BMKRadarUploadInfo alloc] init];
    myinfo.extInfo = @"hello,world";//扩展信息
    myinfo.pt = _location;
    return myinfo;
}

-(void)onGetRadarUploadResult:(BMKRadarErrorCode)error{
    if (error != BMK_RADAR_NO_ERROR) {
        NSLog(@"上传我的位置失败 ：%d", error);
    }else{
        NSLog(@"上传我的位置成功");
        [self.radarManager stopAutoUpload];
    }
}

-(void)onGetRadarNearbySearchResult:(BMKRadarNearbyResult *)result error:(BMKRadarErrorCode)error{
    if (error == BMK_RADAR_NO_ERROR) {
        //TODO: 调试的，需要删除
        [result.infoList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"扫描到的用户userId ：%@", [obj valueForKey:@"userId"]);
        }];
        if ([self.radarDelegate respondsToSelector:@selector(didFinishSearchNearbyUsers:success:)]) {
            [self.radarDelegate didFinishSearchNearbyUsers:result success:YES];
        }
    }else if (error == BMK_RADAR_NO_RESULT){
        if ([self.radarDelegate respondsToSelector:@selector(didFinishSearchNearbyUsers:success:)]) {
            [self.radarDelegate didFinishSearchNearbyUsers:nil success:YES];
        }
    }else if (error == BMK_RADAR_PERMISSION_UNFINISHED){
        NSLog(@"雷达尚未完成鉴权，继续检索");
        sleep(5);
        [self searchNearByUsersWithLocation:_location];
    }else{
        if ([self.radarDelegate respondsToSelector:@selector(didFinishSearchNearbyUsers:success:)]) {
            NSLog(@"雷达检索失败：%u", error);
            [self.radarDelegate didFinishSearchNearbyUsers:nil success:NO];
        }
    }
}

#pragma mark - BMKGeoCodeSearch Delegate
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        if ([self.delegate respondsToSelector:@selector(didGetAddress:nearBy:success:)]) {
            [self.delegate didGetAddress:result.address nearBy:result.poiList success:YES];
        }
    }else{
        NSLog(@"地理反编码失败:%d", error);
        if ([self.delegate respondsToSelector:@selector(didGetAddress:nearBy:success:)]) {
            [self.delegate didGetAddress:nil nearBy:nil success:NO];
        }
    }
}

-(void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"%f,%f", result.location.latitude, result.location.longitude);
        CLLocationCoordinate2D location = result.location;
        if ([self.delegate respondsToSelector:@selector(didGetLocation:success:)]) {
            [self.delegate didGetLocation: location success:YES];
        }
    }else{
        NSLog(@"地理编码失败:%d", error);
        if ([self.delegate respondsToSelector:@selector(didGetLocation:success:)]) {
            [self.delegate didGetLocation:kCLLocationCoordinate2DInvalid success:NO];
        }
    }
}


#pragma mark - Getters
-(BMKLocationService *)locationService{
    if (_locationService == nil) {
        _locationService = [[BMKLocationService alloc] init];
        _locationService.allowsBackgroundLocationUpdates = YES;
        _locationService.desiredAccuracy = kCLLocationAccuracyBest;
        _locationService.distanceFilter = 0;
        _locationService.delegate = self;
    }
    return _locationService;
}

-(BMKGeoCodeSearch *)geocodeSearch{
    if (_geocodeSearch == nil) {
        _geocodeSearch = [[BMKGeoCodeSearch alloc] init];
        _geocodeSearch.delegate = self;
    }
    return _geocodeSearch;
}

-(BMKRadarManager *)radarManager{
    if (_radarManager == nil) {
        _radarManager = [BMKRadarManager getRadarManagerInstance];
        [_radarManager addRadarManagerDelegate:self];
        NSString *myId = [@([QYAccount currentAccount].userId) stringValue];
        NSLog(@"myId : %@", myId);
        if (myId) {
            _radarManager.userId = myId;
//            _radarManager.userId = @"0";
        }
    }
    return _radarManager;
}

@end
