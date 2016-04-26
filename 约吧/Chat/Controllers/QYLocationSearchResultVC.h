//
//  QYMapSearchResultVC.h
//  约吧
//
//  Created by 云菲 on 3/28/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLLocation;

@interface QYLocationSearchResultVC : UIViewController <UISearchResultsUpdating>
@property (strong, nonatomic) CLLocation *location;

@end
