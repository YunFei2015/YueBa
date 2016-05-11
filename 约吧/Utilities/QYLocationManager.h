//
//  QYMapManager.h
//  约吧
//
//  Created by 云菲 on 3/29/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
@class BMKRadarNearbyResult;

@protocol QYLocationManagerDelegate <NSObject>

@optional
-(void)didFinishUpdateLocation:(CLLocation *)location success:(BOOL)success;
-(void)didGetLocation:(CLLocationCoordinate2D)location success:(BOOL)success;
-(void)didGetAddress:(NSString *)address nearBy:(NSArray *)nearByList success:(BOOL)success;


@end

@protocol QYRadarDelegate <NSObject>

-(void)didFinishSearchNearbyUsers:(BMKRadarNearbyResult *)result success:(BOOL)success;

@end

@interface QYLocationManager : NSObject

@property (nonatomic, weak) id <QYLocationManagerDelegate> delegate;
@property (nonatomic, weak) id <QYRadarDelegate> radarDelegate;
+(instancetype)sharedInstance;
/**
 *  开始定位
 */
-(void)startToUpdateLocation;

/**
 *  停止定位
 */
-(void)stopToUpdateLocation;

/**
 *  地理编码
 *
 *  @param address 地址信息
 */
-(void)getLocationWithAddress:(NSString *)address;

/**
 *  地理反编码
 *  
 *  @param location 经纬度
 */
-(void)getAddressWithLocation:(CLLocationCoordinate2D)location;

/**
 *  雷达搜索周围使用该app的用户
 *
 *  @param location 当前位置
 *  @param userId   当前用户Id
 */
-(void)searchNearByUsersWithLocation:(CLLocationCoordinate2D)location;

/**
 *  上传我的位置
 *
 *  @param location 当前位置
 */
-(void)uploadUserInfoWithLocation:(CLLocationCoordinate2D)location;
@end
