//
//  AppDelegate.h
//  约吧
//
//  Created by 云菲 on 3/16/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMKMapManager;
@class CLLocation;


//typedef void(^QYLocateSuccess)(CLLocation *);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BMKMapManager *mapManager;

-(void)setRootViewControllerToHome;
-(void)setRootViewControllerToEntrance;

@property (strong, nonatomic) CLLocation *location;
@property (strong, atomic) NSMutableArray *nearbyUsers;//在应用程序生命周期内，把附近在使用该app的用户存储到内存
@property (nonatomic, copy) void(^locationSuccess)(CLLocation *);


@end

