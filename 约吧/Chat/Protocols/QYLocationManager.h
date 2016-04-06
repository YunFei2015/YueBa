//
//  QYMapManager.h
//  约吧
//
//  Created by 云菲 on 3/29/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@protocol QYLocationManagerDelegate <NSObject>

-(void)didFinishUpdateLocation:(CLLocation *)location success:(BOOL)success;
-(void)didGetLocation:(CLLocationCoordinate2D)location success:(BOOL)success;
-(void)didGetAddress:(NSString *)address nearBy:(NSArray *)nearByList success:(BOOL)success;

@end

@interface QYLocationManager : NSObject

@property (nonatomic) id <QYLocationManagerDelegate> delegate;
+(instancetype)sharedInstance;
-(void)startToUpdateLocation;
-(void)getLocationWithAddress:(NSString *)address;
-(void)getAddressWithLocation:(CLLocationCoordinate2D)location;
@end
