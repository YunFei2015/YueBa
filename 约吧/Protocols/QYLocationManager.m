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

@interface QYLocationManager () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@property (strong, nonatomic) BMKLocationService *locationService;
@property (strong, nonatomic) BMKGeoCodeSearch *geocodeSearch;

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

-(void)dealloc{
    self.locationService.delegate = nil;
    self.geocodeSearch.delegate = nil;
}

-(void)startToUpdateLocation{
    [self.locationService startUserLocationService];
}

-(void)getLocationWithAddress:(NSString *)address{
    BMKGeoCodeSearchOption *option = [[BMKGeoCodeSearchOption alloc] init];
    option.address = address;
    if ([self.geocodeSearch geoCode:option]) {
        NSLog(@"发起地理编码成功");
    }else{
        NSLog(@"发起地理编码失败");
    }
    
    option = nil;
}

-(void)getAddressWithLocation:(CLLocationCoordinate2D)location{
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    option.reverseGeoPoint = location;
    if ([self.geocodeSearch reverseGeoCode:option]) {
        NSLog(@"发起地理反编码成功");
    }else{
        NSLog(@"发起地理反编码失败");
    }
    option = nil;
}

#pragma mark - BMKLocation Service Delegate
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    CLLocation *location = userLocation.location;
    [self.locationService stopUserLocationService];
    NSLog(@"%f,%f", location.coordinate.latitude, location.coordinate.longitude);
    if ([self.delegate respondsToSelector:@selector(didFinishUpdateLocation:success:)]) {
        [self.delegate didFinishUpdateLocation:location success:YES];
    }
    
}

-(void)didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"%@", error);
    if ([self.delegate respondsToSelector:@selector(didFinishUpdateLocation:success:)]) {
        [self.delegate didFinishUpdateLocation:nil success:NO];
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
        _locationService.desiredAccuracy = kCLLocationAccuracyBest;
        _locationService.distanceFilter = 10;
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

@end
