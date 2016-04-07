//
//  AppDelegate.h
//  约吧
//
//  Created by 云菲 on 3/16/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMKMapManager;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BMKMapManager *mapManager;

-(void)setRootViewControllerToHome;
-(void)setRootViewControllerToEntrance;
@end

