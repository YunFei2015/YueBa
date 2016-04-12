//
//  QYHomeSearchView.h
//  约吧
//
//  Created by 云菲 on 4/11/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMKMapView;

@interface QYHomeSearchView : UIView
@property (strong, nonatomic) BMKMapView *mapView;
@property (nonatomic) BOOL hasMore;//附近是否有更多用户
@end
