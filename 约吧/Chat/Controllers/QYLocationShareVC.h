//
//  QYMapViewController.h
//  约吧
//
//  Created by 云菲 on 3/28/16.
//  Copyright © 2016 云菲. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYPinAnnotation.h"
typedef void(^QYSendLocationToShare)(QYPinAnnotation *);
@interface QYLocationShareVC : UIViewController
@property (strong, nonatomic) QYSendLocationToShare sendLocationToShare;
@end
